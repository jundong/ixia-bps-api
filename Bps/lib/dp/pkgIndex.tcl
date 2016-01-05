# Tcl Distributed Processing package index file.
# For more information about Tcl-DP, see the documentation in
#    C:/Program Files (x86)/dp/doc/index.html
# or,
#    http://tcldp.sourceforge.net
#
# This file is processed by CMake configuration_file() to substitute
# Cmake variable names with their values.

proc dp-4.2:Init { dir } {
    foreach file { {library/acl.tcl} {library/distribObj.tcl} {library/dp_atclose.tcl} {library/dp_atexit.tcl} {library/ldelete.tcl} {library/oo.tcl} {library/rpc.tcl} } {
        uplevel #0 source [list [file join $dir $file]]
    }
    uplevel #0 load [list [file join $dir dp42.dll]]
}
package ifneeded dp 4.2 [list dp-4.2:Init $dir]
