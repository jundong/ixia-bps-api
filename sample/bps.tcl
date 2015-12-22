#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}
lappend auto_path C:/Ixia/Libs/Bps/bpsh-win32.vfs/lib

package require bps
package require dict
package require Itcl

set conn [bps::connect 192.168.0.132 admin admin]
#set chassisObjectName [$var getChassis]

# the callback for a state change should accept these arguments
proc reportStateChange {slot port state} {
    puts "slot $slot, port $port is now in state $state"
}

# the callback for a port reservation should accept these arguments
proc reportReservation {slot port reservedBy group} {
    if {$reservedBy == ""} {
        puts "slot $slot, port $port has been unreserved"
        return
    }
    puts "slot $slot, port $port is reserved by $reservedBy in group $group"
}

# the callback for a link change should accept these arguments
proc reportLink {slot port link media speed duplex} {
    puts "link is now $link on slot $slot, port $port"
    if {$media != ""} {
        puts "using $media at speed=$speed, duplex=$duplex"
    }
}

set c1 [$conn getChassis -onreserve reportReservation \
    -onstate reportStateChange \
    -onlink reportLink]

$c1 reservePort 0 0 -group 1
$c1 reservePort 0 1 -group 1
$c1 unreservePort 2 1
$c1 getState
$c1 configurePort 0 0 -auto false -speed 100 -fullduplex false

set test1 [$conn createTest -template {Cyber-Range Application} -name {Cyber-Range Application}]
$conn exportTest -testid  -file C:/Tmp/Bps/bps7.bpt


