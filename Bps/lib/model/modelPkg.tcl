lappend auto_path [file dirname [info script]]

  
namespace eval model {
  set templatedir [file dirname [info script]]
}
package provide model 0.1
