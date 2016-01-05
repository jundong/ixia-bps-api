#!/bin/sh
lappend auto_path [file dirname [file dirname [info script]]]

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set testName {MyAutoTest}
set testNewName {MyAutoTest}

set componentName {MyAutoComponent}

set loadProfileName {BreakingPoint Default}
set newLoadProfileName {MyAutoLoadProfile}

#Tester @tester 192.168.0.132 admin admin
Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]
set chassis [ @tester getChassis ]

#@tester createTest $testNewName -template $testName
@tester createTest $testNewName
set test [ @tester getTest $testNewName ]

@tester createLoadProfile $newLoadProfileName -template $loadProfileName
set loadProfile [ @tester getLoadProfile $newLoadProfileName ]
@tester save $newLoadProfileName -force

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
@tester configure $componentName -rampDist.up 00:00:10 \
    -rampDist.upBehavior full \
    -rampDist.steady 00:00:60 \
    -rampDist.steadyBehavior cycle \
    -rampDist.down 00:00:05 \
    -rampDist.downBehavior full \
    -delayStart 00:00:05 \
    -loadprofile $newLoadProfileName

@tester save $testNewName -force

#@tester importTest Import1 -file C:/Tmp/Bps/import.bpt -force
#
#@tester reservePort [list { 0 0 } { 0 1 }]
#@tester run $testNewName -rtstats cbRunTimeStats -async cbAsyncRunTest
#set times 10
#while { $times > 0 } {
#    #Add your interoperation here
#    after 2000
#    set times [ expr $times - 1 ]
#}
#@tester cancel $testNewName
#set rt [ @tester getRtStats $testNewName ]
#puts "rt=============$rt"
#set cstats [ @tester getComponentStats $componentName ]
#puts "cstats=============$cstats"
#set agg [ @tester getAggStats $testNewName ]
#puts "agg=============$agg"
##@tester exportTest $testNewName -file C:/Tmp/Bps/export1.bpt
#@tester unreservePort [list { 0 0 } { 0 1 }]
@tester delete $componentName
@tester save $testNewName -force
#set conn [bps::connect 172.16.174.128 admin admin]
#set test [$conn createTest -template $testName -name $testName]