#!/bin/sh
lappend auto_path C:/Ixia/Workspace/ixia-bps-api

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set testId {test@66@127.0.0.1@DSTA_Test7_CXO_Data_Loss@8}
set testName {MyAutoTest}
set testNewName {MyAutoTest}

set componentName {MyAutoTest}

set loadProfileName {MyLoadProfile}
set newLoadProfileName {MyLoadProfile}

#Tester @tester 192.168.0.132 admin admin
Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]

@tester createTest $testNewName -template $testName
set test [ @tester getTest $testNewName ]

@tester createLoadProfile $newLoadProfileName -template $loadProfileName
set loadProfile [ @tester getLoadProfile $newLoadProfileName ]

@tester createComponent $testNewName $componentName "appsim"
set component [ @tester getComponent $componentName ]

# Configure for component
#
#testName: The name of test, mandatory parameter
#componentName: The name of component in above test, mandatory parameter
#args: Args include several types of component, so user must give the matched parameters list. Below list the load options
#    -rampDist.down 00:00:15
#    -rampDist.downBehavior full, valid values are full, half and rst
#    -rampDist.steady 00:00:60
#    -rampDist.steadyBehavior cycle, valid values are cycle and hold 
#    -rampDist.up 00:00:01
#    -rampDist.upBehavior full, valid values are full, full + data,
#            full + data + close, half, data flood and syn
#    -rampDist.synRetryMode obey_retry
#
#    In StairStep load profile mode, we still can configure below options
#    -rampUpProfile.increment 1
#    -rampUpProfile.interval 00:00:01 00:00:01
#    -rampUpProfile.max 1
#    -rampUpProfile.min 1
#    -rampUpProfile.type calculated
#
@tester configure $componentName -rampDist.up 11:11:11
    -rampDist.upBehavior full \
    -rampDist.steady 22:22:22 \
    -rampDist.steadyBehavior cycle \
    -rampDist.down 33:33:33 \
    -rampDist.downBehavior full \
    -delayStart 99:99:99 \
    -loadprofile $loadProfile

#@tester importTest Import1 -file C:/Tmp/Bps/import.bpt -force

#@tester reservePort [list { 0 0 } { 0 1 }]
#@tester run $testNewName -rtstats cbRunTimeStats
#after 10000
#@tester cancel $testNewName
#@tester exportTest $testNewName -file C:/Tmp/Bps/export1.bpt
#@tester unreservePort [list { 0 0 } { 0 1 }]

#set conn [bps::connect 172.16.174.128 admin admin]
#set test [$conn createTest -template $testName -name $testName]