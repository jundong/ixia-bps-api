#!/bin/sh
lappend auto_path C:/Ixia/Workspace/ixia-bps-api

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set superflow {MyAutoTest1}
set newSuperflow {MyAutoTestNew}

Tester @tester 172.16.174.128 admin admin
set conn [ @tester getConnection ]

@tester createSuperflow $superflow -template $testName
set test [ @tester getSuperflow $newSuperflow ]
@tester reservePort [list { 0 0 } { 0 1 }]

#@tester run $testNewName -rtstats cbRunTimeStats
#after 10000
#@tester cancel $testNewName
#@tester exportTest $testNewName -file C:/Tmp/Bps/export1.bpt
@tester unreservePort [list { 0 0 } { 0 1 }]