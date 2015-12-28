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
    
    class BpsObject {
        public variable handle  ""
        public variable chas    ""
        
        #--
        # Name: save - Construct method for BpsConnection
        #--
        # Parameters:
        #       args:
        #           -name: The name of the object is saved to, default is using object current name
        #           -force: Wether force to save the object and overwrite exist one, default is true
        #           -attachments: Include attachments
        #           -file: Abusolute path to save the object to a file
        # Return:
        #        true if got success
        #        raise error if failed
        #--
        method save { args } {
            set tag "method BpsObject::save $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -name {
                        set name $value
                    }
                    -file {
                        set dst $value
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                    -attachments {
                        set attachments BoolTrans($value)
                    }
                }
            }
            
            if { [ info exists name ] } {
                set options "$options -name $name"
            }
            
            if { [ info exists dst ] } {
                set options "$options -file $dst"
            }
            
            if { [ info exists force ] } {
                if { $force } {
                    set options "$options -force"
                }
            }
            
            if { [ info exists attachments ] } {
                set options "$options -attachments $attachments"
            }
            
            if { [ catch {
                set cmd "$handle save $options"
                Deputs $cmd
                eval $cmd
                Deputs "----- Save object done -----"
            } err ] } {
                set tag "----- Failed to save test $£º$err -----"
                Deputs $tag
                return [GetErrorReturnHeader $err]
            }
            
            return [ GetStandardReturnHeader ]
        }
    }

    class BpsConnection {
        inherit BpsObject
        
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
        # Return:
        #        true if got success
        #        raise error if failed
        #--
        method constructor { host username password args } {
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
                set handle [ NamespaceDefine $handle [ namespace current ] ]
                set chas [$handle getChassis]
                set chas [ NamespaceDefine $chas [ namespace current ] ]
                
                set cmd "$chas configure -onlink cbPortLinkChanged -onreserve cbPortReserved -onstate cbPortStateChanged"
                Deputs $cmd
                eval $cmd
                Deputs "----- Connect to system done -----"
            } err ] } {
                set tag "----- Failed to connect to system£º$err -----"
                Deputs $tag
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: reservePort - Reserve Ports
        #--
        # Parameters: 
        #       args:
        #            -portlist: Port list to reserve, eg. [list {1 0} {1 1}]
        #            -group: Group ID, default value is 1
        #            -force: Wehter force to reserve port, default value is true
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method reservePort { args } {
            set tag "BpsConnection::reservePort $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -group {
                        set onclose $value
                    }
                    -portlist {
                        set portlist $value
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                }
            }
            
            if { [ info exists group ] } {
                set options "$options -group $group"
            }
            
            if { ![ info exists portlist ] } {
                error "Reserve portlist must be configured"
            }
            
            if { [ info exists force ] } {
                if { $force } {
                    set options "$options -force"
                }
            }
            
            set slot ""
            set port ""
            if { [ catch {
                foreach sp $portlist {
                    set slot [lindex $sp 0]
                    set port [lindex $sp 1]
                    set cmd "$chas reservePort $slot $port $options"
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
        #       args:
        #            -portlist: Port list to unreserve, eg. [list {1 0} {1 1}]
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method unreservePort { args } {
            set tag "BpsConnection::unreservePort $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -portlist {
                        set portlist $value
                    }
                }
            }
            
            if { ![ info exists portlist ] } {
                error "Unreserve portlist must be configured"
            }
            
            set slot ""
            set port ""
            if { [ catch {
                foreach sp $portlist {
                    set slot [lindex $sp 0]
                    set port [lindex $sp 1]
                    set cmd "$chas unreservePort $slot $port"
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
        method configurePort { portList args } {
            set tag "BpsConnection::configurePort $portList $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            if { [ llength $portList ] == 0 } {
                error "portList must be configured"
            }
            
            set options ""
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
            
            if { [ info exists auto ] } {
                set options "$options -auto $auto"
            }
            
            if { [ info exists fullduplex ] } {
                set options "$options -auto $auto"
            }
            
            if { [ info exists speed ] } {
                set options "$options -auto $auto"
            }
            
            set slot ""
            set port ""
            if { [ catch {
                foreach sp $portList {
                    set slot [lindex $sp 0]
                    set port [lindex $sp 1]
                    set cmd "$chas configurePort $slot $port $options"
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
        # Name: importResource - Import test into Bps system
        #--
        # Parameters:
        #       args:
        #            -type: The resource type to import into Bps system, eg. test or pcap
        #            -name: The name of imported test to save
        #            -file: The source file abusolute path
        #            -force: Wehter force to reserve port, default value is true
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method importResource { args } {
            set tag "BpsConnection::importResource $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -type {
                        set type [ string tolower $value ]
                    }
                    -name {
                        set dst $value
                    }
                    -file {
                        set src $value
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                }
            }
            
            if { [ info exists force ] } {
                if { $force } {
                    set options "$options -force"
                }
            }
            
            if { ![ info exists src ] } {
                error "Import file must be configured"
            } 
            
            if { ![ info exists type ] } {
                error "Import type must be configured"
            }
            
            if { ![ info exists dst ] } {
                error "Import name must be configured"
            }
            
            if { [ catch {
                if { [string range $src 0 6] == "http://" || [string range $src 0 7] == "https://" } {
                    set options "$options -url $src"
                } else {
                    set options "$options -file $src"
                }
                if { $type == "test" } {
                    set cmd "$handle importTest $dst $options"
                    Deputs $cmd
                    eval $cmd
                } elseif { $type == "pcap" } {
                    set cmd "$handle importPcap $dst $options"
                    Deputs $cmd
                    eval $cmd                    
                } else {
                    error "Unknown import resource type $type"
                }
            } err ] } {
                Deputs "----- Failed to import resource $type: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: deleteResource - Delete test from Bps system
        #--
        # Parameters:
        #       args:
        #           -type: The resource type to import into Bps system, eg. test or results
        #           -resultid: The resultid to delete
        #           -name: Delete test name
        #           -force: Whether force to delete the test, default is true
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method deleteResource { args } {
            set tag "BpsConnection::deleteResource $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                
                switch -exact -- $key {
                    -type {
                        set type [ string tolower $value ]
                    }
                    -resultid {
                        set resultid $value
                    }
                    -name {
                        set name $value
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                }
            }
            
            if { [ info exists force ] } {
                if { $force } {
                    set options "$options -force"
                }
            }
            
            if { ![ info exists type ] } {
                error "Delete type must be configured"
            } 
            
            if { [ catch {
                if { $type == "test" } {
                    if { ![ info exists name ] } {
                        error "Delete name must be configured"
                    }
                    set "$conn deleteTest $name $options"
                    Deputs $cmd
                    eval $cmd     
                } elseif { $type == "results" } {
                    if { ![ info exists resultid ] } {
                        error "Delete resultid must be configured"
                    }
                    set cmd "$conn deleteTestResults $resultid $options"
                    Deputs $cmd
                    eval $cmd     
                } else {
                    error "Unknown import resource type $type"
                }
                
            } err ] } {
                Deputs "----- Failed to delete resource $type: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: exportResource - Export test from Bps system
        #--
        # Parameters:
        #       args:
        #           -file: The absolute path for exported file
        #           -resultid: The test resultid
        #           -type: The resource type to export from Bps system, eg. test,pcap,results or report
        #           -channel: File channel to save the report, not support now
        #           -format: Report format: csv, flowstats, html, pdf, rtf, xls,
        #                       bpt, xml, zip, default value is pdf
        #           -sectionids: Filter desired sections
        #           -iterations: Run number or testId in form of test@<testid>@
        #           -direction: Captured packet direction, tx, rx or both
        #           -portlist: Port list to UnReserve, eg. [list {1 0} {1 1}]: The destination file to export report
        #           -compress: Returns the data in Zipped (.gz) compressed pcap
        #                       format when set to true, default is false
        #           -txfilter: Tx filter, eg. "host 10.1.0.254"
        #           -rxfilter: Rx filter, eg. "host 10.1.0.254"
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method exportResource { args } {
            set tag "BpsConnection::exportResource $args [info script]"
            Deputs "----- TAG: $tag -----"
        
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -file {
                        set dst $value
                    }
                    -type {
                        set type [ string tolower $value ]
                    }
                    -resultid {
                        set resultid $value
                    }
                    -format {
                        set format $value
                    }
                    -iterations {
                        set iterations $value
                    }
                    -sectionids {
                        set sectionids $value
                    }
                    -direction {
                        set direction $value
                    }
                    -portlist {
                        set portlist $value
                    }
                    -compress {
                        set compress $value
                    }
                    -txfilter {
                        set txfilter $value
                    }
                    -rxfilter {
                        set rxfilter $value
                    }
                }
            }
            
            if { ![ info exists dst ] } {
                error "Export file must be configured"
            }
            
            if { [ catch {
                if { $type == "test" } {
                    if { ![ info exists resultid ] } {
                        error "Export resultid must be configured"
                    }
                    set cmd "$handle exportTest -testid $testId -file $dst"
                    Deputs $cmd
                    eval $cmd     
                } elseif { $type == "results" } {
                    if { ![ info exists resultid ] } {
                        error "Export resultid must be configured"
                    }
                    set cmd "$handle exportFlowStats -testid $resultid -destdir $dst"
                    Deputs $cmd
                    eval $cmd     
                } elseif { $type == "report" } {
                    set options ""
                    if { [ info exists iterations ] } {
                        set options "$options -iterations $iterations"
                    }
                    
                    if { [ info exists format ] } {
                        set options "$options -format $format"
                    }
                    
                    if { [ info exists sectionids ] } {
                        set options "$options -sectionids $sectionids"
                    }
                    
                    set cmd "$handle exportReport -testid $resultid $options"
                    Deputs $cmd
                    eval $cmd     
                } elseif { $type == "pcap" } {
                    set options ""
                    if { ![ info exists direction ] } {
                        set direction both
                    }
                    
                    if { ![ info exists portlist ] } {
                        error "Export portlist must be configured"
                    }
            
                    if { [ info exists compress ] } {
                        set options "$options -compress $compress"
                    }
                    
                    if { [ info exists force ] } {
                        if { $force } {
                            set options "$options -force"
                        }
                    }
                    
                    if { [ info exists txfilter ] } {
                        set options "$options -txfilter $txfilter"
                    }
            
                    if { [ info exists rxfilter ] } {
                        set options "$options -rxfilter $rxfilter"
                    }
                    
                    set slot ""
                    set port ""
                    foreach sp $portlist {
                        set slot [lindex $sp 0]
                        set port [lindex $sp 1]
                        
                        set cmd "$chas exportPacketTrace $dst $options $slot $port $direction"
                        Deputs $cmd
                        eval $cmd     
                    }
                } else {
                    error "Unknown import resource type $type"
                }
            } err ] } {
                Deputs "----- Failed to export resource $type: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
    }
    
    class BpsTest {
        inherit BpsObject
        
        public variable conn    ""
        public variable aggStats
        
        #--
        # Name: constructor - Constructor method for BpsTest
        #--
        # Parameters:
        #       template: Create or load an exist test template
        #       name: The name of the test to create on Bps system
        #       args:
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method constructor { connection template name args } {
            set tag "method BpsTest::constructor $template $name $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                }
            }
            
            if { [ $connection isa IXIA::BpsConnection] } {
                set conn [ $connection cget -handle ]
                set chas [ $connection cget -chas ]
            } else {
                error "Wrong connection object $connection"
            }
             
            if { [ catch {
                set handle [ $conn createTest -template $template -name $name ]
                set handle [ NamespaceDefine $handle [ namespace current ] ]
            } err ] } {
                Deputs "----- Failed to create test $name: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: config - Constructor method for BpsTest
        #--
        # Parameters:
        #       args:
        #           -description: Test description
        #           -dut: Dut profile name
        #           -maxFlowCreationRate: 
        #           -maximumConcurrentFlows: 
        #           -lockedBy: 
        #           -name: Test name
        #           -neighborhood: Neighborhood profile name
        #           -network: Network profile name
        #           -requiredMTU: 
        #           -samplePeriod: 
        #           -seedOverride: 
        #           -totalAddresses: 
        #           -totalAttacks: 
        #           -totalBandwidth: 
        #           -totalMacAddresses: 
        #           -totalSubnets: Test 
        #           -totalUniqueStrikes: 
        #           -totalUniqueSuperflows:
        #           -resultId: Test result ID
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method config { args } {
            set tag "method BpsTest::config $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            if { [ catch {
                foreach { key value } $args {
                    set key [string tolower $key]
                    Deputs "Key :$key \tValue :$value"
                    switch -exact -- $key {
                        -description {
                            $handle configure -description $value
                        }
                        -dut {
                            $handle configure -dut $value
                        }
                        -maxFlowCreationRate {
                            $handle configure -maxFlowCreationRate $value
                        }
                        -maximumConcurrentFlows {
                            $handle configure -maximumConcurrentFlows $value
                        }
                        -lockedBy {
                            $handle configure -lockedBy $value
                        }
                        -name {
                            $handle configure -name $value
                        }
                        -neighborhood {
                            $handle configure -neighborhood $value
                        }
                        -network {
                            $handle configure -network $value
                        }
                        -requiredMTU {
                            $handle configure -requiredMTU $value
                        }
                        -samplePeriod {
                            $handle configure -samplePeriod  $value
                        }
                        -seedOverride {
                            $handle configure -seedOverride $value
                        }
                        -totalAddresses {
                            $handle configure -totalAddresses $value
                        }
                        -totalAttacks {
                            $handle configure -totalAttacks $value
                        }
                        -totalBandwidth {
                            $handle configure -totalBandwidth $value
                        }
                        -totalMacAddresses {
                            $handle configure -totalMacAddresses $value
                        }
                        -totalSubnets {
                            $handle configure -totalSubnets $value
                        }
                        -totalUniqueStrikes {
                            $handle configure -totalUniqueStrikes $value
                        }
                        -totalUniqueSuperflows {
                            $handle configure -totalUniqueSuperflows $value
                        }
                        -resultId {
                            $handle setResultId -resultId $value
                        }                        
                    }
                }
            } err ] } {
                Deputs "----- Failed to configure test: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: run - Run the test
        #--
        # Parameters:
        #       args:
        #           -group: Create or load an exist test template
        #           -async: Async run test call back function, we can use function cbAsyncRunTest
        #           -progress: Monitor test progress call back function, default is cbTestProgress
        #           -rtstats: Run-time statistics call back function, default is cbRunTimeStats
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method run { args } {
            set tag "method BpsTest::run $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
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
                        set cbProgress $value
                    }
                    -rtstats {
                        set cbRtStats $value
                    }
                }
            }
            
            if { [ info exists group ] } {
                set options "$options -group $group"
            }
            
            if { [ info exists async ] } {
                set options "$options -async $async"
                #set async cbAsyncRunTest
            }
            
            if { ![ info exists cbProgress ] } {
                set cbProgress cbTestProgress
            }
            set options "$options -progress $cbProgress"
            
            if { ![ info exists cbRtStats ] } {
                set cbRtStats cbRunTimeStats
            }
            set options "$options -rtstats $cbRtStats"
            
            if { [ catch {
                #set cmd "$handle getAggStats"
                #Deputs $cmd
                #set aggStats [ eval $cmd ]
                
                set cmd "$handle run $options"
                Deputs $cmd
                eval $cmd
            } err ] } {
                Deputs "----- Failed to run test [ $handle cget -name ]: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: stop - Stop the test
        #--
        # Parameters:
        #       args:
        #           -async: Async stop test call back function
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method stop { args } {
            set tag "method BpsTest::stop $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -async {
                        set async $value
                    }
                }
            }
            
            if { ![ info exists async ] } {
                set async cbAsyncStopTest
            }
            
            if { [ catch {
                set testId [ $handle resultId ]
                set cmd "$chas cancelTest $testId -async $async"
                Deputs $cmd 
                eval $cmd
            } err ] } {
                Deputs "----- Failed to stop test [ $handle cget -name ]: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: exportReport - Export test report
        #--
        # Parameters:
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
        method exportReport { args } {
            set tag "method BpsTest::exportReport $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -iterations {
                        set iterations $value
                    }
                    -file {
                        set dst $value
                    }
                    -channel {
                        set channel $value
                    }
                    -format {
                        set format $value
                    }
                    -sectionids {
                        set sectionids $value
                    }
                }
            }
            
            if { [ info exists format ] } {
                set options "$options -format $format"
            } else {
                set format pdf
            }
            
            if { ![ info exists dst ] } {
                error "file must be confiugred"
            } else {
                if { [ file isdirectory $dst ] } {
                    set dst [ file join $dst [ $handle cget -name ].$format ]
                }
            }

            if { [ info exists channel ] } {
                set options "$options -format $format"
            }
    
            if { [ info exists sectionids ] } {
                set options "$options -format $format"
            }
            
            if { [ catch {
                $handle exportReport $options
            } err ] } {
                Deputs "----- Failed to export test [ $handle cget -name ] report -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: exportCapture - Export test packet trace
        #--
        # Parameters:
        #       args:
        #           -file: Store exported trace directory
        #           -type: Captured packet direction, tx, rx or both
        #           -portlist: Port list to UnReserve, eg. [list {1 0} {1 1}]: The destination file to export report
        #           -compress: Returns the data in Zipped (.gz) compressed pcap
        #                       format when set to true, default is false
        #           -force: Report format: csv, flowstats, html, pdf, rtf, xls,
        #                       bpt, xml, zip, default value is pdf
        #           -txfilter: Tx filter, eg. "host 10.1.0.254"
        #           -rxfilter: Rx filter, eg. "host 10.1.0.254"
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method exportCapture { args } {
            set tag "method BpsTest::exportCapture $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                
                switch -exact -- $key {
                    -file {
                        set dst $value
                    }
                    -direction {
                        set direction $value
                    }
                    -portlist {
                        set portlist $value
                    }
                    -compress {
                        set compress BoolTrans($value)
                    }
                    -force {
                        set force BoolTrans($value)
                    }
                    -txfilter {
                        set txfilter $value
                    }
                    -rxfilter {
                        set rxfilter $value
                    }
                }
            }
            
            if { ![ info exists dst ] } {
                error "Export file must be configured"
            }

            if { ![ info exists direction ] } {
                error "Export direction must be configured"
            }
            
            if { ![ info exists portlist ] } {
                error "Export portlist must be configured"
            }
    
            if { [ info exists compress ] } {
                set options "$options -compress $compress"
            }
            
            if { [ info exists force ] } {
                if { $force } {
                    set options "$options -force"
                }
            }
            
            if { [ info exists txfilter ] } {
                set options "$options -txfilter $txfilter"
            }
    
            if { [ info exists rxfilter ] } {
                set options "$options -rxfilter $rxfilter"
            }
            
            set slot ""
            set port ""
            if { [ catch {
                foreach sp $portlist {
                    set slot [lindex $sp 0]
                    set port [lindex $sp 1]
                    set cmd "$chas exportPacketTrace $dst $options $slot $port $direction"
                    Deputs $cmd
                    eval $cmd 
                }
            } err ] } {
                Deputs "----- Failed to export packet trace from $slot/$port: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: startCapture - Start test packet trace
        #--
        # Parameters:
        #       args:
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method startCapture { args } {
            set tag "method BpsTest::startCapture $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            if { [ catch {
                set cmd "$handle startPacketTrace"
                Deputs $cmd
                eval $cmd
            } err ] } {
                Deputs "----- Failed to start packet trace: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: stopCapture - Stop test packet trace
        #--
        # Parameters:
        #       args:
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method stopCapture { args } {
            set tag "method BpsTest::stopCapture $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            if { [ catch {
                set cmd "$handle stopPacketTrace"
                Deputs $cmd
                eval $cmd
            } err ] } {
                Deputs "----- Failed to stop packet trace: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: getRtStats - Return run time test statitistcs
        #--
        # Parameters:
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
        method getRtStats { args } {
            set tag "method BpsTest::getRtStats $args [info script]"
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
            set name [ $handle cget -name ]
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
        # Name: getAggStats - Return aggregate test statitistcs
        #--
        # Parameters:
        #       args:
        #           -filters: Filter desired results
        # Return:
        #        cpu_usage: CPU Usage
        #        ethAlignmentErrors: Ethernet alignment errors
        #        ethDropEvents: Ethernet drop events
        #        ethFCSErrors: Ethernet FCS errors
        #        ethOversizedFrames: Ethernet oversize frames
        #        ethRxErrors: Ethernet receive errors
        #        ethRxFrameData: Ethernet bytes received. This includes L7
        #                        and all packet overhead, including L2,
        #                        L3, L4 headers, ethernet CRC, and interpacket
        #                        gap (20 bytes per frame).
        #        ethRxFrameDataRate: Ethernet receive rate. This includes L7
        #                        and all packet overhead, including L2,
        #                        L3, L4 headers, ethernet CRC, and interpacket
        #                        gap (20 bytes per frame)
        #        ethRxFrameRate: Ethernet frame receive rate
        #        ethRxFrames: Ethernet frames received
        #        ethRxPauseFrames: Ethernet pause frames received
        #        ethTotalErrors: Total Errors
        #        ethTxErrors: Ethernet transmit errors
        #        ethTxFrameData: Ethernet bytes transmit. This includes L7
        #                        and all packet overhead, including L2,
        #                        L3, L4 headers, ethernet CRC, and interpacket
        #                        gap (20 bytes per frame).
        #        ethTxFrameDataRate: Ethernet transmit rate. This includes L7
        #                        and all packet overhead, including L2,
        #                        L3, L4 headers, ethernet CRC, and interpacket
        #                        gap (20 bytes per frame).
        #        ethTxFrameRate: Ethernet frame transmit rate
        #        ethTxFrames: Ethernet frames transmitted
        #        ethTxPauseFrames: Ethernet pause frames transmitted
        #        ethUndersizedFrames: Ethernet undersize frames
        #        linux mem_free_kb: Free memory on the System Controller
        #        mem_total_kb: Total memory on the System Controller
        #        mem_used_kb: Used memory
        #        mount percent_used: The percent of disk spaced used on the disk partition
        #        superFlowRate: Super Flow rate
        #        superFlows: Aggregate Super Flows
        #        superFlowsConcurrent: Concurrent Super Flows
        #        tcpFlowRate: TCP Flow rate
        #        tcpFlows: Aggregate TCP Flows
        #        tcpFlowsConcurrent: Concurrent TCP Flows
        #        timestamp: The time that the datapoint was taken
        #                            (refers to the rest of the data that comes
        #                            with it)
        #        udpFlowRate: UDP Flow rate
        #        udpFlows: Aggregate UDP Flows
        #        udpFlowsConcurrent: Concurrent UDP Flows
        #
        #        return [] if no results
        #--
        method getAggStats { args } {
            set tag "method BpsTest::getAggStats $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            array set aggstats [list] 
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -filters {
                        set filters $value
                    }
                }
            }
            
            set aggResults [ $aggStats result ]
            
            puts "************ [ $aggResults values aggStats ] ***********"
            
            #if { [ info exists filters ] } {
            #    foreach stat $filters {
            #        dict for { key val } $IXIA::rtstatistics($name) {
            #            if { [ string tolower $stat ] == [ string tolower $key ] } {
            #                set rtstats($key) $val
            #                break
            #            }
            #        }   
            #    }
            #} else {
            #    return $IXIA::rtstatistics($name)
            #}
            #
            #return [ array get rtstats ] 
        }
        
        #--
        # Name: exportTest - Export test from Bps system
        #--
        # Parameters:
        #       args:
        #           -file: The absolute path for exported file 
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method exportTest { args } {
            set tag "BpsConnection::exportTest $args [info script]"
            Deputs "----- TAG: $tag -----"
        
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -file {
                        set dst $value
                    }
                }
            }
            
            if { ![ info exists dst ] } {
                error "file must be configured"
            }
            
            if { [ file isdirectory $dst ] } {
                set dst [ file join $dst [ $handle cget -name ].bpt ]
            }
            
            if { [ catch {
                set testId [ $handle resultId ]
                if { $testId == "" } {
                    error "No test id found for current test, you may run it for a trial"
                }
                
                $conn exportTest -testid $testId -file $dst
            } err ] } {
                Deputs "----- Failed to export test [ $handle cget -name ]: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
        }
        
        #--
        # Name: deleteTest - Delete test from Bps system
        #--
        # Parameters:
        #       args:
        #           -force: Whether force to delete the test, default is true
        # Return:
        #        0 if got success
        #        raise error if failed
        #--
        method deleteTest { args } {
            set tag "BpsConnection::deleteTest $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            set options ""
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                
                switch -exact -- $key {
                    -force {
                        set force BoolTrans($value)
                    }
                }
            }
            
            if { [ info exists force ] } {
                if { $force } {
                    set options "$options -force"
                }
            }
            
            set name [ $handle cget -name ]
            if { [ catch {
                $conn deleteTest $name $options
            } err ] } {
                Deputs "----- Failed to delete test $name: $err -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
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
        method constructor { connection template name args } {
            set tag "method BpsNetwork::constructor $template $name $args [info script]"
            Deputs "----- TAG: $tag -----"
            
            foreach { key value } $args {
                set key [string tolower $key]
                Deputs "Key :$key \tValue :$value"
                switch -exact -- $key {
                    -force {
                        set force $value
                    }
                }
            }
            
            if { ![ info exists force ] } {
                set options "$options -force"
            } else {
                if { $force } {
                    set options "$options -force"
                }
            }
            
            if { [ $connection isa IXIA::BpsConnection] } {
                set conn [ $connection cget -conn ]
                set chas [ $connection cget -chas ]
            } else {
                error "Wrong connection object $connection"
            }
            
            if { [ catch {
                set handle [ $conn createNetwork -template $template -name $name $options ]
                set handle [ NamespaceDefine $handle [ namespace current ] ]
            } err ] } {
                Deputs "----- Failed to create network: $name -----"
                return [GetErrorReturnHeader $err]
            }
            return [GetStandardReturnHeader]
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