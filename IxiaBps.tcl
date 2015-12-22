package provide IxBps  1.0

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
    package require Itcl
    
    variable debug   0
    variable logfile ""
    
    class BpsObject {
        public variable handle
        
        #--
        # Name: save - Construct method for BpsConnection
        #--
        # Parameters:
        #       args:
        #           -name: The name of the object is saved to, default is using object current name
        #           -force: Wether force to save the object and overwrite exist one, default is true
        #           -file: Abusolute path to save the object to a file
        # Return:
        #        true if got success
        #        raise error if failed
        #--
        method save { { args "" } } {
            set tag "method BpsObject::save $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -name {
                        set name $value
                    }
                    -file {
                        set file $value
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                }
            }
            
            if { ![ info exists name ] } {
                set name [ $handle cget -name ]
            }
            
            if { ![ info exists force ] } {
                set force true
            }
            
            if { [ catch {
                if { [ info exists file ] } {
                    $handle save -name $name -force $force -file $file
                } else {
                    $handle save -name $name -force $force
                }
                
                Deputs "----- Save object done -----"
                return [GetStandardReturnHeader]
            } err ] } {
                set tag "----- Failed to save object£º$err -----"
                Deputs $tag
                error "$tag"
            }
            

            return [ GetStandardReturnHeader ]
        }
    }

    class BpsConnection {
        inherit BpsObject
        
        public variable chas  ""
        
        #--
        # Name: constructor - Construct method for BpsConnection
        #--
        # Parameters: 
        #       host: The management IP address for the BPS system
        #       username: User account
        #       password: User account password
        #       args:
        #               -onclose: Determins what a script does once
        #                         it finishes running, default function is onClose
        #               -shortcuts: Whether use shortcuts commands for test components, default value is true
        #               -portlist: Port list to reserve, eg. [list {1 0} {1 1}]
        # Return:
        #        true if got success
        #        raise error if failed
        #--
        method constructor { host username password { args "" } } {
            set tag "BpsConnection::constructor $host $username $password $args [info script]"
            Deputs "----- TAG: $tag -----"

            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -onclose {
                        set onclose $value
                    }
                    -shortcuts {
                        set shortcuts BoolTrans($value)
                    }
                }
            }
            
            if { ![ info exists onclose ] } {
                set onclose cbSessionClose
            }
            
            if { ![ info exists shortcuts ] } {
                set shortcuts true
            }
            
            if { [ catch {
                set handle [bps::connect $host $username $password -onclose $onclose -shortcuts $shortcuts]
                set chas [$conn getChassis]
                
                $chas configure -onlink cbPortLinkChanged -onreserve cbPortReserved -onstate cbPortStateChanged
                
                Deputs "----- Connect to system done -----"
                return [GetStandardReturnHeader]
            } err ] } {
                set tag "----- Failed to connect to system£º$err -----"
                Deputs $tag
                error "$tag"
            }
        }
        
        #--
        # Name: reservePort - Reserve Ports
        #--
        # Parameters: 
        #       portlist: Port list to reserve, eg. [list {1 0} {1 1}]
        #       args:
        #               -group: Group ID, default value is 1
        #               -force: Wehter force to reserve port, default value is true
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method reservePort { portList { args "" } } {
            set tag "BpsConnection::reservePort $portList $args [info script]"
            Deputs "----- TAG: $tag -----"

            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -group {
                        set onclose $value
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                }
            }
            
            if { ![ info exists group ] } {
                set group 1
            }
            
            if { ![ info exists force ] } {
                set force true
            }
            
            set slot ""
            set port ""
            if { [ catch {
                foreach sp $portList {
                    set slot [lindex $sp 0]
                    set port [lindex $sp 1]
                    $chas reservePort $slot $port -group $group -force $force
                }
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to reserve port $slot/$port -----"
                return [GetErrorReturnHeader $err]
            }
        }
        
        #--
        # Name: unreservePort - UnReserve Ports
        #--
        # Parameters: 
        #       portlist: Port list to UnReserve, eg. [list {1 0} {1 1}]
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method unreservePort { portList } {
            set tag "BpsConnection::unreservePort $portList [info script]"
            Deputs "----- TAG: $tag -----"
            
            set slot ""
            set port ""
            if { [ catch {
                foreach sp $portList {
                    set slot [lindex $sp 0]
                    set port [lindex $sp 1]
                    $chas unreservePort $slot $port
                }
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to unreserve port $slot/$port -----"
                return [GetErrorReturnHeader $err]
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
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method configurePort { portList { args "" } } {
            set tag "BpsConnection::configurePort $portList $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -auto {
                        set auto BoolTrans($value)
                    }
                    -speed {
                        set speed $value
                    }
                    -fullduplex {
                        set fullduplex BoolTrans($value)
                    }
                }
            }
            
            if { ![ info exists auto ] } {
                set auto true
            }
            
            if { ![ info exists fullduplex ] } {
                set fullduplex true
            }
            
            if { ![ info exists speed ] } {
                set speed 1000
            }
            
            set slot ""
            set port ""
            if { [ catch {
                foreach sp $portList {
                    set slot [lindex $sp 0]
                    set port [lindex $sp 1]
                    $chas configurePort $slot $port -auto $auto -fullduplex $fullduplex -speed $speed
                }
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to configurePort port $slot/$port -----"
                return [GetErrorReturnHeader $err]
            }
        }
        
        #--
        # Name: importTest - Import test into Bps system
        #--
        # Parameters:
        #       args:
        #           -src: Absolute local path or a URL
        #           -dst: Test name for imported test
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method importTest { { args "" } } {
            set tag "BpsConnection::importTest $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -src {
                        set src $value
                    }
                    -dst {
                        set dst $value
                    }
                }
            }
            
            if { ![ info exists dst ] } {
                error "dst must be configured"
            }
            
            if { ![ info exists src ] } {
                error "src must be configured"
            }
            
            if { [ catch {
                if { [string range $src 0 6] == "http://" || [string range $src 0 7] == "https://" } {
                    $handle importTest $dst -url $src
                } else {
                    $handle importTest $dst -file $src
                }
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to import test from $src to $dst -----"
                return [GetErrorReturnHeader $err]
            }
        }
        
        #--
        # Name: exportTest - Export test from Bps system
        #--
        # Parameters:
        #       args:
        #           -testid: Test result ID
        #           -dst: The absolute path for exported file 
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method exportTest { { args "" } } {
            set tag "BpsConnection::exportTest $args [info script]"
            Deputs "----- TAG: $tag -----"
        
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -testid {
                        set testid $value
                    }
                    -dst {
                        set dst $value
                    }
                }
            }
            
            if { ![ info exists testid ] } {
                error "testid must be configured"
            }
            
            if { ![ info exists dst ] } {
                error "dst must be configured"
            }
            
            if { [ catch {
                $handle exportTest -testid $testId -file $dst
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to export test $dst -----"
                return [GetErrorReturnHeader $err]
            }
        }
        
        #--
        # Name: deleteTest - Delete test from Bps system
        #--
        # Parameters:
        #       args:
        #           -name: The name of the deleted test
        #           -force: Whether force to delete the test, default is true
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method deleteTest { { args "" } } {
            set tag "BpsConnection::deleteTest $args [info script]"
            Deputs "----- TAG: $tag -----"
        
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -name {
                        set name $value
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                }
            }
            
            if { ![ info exists name ] } {
                error "name must be configured"
            }
            
            if { ![ info exists force ] } {
                set force true
            }
            
            if { [ catch {
                $conn deleteTest $name -force $force
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to delete test $name -----"
                return [GetErrorReturnHeader $err]
            }
        }
    }
    
    class BpsTest {
        inherit BpsObject
        
        variable conn       ""
        
        #--
        # Name: constructor - Constructor method for BpsTest
        #--
        # Parameters:
        #       template: Create or load an exist test template
        #       name: The name of the test to create on Bps system
        #       force: Whether overwrite the test has the same name as this new one, default is false
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method constructor { connection template name { force true } } {
            set tag "method BpsTest::constructor $template $name $force [info script]"
            Deputs "----- TAG: $tag -----"
            
            if { [ $connection isa BpsConnection] } {
                set conn [ $connection cget -handle ]
            } else {
                set conn $connection
            }
            
            if { [ catch {
                set handle [ $conn createTest -template $template -name $name -force $force ]
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to create test: $name -----"
                return [GetErrorReturnHeader $err]
            }
        }
        
        #--
        # Name: run - Run the test
        #--
        # Parameters:
        #       args:
        #           -group: Create or load an exist test template
        #           -async: Async run test call back function
        #           -progress: Monitor test progress call back function
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method run { { args "" } } {
            set tag "method BpsTest::run $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -group {
                        set group $value
                    }
                    -async {
                        set async $value
                    }
                    -progress {
                        set progress $value
                    }
                }
            }
            
            if { ![ info exists group ] } {
                set group 1
            }
            
            if { ![ info exists async ] } {
                set async cbAsyncRunTest
            }
            
            if { ![ info exists progress ] } {
                set progress cbTestProgress
            }
            
            if { [ catch {
                $handle run -group $group -async $async -progress $progress ]
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to run test: [ $handle cget -name ] -----"
                return [GetErrorReturnHeader $err]
            }
        }
    }
    
    class BpsNetwork {
        inherit BpsObject
        
        variable conn       ""
        
        #--
        # Name: constructor - Constructor method for BpsTest
        #--
        # Parameters:
        #       template: Create or load an exist network template
        #       name: The name of the network to create on Bps system
        #       force: Whether overwrite the test has the same name as this new one, default is false
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method constructor { connection template name { force true } } {
            set tag "method BpsNetwork::constructor $template $name $force [info script]"
            Deputs "----- TAG: $tag -----"
            
            if { [ $connection isa BpsConnection] } {
                set conn [ $connection cget -conn ]
            } else {
                set conn $connection
            }
            
            if { [ catch {
                set handle [ $conn createNetwork -template $template -name $name -force $force]
                return [GetStandardReturnHeader]
            } err ] } {
                Deputs "----- Failed to create network: $name -----"
                return [GetErrorReturnHeader $err]
            }
        }
    }
    
    #--
    # debug puts
    #--
    proc Deputs { value } {
        set timeVal  [ clock format [ clock seconds ] -format %D-%T ]
        set clickVal [ clock clicks ]
        puts "\[<IXIA>TIME:$timeVal\]$value"
        
        if { $IXIA::debug } {
            IXIA::Logger::LogIn -message $value
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
    source [file join $currDir "IxiaBpsCallBack.tcl"]
} err ] } {
    puts "load package fail...$err"
}