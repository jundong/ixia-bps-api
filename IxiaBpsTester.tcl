package provide IxiaBps  1.0

####################################################################################################
# IxBps.tcl--
#   This file implements the Tcl encapsulation of IxBps interface
#
# Copyright (c) Ixia technologies, Inc.
# Change made
# Version 1.0
# a. Judo Xu-- Create
####################################################################################################

package require Itcl
namespace import itcl::*

namespace eval IXIA {
    namespace export *
    
    package require bps
    package require dict
    
    variable debug   0
    variable logfile ""
    variable rtStats
    variable rtProcess
    
    class Tester {
        protected variable _connection
        protected variable _chassis
        
        protected variable _attackSeries
        protected variable _components
        protected variable _evasionProfiles
        protected variable _lteTests
        protected variable _lawfulInterceptTests
        protected variable _loadProfiles
        protected variable _multiboxTests
        protected variable _multicastTests
        protected variable _neighborhoods
        protected variable _networks
        protected variable _rfc2544Tests
        protected variable _resiliencyTests
        protected variable _serverResiliencyTests
        protected variable _sessionLabTests
        protected variable _superflows
        protected variable _tests
        protected variable _testSeries
        protected variable _strikeLists
  
        constructor { host userid password args } {
            set tag "Tester::constructor $host $userid $password $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            if { [ catch {
                set cmd "bps::connect $host $userid $password $args"
                Deputs $cmd
                set _connection [ eval $cmd ]
                set cmd "$_connection getChassis"
                Deputs $cmd
                set _chassis [ eval $cmd ]
            } err ] } {
                set tag "----- Failed to connect to system£º$err -----"
                Deputs $tag
                return [GetErrorReturnHeader $err]
            }
            
            return [GetStandardReturnHeader]
        }
        public method run { name args } {}
        public method cancel { name args } {}
        
        public method createTest { name args } {}
        public method createTestSeries { name args } {}
        public method createLoadProfile { name args } {}
        public method createNetwork { name args } {}
        
        public method configure { name args } {}
        public method configureComponent { testName componentName args } {}
        public method save { name args } {}
        
        public method importTest { name args } {}
        public method exportTest { name args } {}
        public method exportReport { name args } {}
        
        public method getRtStats { name args } {}
        
        public method reservePort { portlist args } {}
        public method unreservePort { portlist } {}
        
        public method getChassis {} { return $_chassis }
        public method getConnection {} { return IXIA::Tester::$_connection }
        public method getTest { name } {
            if { [ catch {
                if { [info exists _tests($name) ] } {
                    return $_tests($name)
                }
            } err ] } {
                Deputs "No test $name found"
            }
        }
        public method getTestSeries { name } {
            if { [ catch {
                if { [info exists _testSeries($name) ] } {
                    return $_testSeries($name)
                }
            } err ] } {
                Deputs "No test series $name found"
            }
        }
        public method getLoadProfile { name } {
            if { [ catch {
                if { [info exists _loadProfiles($name) ] } {
                    return $_loadProfiles($name)
                }
            } err ] } {
                Deputs "No load profile $name found"
            }
            return ""
        }
    }

    #--
    # Name: configure - Configure created object
    #--
    # Parameters:
    #       name: The name of created object to configure, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configure { name args } {
        set tag "body Tester::configure $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "configure name must be configured"
        }
        
        set handle ""
        if { [ catch {
            if { ![ info exists _loadProfiles($name) ] } {
                set handle $_loadProfiles($name)
            } elseif { ![ info exists _tests($name) ] } {
                set handle $_tests($name)
            } elseif { ![ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
            } elseif { ![ info exists _networks($name) ] } {
                set handle $_networks($name)
            }
            
            if { $handle != "" } {
                set cmd "$handle configure $args"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "No resource with name: $name"
            }
        } err ] } {
            Deputs "----- Failed to configure resource $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: configureComponent - Configure component object
    #--
    # Parameters:
    #       name: The name of created object to configure, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configureComponent { testName componentName args } {
        set tag "body Tester::configure $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "configure name must be configured"
        }
        
        set handle ""
        if { [ catch {
            if { ![ info exists _loadProfiles($name) ] } {
                set handle $_loadProfiles($name)
            } elseif { ![ info exists _tests($name) ] } {
                set handle $_tests($name)
            } elseif { ![ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
            } elseif { ![ info exists _networks($name) ] } {
                set handle $_networks($name)
            }
            
            if { $handle != "" } {
                set cmd "$handle configure $args"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "No resource with name: $name"
            }
        } err ] } {
            Deputs "----- Failed to configure resource $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: save - Save updated object
    #--
    # Parameters:
    #       name: The name of object to configure, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::save { name args } {
        set tag "body Tester::save $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "save name must be configured"
        }
        
        set handle ""
        if { [ catch {
            if { ![ info exists _loadProfiles($name) ] } {
                set handle $_loadProfiles($name)
            } elseif { ![ info exists _tests($name) ] } {
                set handle $_tests($name)
            } elseif { ![ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
            } elseif { ![ info exists _networks($name) ] } {
                set handle $_networks($name)
            }
            
            if { $handle != "" } {
                set cmd "$handle save $args"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "No resource with name: $name"
            }
        } err ] } {
            Deputs "----- Failed to configure resource $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createLoadProfile - Create Load Profile
    #--
    # Parameters:
    #       name: The name of load profile to create, mandatory parameter, if for default load profile (Default or StairStep), nothing to do
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createLoadProfile { name args } {
        set tag "body Tester::createLoadProfile $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "createLoadProfile name must be configured"
        }
        
        if { [ catch {
            if { ![ info exists _loadProfiles($name) ] } {
                set cmd "$_connection createLoadProfile -name $name $args"
                Deputs $cmd
                set _loadProfiles($name) [ eval $cmd ]
            } 
        } err ] } {
            Deputs "----- Failed to create test $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: reservePort - Reserve Ports
    #--
    # Parameters:
    #       portlist: Port list to reserve, eg. [list {1 0} {1 1}]
    #       args:
    #            -group: Group ID, default value is 1
    #            -force: Wehter force to reserve port, default value is true
    #            .......
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::reservePort { portlist args } {
        set tag "body Tester::reservePort $portlist $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists portlist ] } {
            error "reservePort portlist must be configured"
        }
        
        set slot ""
        set port ""
        if { [ catch {
            foreach sp $portlist {
                set slot [lindex $sp 0]
                set port [lindex $sp 1]
                set cmd "$_chassis reservePort $slot $port $args"
                Deputs $cmd
                eval $cmd
            }
        } err ] } {
            Deputs "----- Failed to reserve port $slot/$port: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: unreservePort - UnReserve Ports
    #--
    # Parameters: 
    #       portlist: Port list to unreserve, eg. [list {1 0} {1 1}]
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::unreservePort { portlist } {
        set tag "body Tester::unreservePort $portlist [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists portlist ] } {
            error "unreservePort portlist must be configured"
        }
        
        set slot ""
        set port ""
        if { [ catch {
            foreach sp $portlist {
                set slot [lindex $sp 0]
                set port [lindex $sp 1]
                set cmd "$_chassis unreservePort $slot $port"
                Deputs $cmd
                eval $cmd
            }
        } err ] } {
            Deputs "----- Failed to unreserve port $slot/$port: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
        
    #--
    # Name: exportReport - Export test report
    #--
    # Parameters:
    #       name: Test or test series name, mandatory parameter
    #       args:
    #           -file: The destination file to export report
    #           -channel: File channel to save the report, not support now
    #           -format: Report format: csv, flowstats, html, pdf, rtf, xls,
    #                       bpt, xml, zip, default value is pdf
    #           -sectionids: Filter desired sections
    #           -iterations: Run number or testId in form of test@<testid>@ 
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::exportReport { name args } {
        set tag "body Tester::exportReport $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "exportReport name must be configured"
        }
        
        if { [ catch {
            if { [ info exists _tests($name) ] } {
                set handle $_tests($name)
            } elseif { [ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
            } else {
                error "No test found"
            }
            set cmd "$handle exportReport $args"
            Deputs $cmd
            eval $cmd
        } err ] } {
            Deputs "----- Failed to export $name report: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
        
    #--
    # Name: exportTest - Export test from Bps system
    #--
    # Parameters:
    #       name: Test or test series name to find proper resultid, if no test found in current test, we'll
    #             create new test with this name after we export test successfully, mandatory parameter
    #       args: 
    #           -resultid: The test resultid, if the name of test is not ran in current test, this is a mandatory parameter
    #           -file: file path to local system, mandatory parameter
    #           .................
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::exportTest { name args } {
        set tag "body Tester::exportTest $name $args [info script]"
        Deputs "----- TAG: $tag -----"
    
        if { ![ info exists name ] } {
            error "exportTest name must be configured"
        }
        
        if { [ catch {
            if { [ info exists _tests($name) ] } {
                set handle $_tests($name)
                set testId [ $handle resultId ]
                if { $testId == "" } {
                    error "No test id found for current test, you may run it for a trial"
                }
                set cmd "$_connection exportTest -testid $testId $args"
                Deputs $cmd
                eval $cmd
            } elseif { [ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
                set testId [ $handle resultId ]
                if { $testId == "" } {
                    error "No test id found for current test series, you may run it for a trial"
                }
                set cmd "$_connection exportTest -testid $testId $args"
                Deputs $cmd
                eval $cmd
            } else {
                set cmd "$_connection exportTest $args"
                Deputs $cmd
                eval $cmd
                set cmd "createTest $name -template $name"
                Deputs $cmd
                eval $cmd
            }
        } err ] } {
            Deputs "----- Failed to export $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
       
    #--
    # Name: importTest - Import test from local to Bps system
    #--
    # Parameters:
    #       name: The name save into Bps system, mandatory parameter
    #       args:
    #           -file: File path on local system, we must configure url or file in a invoking
    #           -url: Remote file located, we must configure url or file in a invoking
    #           .........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::importTest { name args } {
        set tag "body Tester::importTest $name $args [info script]"
        Deputs "----- TAG: $tag -----"
    
        if { ![ info exists name ] } {
            error "importTest name must be configured"
        }
        
        if { [ catch {
            set cmd "$_connection importTest $name $args"
            Deputs $cmd
            eval $cmd
        } err ] } {
            Deputs "----- Failed to export $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: run - Run the test
    #--
    # Parameters:
    #       name: Test or test series name, mandatory parameter
    #       args:
    #           -progress: Monitor test progress call back function, default is cbTestProgress
    #           -rtstats: Run-time statistics call back function, default is cbRunTimeStats
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::run { name args } {
        set tag "body Tester::run $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "Run name must be configured"
        }
        
        if { [ catch {
            #set cmd "$handle getAggStats"
            #Deputs $cmd
            #set aggStats [ eval $cmd ]
            if { [ info exists _tests($name) ] } {
                set handle $_tests($name)
                set cmd "$handle run $args"
                Deputs $cmd
                eval $cmd
            } elseif { [ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
                set cmd "$handle run $args"
                Deputs $cmd
                eval $cmd
            }
        } err ] } {
            Deputs "----- Failed to run $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: cancel - Cancel the test
    #--
    # Parameters:
    #       name: Cancel test or test series name, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::cancel { name args } {
        set tag "body Tester::cancel $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "Cancel name must be configured"
        }
        
        if { [ catch {
            if { [ info exists _tests($name) ] } {
                set handle $_tests($name)
                set testId [ $handle resultId ]
                set cmd "$_chassis cancelTest $testId $args"
                Deputs $cmd
                eval $cmd
            } elseif { [ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
                set cmd "$handle cancel $args"
                Deputs $cmd
                eval $cmd
            } else {
                error "No test found to cancel"
            }
        } err ] } {
            Deputs "----- Failed to cancel $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createTest - Create the test
    #--
    # Parameters:
    #       name: The name of test to create, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createTest { name args } {
        set tag "body Tester::createTest $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "createTest name must be configured"
        }
        
        if { [ catch {
            if { ![ info exists _tests($name) ] } {
                set cmd "$_connection createTest -name $name $args"
                Deputs $cmd
                set _tests($name) [ eval $cmd ]
            } 
        } err ] } {
            Deputs "----- Failed to create test $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createTestSeries - Create the test series
    #--
    # Parameters:
    #       name: The name of test series to create, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createTestSeries { name args } {
        set tag "body Tester::createTestSeries $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "createTestSeries name must be configured"
        }
        
        if { [ catch {
            if { ![ info exists _testSeries($name) ] } {
                set cmd "$_connection createTestSeries -name $name $args"
                Deputs $cmd
                set _testSeries($name) [ eval $cmd ]
            } 
        } err ] } {
            Deputs "----- Failed to create test series $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: getRtStats - Return run time test statitistcs
    #--
    # Parameters:
    #       name: Test or test series name, mandatory parameter
    #       args:
    #           -filters: Filter desired results
    # Return:
    #        tcpClientClosed: 5672
    #        tcpServerCloseRate: 0
    #        tcpClientEstablishRate: 0
    #        appAttempted: 18465
    #        ethRxFrameRate: 68.69
    #        tcpAvgCloseTime: 0.107
    #        tcpAvgResponseTime: 0.243
    #        ethTxFrameRate: 68.69
    #        t: 144.463
    #        progress: 100
    #        appSuccessfulRate: 0
    #        tcpAvgSetupTime: 0.31
    #        tcpClientEstablished: 5676
    #        tcpAvgSessionDuration: 273.14
    #        time: 147.59636
    #        udpFlowsConcurrent: 4
    #        tcpServerClosed: 5672
    #        tcpClientCloseRate: 0
    #        sctpFlowsConcurrent: 0
    #        tcpServerEstablishRate: 0
    #        appSuccessful: 18463
    #        ethRxFrames: 236100
    #        tcpAttemptRate: 0
    #        ethTxFrames: 236100
    #        ethRxFrameDataRate: 0.1365
    #        appAttemptedRate: 0
    #        tcpFlowsConcurrent: 4
    #        superFlowsConcurrent: 2
    #        tcpServerEstablished: 5676
    #        ethTxFrameDataRate: 0.1365
    #        tcpAttempted: 5676
    #
    #        return [] if no results
    #--
    body Tester::getRtStats { name args } {
        set tag "body Tester::getRtStats $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        array set rtstats [list] 
        foreach { key value } $args {
            set key [string tolower $key]
            Deputs "Key :$key \tValue :$value"
            switch -exact -- $key {
                -filters {
                    set filters $value
                }
            }
        }
        
        if { ![ info exists name ] } {
            error "getRtStats name must be configured"
        }
        
        if { ![ info exists IXIA::rtStats($name) ] } {
            return [ array get rtstats ] 
        }
        
        if { [ info exists filters ] } {
            foreach stat $filters {
                dict for { key val } $IXIA::rtStats($name) {
                    if { [ string tolower $stat ] == [ string tolower $key ] } {
                        set rtstats($key) $val
                        break
                    }
                }   
            }
        } else {
            return $IXIA::rtStats($name)
        }

        return [ array get rtstats ] 
    }
    
    #--
    # debug puts
    #--
    proc Deputs { value } {
        set timeVal  [ clock format [ clock seconds ] -format %D-%T ]
        set clickVal [ clock clicks ]
        puts "\[<IXIA>TIME:$timeVal\]$value"
        
        if { $IXIA::debug } {
            LogIn -message $value
        }
    }
    
    #--
    # Enable debug puts
    #--
    proc IxdebugOn {} {
        set timeVal  [ clock format [ clock seconds ] -format %Y%m%d_%H_%M ]
        set filedir [file dirname [info script]]
        if { [file exist "$filedir/ixlogfile"] } {
            set IXIA::logfile "$filedir/ixlogfile/$timeVal.txt"
        } elseif { [file exist "$filedir/ixlogfile"] } {
            set IXIA::logfile "$filedir/ixlogfile/$timeVal.txt"
        } else {
            if { [ catch {
                file mkdir "$filedir/ixlogfile"
                set IXIA::logfile "$filedir/ixlogfile/$timeVal.txt"
            } ] } {
                file mkdir "$filedir/ixlogfile"
                set IXIA::logfile "$filedir/ixlogfile/$timeVal.txt"
            }
        }
        
        set IXIA::debug 1
    } 
      
    #--
    # Disable debug puts
    #--
    proc IxdebugOff {} {
        set IXIA::debug 0
    }
}

set currDir [file dirname [info script]]

if { [ catch {
    source [file join $currDir "Logger.tcl"]
} err ] } {
    puts "load package fail...$err"
}

if { [ catch {
    source [file join $currDir "IxiaUtil.tcl"]
} err ] } {
    puts "load package fail...$err"
}

if { [ catch {
    source [file join $currDir "IxiaBpsCallBack.tcl"]
} err ] } {
    puts "load package fail...$err"
}