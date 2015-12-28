#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}
lappend auto_path C:/Ixia/Workspace/ixia-bps-api

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set testId {test@66@127.0.0.1@DSTA_Test7_CXO_Data_Loss@8}
set testName {DSTA_Test7_CXO_Data_Loss}
set testNewName {DSTA_Test7_CXO_Data_Loss_2}

#BpsConnection @bpsConn 192.168.0.132 admin admin
BpsConnection @bpsConn 172.16.174.128 admin admin
@bpsConn reservePort -portlist [ list { 0 0 } { 0 1 } ]
BpsTest @bpsTest @bpsConn $testName $testNewName
@bpsTest run -async cbAsyncRunTest
after 10000
@bpsTest startCapture
after 10000
@bpsTest stopCapture
@bpsTest stop
@bpsTest exportCapture -file C:/Tmp/Bps -direction both -portlist [list { 0 0 } ]
#set rtstats [ @bpsTest getRtStats ]
#set aggstats [ @bpsTest getAggStats ]

@bpsConn unreservePort -portlist [ list { 0 0 } { 0 1 } ]

#set conn [bps::connect 172.16.174.128 admin admin]
#set test [$conn createTest -template $testName -name $testName]


