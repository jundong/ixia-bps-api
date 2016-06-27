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
        protected variable _appProfiles
        protected variable _multiboxTests
        protected variable _multicastTests
        protected variable _neighborhoods
        protected variable _networks
        protected variable _aggStats
        protected variable _rfc2544Tests
        protected variable _resiliencyTests
        protected variable _serverResiliencyTests
        protected variable _sessionLabTests
        protected variable _superflows
        protected variable _tests
        protected variable _testSeries
        protected variable _strikeList
  
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
        public method createAppProfile { name args } {}
        public method createSuperflow { name args } {}
        public method createComponent { testName componentName componentType args } {}
        public method createStrikeList { name args } {}
        
        public method configure { name args } {}
        public method configurePhase { name action index args } {}
        public method configureComponent { testName componentName args } {}
        public method configureNetwork { name action type parameters args } {}
        public method configureSuperflow { name action type parameters args } {}
        public method configureAppProfile { appProfileName superFlowName action args } {}
        public method configurePort { slot port args } {}
        public method configureStrikeList { name action args } {}
        
        public method listElementOptions { networkName type id } {
            set args ""
            if { [ catch {
                if { [info exists _networks($networkName) ] } {
                    set networkHandle $_networks($networkName)
                    set cmd "$networkHandle get $type $id"
                    Deputs $cmd
                    set handle [eval $cmd]
                    set args [$handle configure]
                }
            } err ] } {
                Deputs "No network $networkName found: $err"
                error "No network $networkName found: $err"
            }
            return $args
        }
        
        public method save { name args } {}
        public method delete { name args } {}
        
        public method importTest { name args } {}
        public method exportTest { name args } {}
        public method exportReport { name args } {}
        
        public method startCapture { name } {
            set test [getObjByName $name]
            $test  startPacketTrace
        }
        public method stopCapture { name } {
            set test [getObjByName $name]
            $test  stopPacketTrace
        }
        public method exportCapture { portlist dir direction args } {}
        
        public method getRtStats { name args } {}
        public method getAggStats { name args } {}
        public method getComponentStats { name args } {}
        public method getRtProcess { name } {
            if { [ info exists IXIA::rtProcess($name) ] } {
                return $IXIA::rtProcess($name)
            }
            return null
        }
        
        public method reservePort { portlist args } {}
        public method unreservePort { portlist } {}
        
        public method getChassis {} { return $_chassis }
        public method getConnection {} {
            #return $_connection
            return IXIA::Tester::$_connection
        }
        public method getTest { name } {
            set testHandle ""
            if { [ catch {
                if { [ info exists _tests($name) ] } {
                    set testHandle $_tests($name)
                }
            } err ] } {
                Deputs "No test $name found"
                error "No test $name found"
            }
            return $testHandle
        }
        public method getTestSeries { name } {
            et testSeriesHandle ""
            if { [ catch {
                if { [info exists _testSeries($name) ] } {
                    set testSeriesHandle $_testSeries($name)
                }
            } err ] } {
                Deputs "No test series $name found"
                error "No test series $name found"
            }
            return $testSeriesHandle
        }
        public method getLoadProfile { name } {
            set loadProfileHandle ""
            if { [ catch {
                if { [info exists _loadProfiles($name) ] } {
                    set loadProfileHandle $_loadProfiles($name)
                }
            } err ] } {
                Deputs "No load profile $name found"
                error "No load profile $name found"
            }
            return $loadProfileHandle
        }
        public method getAppProfile { name } {
            set appProfileHandle ""
            if { [ catch {
                if { [info exists _appProfiles($name) ] } {
                    set appProfileHandle $_appProfiles($name)
                }
            } err ] } {
                Deputs "No app profile $name found"
                error "No app profile $name found"
            }
            return $appProfileHandle
        }
        public method getSuperflow { name } {
            set superflowHandle ""
            if { [ catch {
                if { [info exists _superflows($name) ] } {
                    set superflowHandle $_superflows($name)
                }
            } err ] } {
                Deputs "No app profile $name found"
                error "No app profile $name found"
            }
            return $superflowHandle
        }
        public method getComponent { name } {
            set componentHandle ""
            if { [ catch {
                if { [info exists _components($name) ] } {
                    set componentHandle $_components($name)
                }
            } err ] } {
                Deputs "No component $name found"
                error "No component $name found"
            }
            return $componentHandle
        }
        public method getNetwork { name } {
            set networkHandle ""
            if { [ catch {
                if { [info exists _networks($name) ] } {
                    set networkHandle $_networks($name)
                }
            } err ] } {
                Deputs "No network $name found"
                error "No network $name found"
            }
            return $networkHandle
        }
        
        public method getObjByName { name } {
            set tag "body Tester::getObjByName $name[info script]"
            Deputs "----- TAG: $tag -----"
            
            if { ![ info exists name ] } {
                error "getObjByName name must be configured"
            }
            
            set handle ""
            if { [ catch {
                if { [ info exists _tests($name) ] } {
                    set handle $_tests($name)
                } elseif { [ info exists _testSeries($name) ] } {
                    set handle $_testSeries($name)
                } elseif { [ info exists _networks($name) ] } {
                    set handle $_networks($name)
                } elseif { [ info exists _loadProfiles($name) ] } {
                    set handle $_loadProfiles($name)
                } elseif { [ info exists _components($name) ] } {
                    set handle $_components($name)
                } elseif { [ info exists _strikeList($name) ] } {
                    set handle $_strikeList($name)
                } else {
                    error "No object found with $name"
                }
            } err ] } {
                Deputs $err
            }
            return $handle
        }
    }

    #--
    # Name: configurePort - Configure Ports
    #--
    # Parameters: 
    #       portlist: Port list to configure, eg. [list {1 0} {1 1}]
    #       args:
    #               -auto: Wether working with auto nigotiation mode, default value is true
    #               -speed: Port speed, default value is true
    #               -fullduplex: Wether working with full duplex mode, default value is true
    #           ..........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configurePort { portList args } {
        set tag "body Tester::configurePort $portList $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { [ llength $portList ] == 0 } {
            error "configurePort portList must be specified"
        }
        
        set slot ""
        set port ""
        if { [ catch {
            foreach sp $portList {
                set slot [lindex $sp 0]
                set port [lindex $sp 1]
                set cmd "$_chassis configurePort $slot $port $args"
                Deputs $cmd
                eval $cmd
            }
        } err ] } {
            Deputs "----- Failed to configurePort port $slot/$port: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
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
            if { [ info exists _tests($name) ] } {
                set handle $_tests($name)
            } elseif { [ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
            } elseif { [ info exists _networks($name) ] } {
                set handle $_networks($name)
            } elseif { [ info exists _loadProfiles($name) ] } {
                set handle $_loadProfiles($name)
            } elseif { [ info exists _components($name) ] } {
                set handle $_components($name)
            } elseif { [ info exists _strikeList($name) ] } {
                set handle $_strikeList($name)
            }
            
            if { $handle != "" } {
                set cmd "$handle configure $args"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "No object found with name: $name"
            }
        } err ] } {
            Deputs "----- Failed to configure object $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: configureComponent - Configure component object
    #--
    # Parameters:
    #       testName: The name of test, mandatory parameter
    #       componentName: The name of component, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configureComponent { testName componentName args } {
        set tag "body Tester::configureComponent $testName $componentName $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists testName ] } {
            error "configureComponent testName must be configured"
        }
        
        if { ![ info exists componentName ] } {
            error "configureComponent componentName must be configured"
        }
        
        set handle ""
        if { [ catch {
            if { [ info exists _tests($testName) ] } {
                set handle $_tests($testName)
            }
            
            if { $handle != "" } {
                set component_handle ""
                dict for { key value } [ $handle getComponents ] {
                    if { $key != "aggstats" } {
                        if { [ string tolower [ $value cget -name ] ] == [ string tolower $componentName ] ||
                            [ string tolower [ $value cget -name ] ] == [ string tolower ::$componentName ]} {
                            Deputs "$value"
                            set component_handle $value
                            set _components($componentName) "$value"
                            break
                        }
                    }
                }
                if { $component_handle != "" } {
                    set cmd "$component_handle configure $args"
                    Deputs $cmd
                    eval $cmd
                } else {
                    error "No component object found with name: $componentName"
                }
            } else {
                error "No test object found with name: $testName"
            }
        } err ] } {
            Deputs "----- Failed to configure $componentName: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: configureAppProfile - Configure component object
    #--
    # Parameters:
    #       appProfileName: The name of application profile, mandatory parameter
    #       superFlowName: The name of super flow, mandatory parameter
    #       action: The action to configure the super flow in app profile, valid value are add, modify and remove, mandatory parameter 
    #       args: 
    #           -weight: Super flow weight
    #           -seed: Random seed
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configureAppProfile { appProfileName superFlowName action args } {
        set tag "body Tester::configureAppProfile $appProfileName $superFlowName $action $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists appProfileName ] } {
            error "configureAppProfile appProfileName must be configured"
        }
        
        if { ![ info exists superFlowName ] } {
            error "configureAppProfile superFlowName must be configured"
        }

        if { ![ info exists action ] } {
            error "configureAppProfile action must be configured"
        }
        
        foreach { key value } $args {
            set key [string tolower $key]
            Deputs "Key :$key \tValue :$value"
            switch -exact -- $key {
                -weight {
                    set weight $value
                }
                -seed {
                    set seed $value
                }
            }
        }
        
        if { [ catch {
            if { [ info exists _appProfiles($appProfileName) ] } {
                set handle $_appProfiles($appProfileName)
                set cmd ""
                if { [ string tolower $action ] == "add" } {
                    if { [ info exists weight ] } {
                        if { [ info exists seed ] } {
                            set cmd "$handle addSuperflow $superFlowName $weight $seed"
                        } else {
                            set cmd "$handle addSuperflow $superFlowName $weight"
                        }
                    } else {
                        if { [ info exists seed ] } {
                            set cmd "$handle addSuperflow $superFlowName $seed"
                        } else {
                            set cmd "$handle addSuperflow $superFlowName"
                        }
                    }
                } elseif { [ string tolower $action ] == "modify" } {
                    if { [ info exists weight ] } {
                        if { [ info exists seed ] } {
                            set cmd "$handle modifySuperflow $superFlowName $weight $seed"
                        } else {
                            set cmd "$handle modifySuperflow $superFlowName $weight"
                        }
                    } else {
                        if { [ info exists seed ] } {
                            set cmd "$handle modifySuperflow $superFlowName $seed"
                        } 
                    }
                } elseif { [ string tolower $action ] == "remove" } {
                    set cmd "$handle removeSuperflow $superFlowName"
                } else {
                    Deputs "Unknown action $action found"
                    error "Unknown action $action found"
                }
                Deputs $cmd
                eval $cmd
                
                #set cmd "$handle save -force"
                #Deputs $cmd
                #eval $cmd
            } else {
                Deputs "No app profile $appProfileName found"
                error "No app profile $appProfileName found"
            }
        } err ] } {
            Deputs "----- Failed to configure app profile $appProfileName: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: configureSuperflow - Configure super flow
    #--
    # Parameters:
    #       name: The name of super flow, mandatory parameter
    #       action: The action for super flow resources, valid values are add, modify, remove and unset, mandatory parameter
    #       type: The configure resource type, valid values are action, maction(Match action), flow and host, mandatory parameter
    #       parameters: Mandatory parameters for action operation, eg [list flowid source name], mandatory parameter
    #       args: Args for action operation
    #           For add:
    #               
    #           For modify:
    #
    #           For remove:
    #
    #           For unset:
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configureSuperflow { name action type parameters args } {
        set tag "body Tester::configureSuperflow $name $action $type $parameters $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "configureSuperflow name must be configured"
        }
        
        if { ![ info exists action ] } {
            error "configureSuperflow action must be configured"
        }

        if { ![ info exists type ] } {
            error "configureSuperflow type must be configured"
        }
        
        if { ![ info exists parameters ] } {
            error "configureSuperflow parameters must be configured"
        }
        
        if { [ catch {
            if { [ info exists _superflows($name) ] } {
                set handle $_superflows($name)
                set cmd ""
                if { [ string tolower $action ] == "add" } {
                    if { [ string tolower $type ] == "action" } {
                        set cmd "$handle addAction [ lindex $parameters 0 ] [ lindex $parameters 1 ] [ lindex $parameters 2 ] $args"
                    } elseif { [ string tolower $type ] == "maction" } {
                        set cmd "$handle addMatchAction [ lindex $parameters 0 ] [ lindex $parameters 1 ] [ lindex $parameters 2 ] [ lindex $parameters 3 ] [ lindex $parameters 4 ] $args"
                    } elseif { [ string tolower $type ] == "flow" } {
                        set cmd "$handle addFlow [ lindex $parameters 0 ] [ lindex $parameters 1 ] [ lindex $parameters 2 ] $args"
                    } elseif { [ string tolower $type ] == "host" } {
                        set cmd "$handle addHost [ lindex $parameters 0 ] [ lindex $parameters 1 ] [ lindex $parameters 2 ] $args"
                    } else {
                        Deputs "Unknown resource type $type"
                        error "Unknown resource type $type"
                    }
                } elseif { [ string tolower $action ] == "modify" } {
                    if { [ string tolower $type ] == "action" } {
                        set cmd "$handle modifyAction [ lindex $parameters 0 ] $args"
                    } elseif { [ string tolower $type ] == "maction" } {
                        set cmd "$handle modifyMatchAction [ lindex $parameters 0 ] [ lindex $parameters 1 ] [ lindex $parameters 2 ] $args"
                    } elseif { [ string tolower $type ] == "flow" } {
                        set cmd "$handle modifyFlow [ lindex $parameters 0 ] $args"
                    } elseif { [ string tolower $type ] == "host" } {
                        set cmd "$handle modifyHost [ lindex $parameters 0 ] $args"
                    } else {
                        Deputs "Unknown resource type $type"
                        error "Unknown resource type $type"
                    }
                } elseif { [ string tolower $action ] == "remove" } {
                    if { [ string tolower $type ] == "action" } {
                        set cmd "$handle removeAction [ lindex $parameters 0 ] $args"
                    } elseif { [ string tolower $type ] == "maction" } {
                        set cmd "$handle removeMatchAction [ lindex $parameters 0 ] [ lindex $parameters 1 ] [ lindex $parameters 2 ] $args"
                    } elseif { [ string tolower $type ] == "flow" } {
                        set cmd "$handle removeFlow [ lindex $parameters 0 ] $args"
                    } elseif { [ string tolower $type ] == "host" } {
                        set cmd "$handle removeHost [ lindex $parameters 0 ] $args"
                    } else {
                        Deputs "Unknown resource type $type"
                        error "Unknown resource type $type"
                    }
                } elseif { [ string tolower $action ] == "unset" } {
                    if { [ string tolower $type ] == "action" } {
                        set cmd "$handle unsetActionParameter [ lindex $parameters 0 ] $args"
                    } elseif { [ string tolower $type ] == "maction" } {
                        set cmd "$handle unsetMatchActionParameter [ lindex $parameters 0 ] [ lindex $parameters 1 ] [ lindex $parameters 2 ] $args"
                    } elseif { [ string tolower $type ] == "flow" } {
                        set cmd "$handle unsetFlowParameter [ lindex $parameters 0 ] $args"
                    } else {
                        Deputs "Unknown resource type $type"
                        error "Unknown resource type $type"
                    }
                } else {
                    Deputs "Unknown action $action"
                }
                
                Deputs $cmd
                eval $cmd
                
                #set cmd "$handle save -force"
                #Deputs $cmd
                #eval $cmd
            } else {
                Deputs "No super flow $name found"
                error "No super flow $name found"
            }
        } err ] } {
            Deputs "----- Failed to configure superflow $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: configureNetwork - Configure network
    #--
    # Parameters:
    #       name: The name of network, mandatory parameter
    #       action: The action for super flow resources, valid values are config, add and remove, mandatory parameter
    #       type: The configure resource type, valid values are path, interface, vlan, ip_dhcp_server, ipsec_config..., mandatory parameter
    #       parameters: Mandatory parameters for action operation, eg [list flowid source name], mandatory parameter
    #       args: Args for action operation
    #           For add:
    #               
    #           For remove:
    #
    #           For config:
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configureNetwork { name action type parameters args } {
        set tag "body Tester::configureNetwork $name $action $type $parameters $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "configureNetwork name must be configured"
        }
        
        if { ![ info exists action ] } {
            error "configureNetwork action must be configured"
        }

        if { ![ info exists type ] } {
            error "configureNetwork type must be configured"
        }
        
        if { ![ info exists parameters ] } {
            error "configureNetwork parameters must be configured"
        }
        
        if { [ catch {
            if { [ info exists _networks($name) ] } {
                set handle $_networks($name)
                set cmd ""
                if { [ string tolower $action ] == "add" } {
                    if { [ string tolower $type ] == "path" } {
                        set cmd "$handle addPath [ lindex $parameters 0 ] [ lindex $parameters 1 ]"
                    } else {
                        set cmd "$handle add $type $args"
                    }
                } elseif { [ string tolower $action ] == "config" } {
                    foreach res $parameters {
                        set element [ $handle get $type $res ]
                        set cmd "$element configure $args"
                        
                        Deputs $cmd
                        eval $cmd
                        
                        set cmd "$handle commit"
                        Deputs $cmd
                        eval $cmd
                    }
                } elseif { [ string tolower $action ] == "remove" } {
                    if { [ string tolower $type ] == "path" } {
                        set cmd "$handle removePath [ lindex $parameters 0 ] [ lindex $parameters 1 ]"
                    } else {
                        set cmd "$handle remove $type [ lindex $parameters 0 ]"
                    }
                } else {
                    Deputs "Unknown action $action"
                }
                
                Deputs $cmd
                eval $cmd
                
                set cmd "$handle commit"
                Deputs $cmd
                eval $cmd
                
                #set cmd "$handle save -force"
                #Deputs $cmd
                #eval $cmd
            } else {
                Deputs "No network $name found"
                error "No network $name found"
            }
        } err ] } {
            Deputs "----- Failed to configure network $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: configurePhase - Configure Phase
    #--
    # Parameters:
    #       name: The name of load profile, mandatory parameter
    #       action: The atction for load phase, valid values are add, modify and remove, mandatory parameter
    #       index: The index of load phase, mandatory parameter
    #       args:
    #           duration 1
    #           sessions.max 1
    #           sessions.maxPerSecond 1
    #           rateDist.min 1
    #           rateDist.unit mbps
    #           rateDist.scope per_if
    #           rampDist.downBehavior full, valid values are full, half and rst
    #           rampDist.steadyBehavior cycle, valid values are cycle and hold 
    #           rampDist.upBehavior full, valid values are full, full + data,
    #                   full + data + close, half, data flood and syn
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configurePhase { name action index args } {
        set tag "body Tester::configurePhase $name $action $index $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "configurePhase name must be configured"
        }

        if { ![ info exists action ] } {
            error "configurePhase action must be configured"
        }
        
        if { ![ info exists index ] } {
            error "configurePhase index must be configured"
        }
        
        if { [ catch {
            if { [ info exists _loadProfiles($name) ] } {
                set handle $_loadProfiles($name)
                set cmd ""
                if { [string tolower $action ] == "add" } {
                    set cmd "$handle addPhase $index $args"
                } elseif { [string tolower $action ] == "modify" } {
                    set cmd "$handle modifyPhase $index $args"
                } elseif { [string tolower $action ] == "remove" } {
                    set cmd "$handle removePhase $index"
                } else {
                    Deputs "Wrong action $action, action must be one of add, modify or remove"
                    error "Wrong action $action, action must be one of add, modify or remove"
                }
                Deputs $cmd
                eval $cmd
                #set cmd "$handle save -force"
                #Deputs $cmd
                #eval $cmd
            } else {
                Deputs "No load profile $name found"
            }
        } err ] } {
            Deputs "----- Failed to configure load profile $name: $err -----"
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
            if { [ info exists _loadProfiles($name) ] } {
                set handle $_loadProfiles($name)
            } elseif { [ info exists _tests($name) ] } {
                set handle $_tests($name)
            } elseif { [ info exists _testSeries($name) ] } {
                set handle $_testSeries($name)
            } elseif { [ info exists _networks($name) ] } {
                set handle $_networks($name)
            } elseif { [ info exists _appProfiles($name) ] } {
                set handle $_appProfiles($name)
            } elseif { [ info exists _strikeList($name) ] } {
                set handle $_strikeList($name)
            }
            
            if { $handle != "" } {
                set cmd "$handle save $args"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "No resource with name: $name"
            }
        } err ] } {
            Deputs "----- Failed to save resource $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: delete - Delete object
    #--
    # Parameters:
    #       name: The name of object to delete, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::delete { name args } {
        set tag "body Tester::delete $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "save name must be configured"
        }
        
        set cmd ""
        if { [ catch {
            if { [ info exists _loadProfiles($name) ] } {
                set cmd "$_connection deleteLoadProfile $name $args"
                unset _loadProfiles($name)
            } elseif { [ info exists _tests($name) ] } {
                set cmd "$_connection deleteTest $name $args"
                unset _tests($name)
            } elseif { [ info exists _testSeries($name) ] } {
                set cmd "$_connection deleteTestSeries $name $args"
                unset _testSeries($name)
            } elseif { [ info exists _networks($name) ] } {
                set cmd "$_connection deleteNeighborhood $name $args"
                unset _networks($name)
            } elseif { [ info exists _appProfiles($name) ] } {
                set cmd "$_connection deleteAppProfile $name $args"
                unset _appProfiles($name)
            } elseif { [ info exists _components($name) ] } {
                set cmd "itcl::delete object $_components($name)"
                unset _components($name)
            } elseif { [ info exists _superflows($name) ] } {
                set cmd "$_connection deleteSuperflow $name $args"
                unset _superflows($name)
            } elseif { [ info exists _strikeList($name) ] } {
                set cmd "$_connection deleteStrikeList $name $args"
                unset _strikeList($name)
            }
            
            if { $cmd != "" } {
                Deputs $cmd
                eval $cmd
                
                #set cmd "$_connection save -force"
                #Deputs $cmd
                #eval $cmd
            } else {
                Deputs "No resource with name: $name"
            }
        } err ] } {
            Deputs "----- Failed to delete resource $name: $err -----"
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
                Deputs $_loadProfiles($name)
                
                set cmd "$_loadProfiles($name) configure -name $name"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "Load profile $name has already exists"
            }
        } err ] } {
            Deputs "----- Failed to create load profile $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createNetwork - Create network
    #--
    # Parameters:
    #       name: The name of network neighorbood to create, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createNetwork { name args } {
        set tag "body Tester::createNetwork $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "createNetwork name must be configured"
        }
        
        if { [ catch {
            if { ![ info exists _networks($name) ] } {
                set cmd "$_connection createNetwork -name $name $args"
                Deputs $cmd
                set _networks($name) [ eval $cmd ]
                
                set cmd "$_networks($name) configure -name $name"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "Nework neihorhood $name has already exists"
            }
        } err ] } {
            Deputs "----- Failed to create network neihorhood $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createStrikeList - Create Strike List
    #--
    # Parameters:
    #       name: The name of strike list to create, mandatory parameter
    #       args:
    #           ........
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createStrikeList { name args } {
        set tag "body Tester::createStrikeList $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "createStrikeList name must be configured"
        }
        
        if { [ catch {
            if { ![ info exists _strikeList($name) ] } {
                set cmd "$_connection createStrikeList -name $name $args"
                Deputs $cmd
                set _strikeList($name) [ eval $cmd ]
                
                set cmd "$_strikeList($name) configure -name $name"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "Strike list $name has already exists"
            }
        } err ] } {
            Deputs "----- Failed to create Strike List $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: configureStrikeList - Configure Strike List
    #--
    # Parameters:
    #       name: The name of network, mandatory parameter
    #       action: The action for strike list resources, valid values are config, add and remove, mandatory parameter
    #       args: Args for action operation
    #           For add:
    #               
    #           For remove:
    #
    #           For config:
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::configureStrikeList { name action args } {
        set tag "body Tester::configureStrikeList $name $action $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "configureStrikeList name must be configured"
        }
        
        if { ![ info exists action ] } {
            error "configureStrikeList action must be configured"
        }

        if { [ catch {
            if { [ info exists _strikeList($name) ] } {
                set handle $_strikeList($name)
                set cmd ""
                if { [ string tolower $action ] == "add" } {
                    set cmd "$handle add $args"
                } elseif { [ string tolower $action ] == "config" } {
                    set cmd "$handle configure $args"
                } elseif { [ string tolower $action ] == "remove" } {
                    set cmd "$handle remove $args"
                } else {
                    Deputs "Unknown action $action"
                }
                
                Deputs $cmd
                eval $cmd
                
                #set cmd "$handle save -force"
                #Deputs $cmd
                #eval $cmd
            } else {
                Deputs "No strike list $name found"
                error "No strike list $name found"
            }
        } err ] } {
            Deputs "----- Failed to configure strike list $name: $err -----"
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
    # Name: exportCapture - Export test capture
    #--
    # Parameters:
    #       portlist: Port list to export capture, eg. [list {1 0} {1 1}]
    #       dir: Directory to put export capture
    #       direction: Packets direction in capture, eg. tx, rx or both
    #       args:
    #           -compress: Whether compress the capture data
    #           -txsnaplen: Truncates transmitted packets
    #                       that are larger than txsnaplen bytes
    #           -rxsnaplen: Truncates received packets
    #                       that are larger than rxsnaplen bytes
    #           -txfilter: Filter packets from specified host, eg. "host 10.1.0.254"
    #           -rxfilter: Filter packets from specified host, eg. "host 10.1.0.254"
    #           ................. 
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::exportCapture { portlist dir direction args } {
        set tag "body Tester::exportCapture $portlist $dir $direction $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists portlist ] } {
            error "exportCapture portlist must be configured"
        }
        
        if { ![ info exists dir ] } {
            error "exportCapture dir must be configured"
        } else {
            if { ![file exists $dir ] } {
                file mkdir $dir
            }
        }
        
        if { ![ info exists direction ] } {
            error "exportCapture direction must be configured"
        }
        
        set slot ""
        set port ""
        if { [ catch {
            foreach sp $portlist {
                set slot [lindex $sp 0]
                set port [lindex $sp 1]
                set cmd "$_chassis exportPacketTrace $dir $args $slot $port $direction"
                Deputs $cmd
                eval $cmd
            }
        } err ] } {
            Deputs "----- Failed to export capture from $slot/$port: $err -----"
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
                set cmd "$_connection exportTest $name $args"
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
            
            #set cmd "createTest $name -template $name"
            #Deputs $cmd
            #eval $cmd
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
                #-allowMalware£ºConfirm that malware should be allowed in this test
                #-async: Runs the test in the background and executes the command specified
                #-flowexceptions: Identifies the script to run with flow exception notifications
                #-group: Identifies the interface group to be used
                #-progress: Allows you to monitor the progress of the test
                #-rtstats: Calls the -rtstats attribute when there are new Real-Time statistics available

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
                #set testId [ $handle resultId ]
                #set cmd "$_chassis cancelTest $testId $args"
                set cmd "$handle cancel $args"
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
    #           -template: Canned test as a template
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

                set cmd "$_tests($name) configure -name $name"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "Test $name has already exists"
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
    #           -template: Canned test series as a template
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
                
                set cmd "$_testSeries($name) configure -name $name"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "Test series $name has already exists"
            }
        } err ] } {
            Deputs "----- Failed to create test series $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createAppProfile - Create app profile
    #--
    # Parameters:
    #       name: The name of app profile to create, mandatory parameter
    #       args:
    #           -template: Canned app profile as a template
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createAppProfile { name args } {
        set tag "body Tester::createAppProfile $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "createAppProfile name must be configured"
        }
        
        if { [ catch {
            if { ![ info exists _appProfiles($name) ] } {
                set cmd "$_connection createAppProfile -name $name $args"
                Deputs $cmd
                set _appProfiles($name) [ eval $cmd ]
                
                set cmd "$_appProfiles($name) configure -name $name"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "App profile $name has already exists"
            }
        } err ] } {
            Deputs "----- Failed to create app profile $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createSuperflow - Create super flow
    #--
    # Parameters:
    #       name: The name of super flow to create, mandatory parameter
    #       args:
    #           -template: Canned app profile as a template
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createSuperflow { name args } {
        set tag "body Tester::createSuperflow $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "createSuperflow name must be configured"
        }
        
        if { [ catch {
            if { ![ info exists _superflows($name) ] } {
                set cmd "$_connection createSuperflow -name $name $args"
                Deputs $cmd
                set _superflows($name) [ eval $cmd ]
                
                set cmd "$_superflows($name) configure -name $name"
                Deputs $cmd
                eval $cmd
            } else {
                Deputs "Super flow $name has already exists"
            }
        } err ] } {
            Deputs "----- Failed to create super flow $name: $err -----"
            return [GetErrorReturnHeader $err]
        }
        return [GetStandardReturnHeader]
    }
    
    #--
    # Name: createComponent - Create component for a test
    #--
    # Parameters:
    #       testName: The name of test, mandatory parameter
    #       componentName: The name of component to create, mandatory parameter
    #       componentType: The type of component, mandatory parameter
    #       args:
    # Return:
    #        0 if got success
    #        raise error if failed
    #--
    body Tester::createComponent { testName componentName componentType args } {
        set tag "body Tester::createComponent $testName $componentName $componentType $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists testName ] } {
            error "createComponent testName must be configured"
        }
        
        if { ![ info exists componentName ] } {
            error "createComponent componentName must be configured"
        }
        
        if { ![ info exists componentType ] } {
            error "createComponent componentType must be configured"
        }
        
        if { [ catch {
            if { [ info exists _tests($testName) ] } {
                set handle $_tests($testName)
                set cmd "$handle createComponent $componentType $componentName $args"
                Deputs $cmd
                eval $cmd
                
                dict for { key value } [ $handle getComponents ] {
                    if { $key != "aggstats" } {
                        if { [ string tolower [ $value cget -name ] ] == [ string tolower $componentName ] ||
                            [ string tolower [ $value cget -name ] ] == [ string tolower ::$componentName ]} {
                            Deputs "$value"
                            set _components($componentName) "$value"
                            break
                        }
                    }
                }
                
                #set cmd "$handle save -force"
                #Deputs $cmd
                #eval $cmd
            } else {
                Deputs "No test $testName found"
            }
        } err ] } {
            Deputs "----- Failed to create component $componentName: $err -----"
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
            #tcpClientClosed: 5672
            #tcpServerCloseRate: 0
            #tcpClientEstablishRate: 0
            #appAttempted: 18465
            #ethRxFrameRate: 68.69
            #tcpAvgCloseTime: 0.107
            #tcpAvgResponseTime: 0.243
            #ethTxFrameRate: 68.69
            #t: 144.463
            #progress: 100
            #appSuccessfulRate: 0
            #tcpAvgSetupTime: 0.31
            #tcpClientEstablished: 5676
            #tcpAvgSessionDuration: 273.14
            #time: 147.59636
            #udpFlowsConcurrent: 4
            #tcpServerClosed: 5672
            #tcpClientCloseRate: 0
            #sctpFlowsConcurrent: 0
            #tcpServerEstablishRate: 0
            #appSuccessful: 18463
            #ethRxFrames: 236100
            #tcpAttemptRate: 0
            #ethTxFrames: 236100
            #ethRxFrameDataRate: 0.1365
            #appAttemptedRate: 0
            #tcpFlowsConcurrent: 4
            #superFlowsConcurrent: 2
            #tcpServerEstablished: 5676
            #ethTxFrameDataRate: 0.1365
            #tcpAttempted: 5676
    #
    #        return [] if no results
    #--
    body Tester::getRtStats { name args } {
        set tag "body Tester::getRtStats $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        array set stats [list] 
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
            return [ array get stats ] 
        }
        
        if { [ info exists filters ] } {
            foreach stat $filters {
                dict for { key val } $IXIA::rtStats($name) {
                    if { [ string tolower $stat ] == [ string tolower $key ] } {
                        set stats($key) $val
                        break
                    }
                }   
            }
        } else {
            return $IXIA::rtStats($name)
        }

        return [ array get stats ] 
    }
    
    #--
    # Name: getAggStats - Return aggregate test statitistcs
    #--
    # Parameters:
    #       name: Test name or component name
    #       args:
    #           -filters: Filter desired results
    # Return:
            #cpu_usage: CPU Usage
            #ethAlignmentErrors: Ethernet alignment errors
            #ethDropEvents: Ethernet drop events
            #ethFCSErrors: Ethernet FCS errors
            #ethOversizedFrames: Ethernet oversize frames
            #ethRxErrors: Ethernet receive errors
            #ethRxFrameData: Ethernet bytes received. This includes L7
            #                and all packet overhead, including L2,
            #                L3, L4 headers, ethernet CRC, and interpacket
            #                gap (20 bytes per frame).
            #ethRxFrameDataRate: Ethernet receive rate. This includes L7
            #                and all packet overhead, including L2,
            #                L3, L4 headers, ethernet CRC, and interpacket
            #                gap (20 bytes per frame)
            #ethRxFrameRate: Ethernet frame receive rate
            #ethRxFrames: Ethernet frames received
            #ethRxPauseFrames: Ethernet pause frames received
            #ethTotalErrors: Total Errors
            #ethTxErrors: Ethernet transmit errors
            #ethTxFrameData: Ethernet bytes transmit. This includes L7
            #                and all packet overhead, including L2,
            #                L3, L4 headers, ethernet CRC, and interpacket
            #                gap (20 bytes per frame).
            #ethTxFrameDataRate: Ethernet transmit rate. This includes L7
            #                and all packet overhead, including L2,
            #                L3, L4 headers, ethernet CRC, and interpacket
            #                gap (20 bytes per frame).
            #ethTxFrameRate: Ethernet frame transmit rate
            #ethTxFrames: Ethernet frames transmitted
            #ethTxPauseFrames: Ethernet pause frames transmitted
            #ethUndersizedFrames: Ethernet undersize frames
            #linux mem_free_kb: Free memory on the System Controller
            #mem_total_kb: Total memory on the System Controller
            #mem_used_kb: Used memory
            #mount percent_used: The percent of disk spaced used on the disk partition
            #superFlowRate: Super Flow rate
            #superFlows: Aggregate Super Flows
            #superFlowsConcurrent: Concurrent Super Flows
            #tcpFlowRate: TCP Flow rate
            #tcpFlows: Aggregate TCP Flows
            #tcpFlowsConcurrent: Concurrent TCP Flows
            #timestamp: The time that the datapoint was taken
            #                    (refers to the rest of the data that comes
            #                    with it)
            #udpFlowRate: UDP Flow rate
            #udpFlows: Aggregate UDP Flows
            #udpFlowsConcurrent: Concurrent UDP Flows
    #
    #        return [] if no results
    #--
    body Tester::getAggStats { name args } {
        set tag "body Tester::getAggStats $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "getAggStats name must be specified"
        }
        
        set handle ""
        if { [ info exists _aggStats($name) ] } {
            set handle $_aggStats($name)
        } elseif { [ info exists _tests($name) ] } {
            if { [ info exists _tests($name) ] } {
                set _aggStats($name) [ $_tests($name) getAggStats ]
                set handle $_aggStats($name)
            }
        } else {
            Deputs "No test or component $name found"
            error "No test or component $name found"
        }
        
        array set stats [list] 
        foreach { key value } $args {
            set key [string tolower $key]
            Deputs "Key :$key \tValue :$value"
            switch -exact -- $key {
                -filters {
                    set filters $value
                }
            }
        }
        
        if { [ catch {
            set aggResults [ $handle result ]
            if { [ info exists filters ] } {
                foreach stat $filters {
                    foreach key [ $aggResults values ] {
                        if { [ string tolower $stat ] == [ string tolower $key ] } {
                            set stats($key) [ $aggResults get $key ]
                            break
                        }
                    }   
                }
            } else {
                foreach key [ $aggResults values ] {
                    set stats($key) [ $aggResults get $key ]
                }  
            }
        } err ] } {
            Deputs "----- No results found for $name: $err -----"
        }
        
        return [ array get stats ]
    }
     
    body Tester::getComponentStats { name args } {
        set tag "body Tester::getComponentStats $name $args [info script]"
        Deputs "----- TAG: $tag -----"
        
        if { ![ info exists name ] } {
            error "getComponentStats name must be specified"
        }
        
        array set stats [list] 
        foreach { key value } $args {
            set key [string tolower $key]
            Deputs "Key :$key \tValue :$value"
            switch -exact -- $key {
                -filters {
                    set filters $value
                }
            }
        }
        
        if { [ catch {
            set handle ""
            if { [ info exists _componentStats($name) ] } {
                set handle $_componentStats($name)
            } else {
                foreach { testName testHanle } [ array get _tests ] {
                    dict for { component componentHandle } [ $testHanle getComponents ] {
                        if { $component != "aggstats" } {
                            if { [ string tolower [ $componentHandle cget -name ] ] == [ string tolower $name ] } {
                                set _componentsStats($name) $componentHandle
                                set handle $_componentsStats($name)
                                break
                            }
                        }
                    }
                }
            }
            
            set aggResults [ $handle result ]
            if { [ info exists filters ] } {
                foreach stat $filters {
                    foreach key [ $aggResults values ] {
                        if { [ string tolower $stat ] == [ string tolower $key ] } {
                            set stats($key) [ $aggResults get $key ]
                            break
                        }
                    }   
                }
            } else {
                foreach key [ $aggResults values ] {
                    set stats($key) [ $aggResults get $key ]
                }  
            }
            
            itcl::delete object $aggResults
        } err ] } {
            Deputs "----- No results found for $name: $err -----"
        }
        
        return [ array get stats ]
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