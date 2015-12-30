#!/bin/sh
lappend auto_path C:/Ixia/Workspace/ixia-bps-api

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set testId {test@66@127.0.0.1@DSTA_Test7_CXO_Data_Loss@8}
set testName {MyAutoTest1}
set testNewName {MyAutoTestNew}

#set conn [bps::connect 172.16.174.128 admin admin]
#set test [$conn createTest -template $testName -name $testName]

Tester @tester 172.16.174.128 admin admin
set conn [ @tester getConnection ]
#Tester @tester 192.168.0.132 admin admin

#@tester importTest Import1 -file C:/Tmp/Bps/import.bpt -force

@tester createTest $testNewName -template $testName
set test [ @tester getTest $testNewName ]
@tester reservePort [list { 0 0 } { 0 1 }]

#@tester run $testNewName -rtstats cbRunTimeStats
#after 10000
#@tester cancel $testNewName
#@tester exportTest $testNewName -file C:/Tmp/Bps/export1.bpt
@tester unreservePort [list { 0 0 } { 0 1 }]