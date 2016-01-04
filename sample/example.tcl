#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}
lappend auto_path C:/Ixia/Workspace/ixia-bps-api

#package require IxiaBps
#namespace import IXIA::*
package require bps
package require dict

set conn [bps::connect 192.168.0.132 admin admin]
set test [$conn createTest -template MyAutoTest -name MyAutoTest]

$test run -async echo 

puts [ $test resultId ]




