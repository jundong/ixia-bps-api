proc infostack {} {
  set ret {}
  set n {}
  for {set i [expr [info level] - 1]} {$i > 0} {incr i -1} {
    append ret $n
    set n \n
    append ret "level $i: [info level $i]"
  }
  return $ret
}

package provide infostack 0.1
