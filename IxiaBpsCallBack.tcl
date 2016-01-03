#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

namespace eval IXIA {
    namespace export *
    
    proc cbSessionClose { args } {
        puts "cbSessionClose: $args"
        exit
    }
    
    proc cbPortStateChanged { slot port state } {
        puts "slot $slot, port $port is now in state $state"
    }
    
    proc cbPortReserved { slot port reservedBy group } {
        if { $reservedBy == "" } {
            puts "slot $slot, port $port has been unreserved"
            return
        }
        puts "slot $slot, port $port is reserved by $reservedBy in group $group"
    }
    
    proc cbPortLinkChanged { slot port link media speed duplex } {
        puts "link is now $link on slot $slot, port $port"
        if { $media != "" } {
            puts "using $media at speed=$speed, duplex=$duplex"
        }
    }
    
    proc cbTestProgress { name process } {
        set IXIA::rtProcess($name) $process
    }
    
    proc cbRunTimeStats { name stats } {
        set IXIA::rtStats($name) $stats
        puts "============================"
        dict for { var val } $stats {
            puts "$var: $val"
        }
        puts "============================"
    }
    
    proc cbAsyncRunTest { args } {
        puts "cbAsyncRunTest: $args"
        puts $args
    }
    
    proc cbAsyncStopTest { args } {
        puts "cbAsyncStopTest: $args"
        puts $args
    }
}
