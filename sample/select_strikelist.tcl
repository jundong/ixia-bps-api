#!/bin/sh
#lappend auto_path [file dirname [file dirname [info script]]]
lappend auto_path {C:\Ixia\Workspace\ixia-bps-api}
package require IxiaBps
namespace import IXIA::*

IxdebugOn

set testName {TestStrikeExportPcap}
set strikeListName {TestStrikeList}
set newNetworkName {TestNetwork}
set componentName {Security_1}
set portList [list { 0 0 } { 0 1 }]

Tester @tester 10.210.100.30 admin admin
#Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]
set chassis [ @tester getChassis ]

@tester importTest $testName -file [file dirname [info script]]/bpt/${testName}.bpt -force

@tester createTest $testName -template $testName
set test [ @tester getObjByName $testName ]

@tester createNetwork $newNetworkName -template {BreakingPoint Switching}
set network [ @tester getObjByName $newNetworkName ]
set action "config"
set type "interface"
set parameters [ list "Interface 1" "Interface 2"]
@tester configureNetwork $newNetworkName $action $type $parameters -mtu 9198
@tester save $newNetworkName -force

# Configure test with network "TestNetwork"
@tester configure $testName -neighborhood $newNetworkName
@tester save $testName -force

@tester createStrikeList $strikeListName -template {All Strikes}
set strikeList [@tester getObjByName $strikeListName]
@tester save $strikeListName -force

@tester configureComponent $testName $componentName -attackPlan $strikeListName
set component [@tester getObjByName $componentName]
@tester save $testName -force

@tester reservePort $portList
        
#@tester startCapture $testName
@tester run $testName
#@tester stopCapture $testName
set exportPath [file join "[file dirname [info script]]/results" $strikeListName]
after 5000
@tester exportCapture $portList $exportPath "both" -compress false
after 5000
@tester exportReport $testName -file [file join $exportPath "${strikeListName}.csv"] -format "csv"   

@tester unreservePort $portList

