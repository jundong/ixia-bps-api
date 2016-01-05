#!/usr/bin/env tclsh
if {![catch {package require starkit}]} {
  starkit::startup
} else {
  set scriptdir [file normalize [file dirname [info script]]]
  lappend auto_path \
    [file join $scriptdir bps] \
    [file join $scriptdir ack] \
    [file join $scriptdir flash] \
    [file join $scriptdir model] \
    [file join $scriptdir interactive] \
    [file join $scriptdir library]
}

package require bps
package require cmdline
package require tryfinally

if {[catch {array set opts [cmdline::getoptions argv {
  {i "force interactive mode"}
  {v "get version"}
  {local.secret "local login from shell on-box (no password required)"}
  {nologin.secret "Prevent local login"}
}]} err]} {
  puts $err
  exit
}

if {$opts(v)} {
  puts "bpsh version: $bpsh_version"
  exit
}

if {$opts(local) && !$opts(nologin)} {
    set bps [bps::connect 127.0.0.1 $env(USER) \0 -port 8880 -onclose exit -checkversion false]
}
if {[llength $argv] != 0} {
  # strip the script name off of the args
  set argv0 [lindex $argv 0]
  set argv [lrange $argv 1 end]
  source $argv0
  set scriptarg true
} else {
  set scriptarg false
}

if {!$scriptarg || $opts(i)} {
  if {[string match Windows* $tcl_platform(os)] &&
      [info commands console] != ""} {
    wm withdraw .
    console title bpsh
    console show
    after idle {console eval {wm protocol . WM_DELETE_WINDOW exit}}

    # workaround issue with \0 defaults
        proc ::cmdline::usage {optlist {usage {options:}}} {
            set str "[getArgv0] $usage\n"
            foreach opt [concat $optlist \
              {{help "Print this message"} {? "Print this message"}}] {
          set name [lindex $opt 0]
          if {[regsub -- .secret$ $name {} name] == 1} {
              # Hidden option
              continue
          }
          if {[regsub -- .arg$ $name {} name] == 1} {
              set default [lindex $opt 1]
              regsub -all {[^[:graph:]]} $default {} default
              set comment [lindex $opt 2]
              append str [format " %-20s %s <%s>\n" "-$name value" \
                $comment $default]
          } else {
              set comment [lindex $opt 1]
              append str [format " %-20s %s\n" "-$name" $comment]
          }
            }
            return $str
        }
  } else {
    if {$opts(local) && !$opts(nologin)} {
        puts "Active BPS connection available as \$bps"
    }
    package require interactive
    set historyfile .bpsh_history
    if {[string match Windows* $tcl_platform(os)]} {
        set historyfile bpsh_history.tcl
    }
    interactive::interact -historyfile [file join $env(HOME) $historyfile]
  }
}
