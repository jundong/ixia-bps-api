# This package assumes the availability of the TclSyslog package, available
# from http://www.45.free.net/tcl/tclsyslog.html

package require log
package require Syslog
package require cmdline

namespace eval log2syslog {
  array set _levelMap {
    emergency emerg
    alert     alert
    critical  crit
    error     error
    warning   warning
    notice    notice
    info      info
    debug     debug
  }
  #set facility user
  #set ident $argv0

  set LOG_PID         0x01
  set LOG_CONS        0x02
  set LOG_ODELAY      0x04
  set LOG_NDELAY      0x08
  set LOG_NOWAIT      0x10
  set LOG_PERROR      0x20

}

proc log2syslog::log2syslog {args} {
  global argv0
  array set opts [cmdline::getoptions args [subst {
    {facility.arg local0 "facility"}
    {ident.arg $argv0 "ident"}
  }]]

  switch $opts(facility) {
     authpriv {}  
     cron {}
     daemon {}
     kernel {}
     lpr {}
     mail {}
     news {}
     syslog {}
     user {}
     uucp {}
     local0 {}
     local1 {}
     local2 {}
     default {
       error "invalid facility $opts(facility)"
     }
  }

  #set ::log2syslog::facility $opts(facility)
  #set ::log2syslog::ident $opts(ident)

  log::lvCmdForall ::log2syslog::syslogLvCmd

  # only first call needs to set facility etc.
  syslog -facility $opts(facility) \
         -ident $opts(ident) \
	 -options $::log2syslog::LOG_PID
	 #debug "initializing syslog"
	 #-options [expr $::log2syslog::LOG_PID | $::log2syslog::LOG_PERROR]
}

proc log2syslog::syslogLvCmd {level msg} {
  syslog $::log2syslog::_levelMap($level) \
	 $msg
}

package provide log2syslog 0.1
