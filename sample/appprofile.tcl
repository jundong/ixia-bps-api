#!/bin/sh
lappend auto_path C:/Ixia/Workspace/ixia-bps-api

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set appProfile {MyAppProfile}
set newAppProfile {MyAppProfile}
set superflow {MySuperflow}

Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]

@tester createAppProfile $newAppProfile -template $appProfile
set profile [ @tester getAppProfile $newAppProfile ]

#====================== Flow ===========================
set action "add"
@tester configureAppProfile $newAppProfile $superflow $action -weight 1111

set action "modify"
@tester configureAppProfile $newAppProfile $superflow $action -weight 888 -seed 999

set action "remove"
@tester configureAppProfile $newAppProfile $superflow $action
#====================== Flow ===========================
