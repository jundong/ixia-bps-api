#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}
#lappend auto_path [file dirname [file dirname [info script]]]
lappend auto_path {C:\Ixia\Workspace\ixia-bps-api}

proc cbTestProgress { name process } {
    puts "cbTestProgress: $name, $process"
}

proc cbAsyncRunTest { args } {
    puts "cbAsyncRunTest: $args"
}
    
#package require IxiaBps
#namespace import IXIA::*
package require bps
package require dict

set conn [bps::connect 10.210.100.30 admin admin]
#set conn [bps::connect 172.16.174.131 admin admin]
set chassis [$conn getChassis]
$chassis reservePort 0 0
$chassis reservePort 0 1
set test [$conn createTest -template TestStrikeExportPcap -name TestStrikeExportPcap]
$test save -force
#Synchronous mode
$test run -async cbAsyncRunTest -progress cbTestProgress
after [expr 100 * 1000]
#$chassis exportPacketTrace C:/Tmp 0 0 both
$test exportReport -file TestStrikeExportPcap.csv -format "csv"      




