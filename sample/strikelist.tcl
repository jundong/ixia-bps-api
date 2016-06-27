#!/bin/sh
#lappend auto_path [file dirname [file dirname [info script]]]
lappend auto_path {C:\Ixia\Workspace\ixia-bps-api}
package require IxiaBps
namespace import IXIA::*

IxdebugOn

set testName {TestStrikeExportPcap}
set strikeListName {TestStrike}
set componentName {Security_1}
set portList [list { 0 0 } { 0 1 }]

Tester @tester 10.210.100.30 admin admin
#Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]
set chassis [ @tester getChassis ]

@tester importTest $testName -file [file dirname [info script]]/bpt/${testName}.bpt -force

@tester createTest $testName -template $testName
set test [ @tester getObjByName $testName ]

@tester createStrikeList $strikeListName -template $strikeListName
set strikeList [@tester getObjByName $strikeListName]
@tester save $strikeListName -force

@tester configureComponent $testName $componentName -attackPlan $strikeListName
set component [@tester getObjByName $componentName]
@tester save $testName -force

@tester reservePort $portList

set keywords [list "backdoor" "worm" "trojan" "overflow" "shellcode" "xss" "SQL injection"]
set loops 5
while { $loops >= 0 } {
    foreach keyword $keywords {
        # Empty strikeList
        foreach s [$strikeList getStrikes] {
            $strikeList removeStrike $s
        }
        foreach strike [$conn listStrikes -keywords $keyword] {
            if { [regexp ^/.* $strike strike] } {
                $strikeList addStrike $strike
            }
        }
        # Save strike list
        @tester save $strikeListName -force
        
        #@tester startCapture $testName
        @tester run $testName
        #@tester stopCapture $testName
        set exportPath [file join "[file dirname [info script]]/results" $keyword]
        after 5000
        @tester exportCapture $portList $exportPath "both" -compress false
        after 5000
        @tester exportReport $testName -file [file join $exportPath "${keyword}.csv"] -format "csv"   
    }
    incr loops -1
}
@tester unreservePort $portList

