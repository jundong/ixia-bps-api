#!/bin/sh
lappend auto_path [file dirname [file dirname [info script]]]

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set loadProfile {MyLoadProfile}
set newLoadProfile {MyLoadProfile}

Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]

@tester createLoadProfile $newLoadProfile -template $loadProfile
set profile [ @tester getLoadProfile $newLoadProfile ]

#====================== Phase ===========================
set action "add"
set index 2
@tester configurePhase $newLoadProfile $action $index -duration 11 \
    -rampDist.steadyBehavior cycle \
    -sessions.max 11111 \
    -sessions.maxPerSecond 11111 \
    -rateDist.min 111 \
    -rateDist.unit mbps \
    -rateDist.scope per_if 

set action "modify"
set index 2
@tester configurePhase $newLoadProfile $action $index -duration 222 \
    -rampDist.steadyBehavior cycle \
    -sessions.max 22222 \
    -sessions.maxPerSecond 22222 \
    -rateDist.min 2222 \
    -rateDist.unit mbps \
    -rateDist.scope per_if 

set action "remove"
set index 2
@tester configurePhase $newLoadProfile $action $index
#====================== Phase ===========================

#Available phases
#$profile getPhases
#0 {duration 1 rampDist.upBehavior full sessions.max 50000 sessions.maxPerSecond 50000 rateDist.min 900 rateDist.unit mbps rateDist.scope per_if} 1 {duration 28 rampDist.steadyBehavior cycle sessions.max 50000 sessions.maxPerSecond 50000 rateDist.min 900 rateDist.unit mbps rateDist.scope per_if} 2 {duration 1 rampDist.downBehavior full sessions.max 1 sessions.maxPerSecond 50000 rateDist.min 900 rateDist.unit mbps rateDist.scope per_if}