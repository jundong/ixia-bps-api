if {$tcl_platform(platform) == "windows"} {
  rename namespace safens::tcl_namespace

  proc safens::allvars {{namespace {}}} {
    set vars [concat [info vars ${namespace}::*] [info globals ${namespace}::*]]
    foreach childnamespace [safens::tcl_namespace children $namespace] {
      set vars [concat $vars [allvars $childnamespace]]
    }
    if {$namespace == {}} {
      foreach var $vars {
        foreach name [array names $var] {
          lappend vars ${var}($name)
        }
      }
    }
    return $vars
  }

  # for commands run from within a bps namespace, delete vars before
  # deleting the namespace, to avoid a bug with trace calls on variables
  # being deleted due to namespace delete
  proc namespace {args} {
    if {![string match ::bps::* [uplevel safens::tcl_namespace current]]} {
      return [uplevel safens::tcl_namespace $args]
    }
    if {[llength $args] == 2 
        && [lindex $args 0] == "delete"
        && [uplevel safens::tcl_namespace exists [list [lindex $args 1]]]} {
      # haven't found a workaround for itcl::delete; best workaround identified
      # so far is to refuse to delete
      return
      foreach var [safens::allvars [lindex $args 1]] {
        catch {unset $var}
      }
      foreach class [itcl::find classes [lindex $args 1]::*] {
        itcl::delete class $class
      }
    }
    return [uplevel safens::tcl_namespace $args]
  }
}
package provide safenamespace 0.1
