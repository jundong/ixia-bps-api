package require flash::flashchannel
package require flash::flashinterp

proc flash::standardizeError {cmd {errorstring {}}} {
  if {[catch [list uplevel $cmd] err]} {
    global errorInfo
    if {"" == $errorstring} {
      set errorstring $err
    }
    error $errorstring $errorInfo RUNTIME_ERROR
  }
}

proc flash::preamble {optlist {assumedopts {}} {requiredopts {}}} {
  global argv0

  if {[file exists /tmp/ignore_user_input]} {
    error "unable to process command; system upgrade in progress" \
           {} UPGRADE_IN_PROGRESS
  }

  set argv0 [lindex [info level -1] 0]
  upvar opts opts
  upvar args args
  lappend optlist \
      {clientinfo.arg.secret {} "client information"} \
      {token.arg.secret {} "token identifying this com interaction"}
  flash::standardizeError {
    array set opts [cmdline::getoptions args $optlist]
  }
  set i 0
  foreach {ao unspec} $assumedopts {
    if {$unspec == $opts($ao) && [llength $args] > $i} {
      set opts($ao) [lindex $args $i]
    }
  }
  foreach {ro unspec errid} $requiredopts {
    if {$unspec == $opts($ro)} {
      error "option -$ro must be specified" {} [list $errid $ro]
    }
  }

  upvar locale locale
  set locale en
  if {[dict exists $opts(clientinfo) flashi] && [itcl::find object [dict get $opts(clientinfo) flashi]] != ""} {
    set locale [[dict get $opts(clientinfo) flashi] cget -locale]
  }
  
  upvar userid userid
  set userid system
  if {[dict exists $opts(clientinfo) flashi] && [itcl::find object [dict get $opts(clientinfo) flashi]] != ""} {
    set u [[dict get $opts(clientinfo) flashi] cget -userid]
    if {$u != ""} {
       set userid $u
    }
  }
}


package provide flash 0.1
