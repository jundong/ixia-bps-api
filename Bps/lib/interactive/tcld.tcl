#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

package require interactive

socket -server gotconnect 2001

proc gotconnect {newchan client_address client_port} {
  set interp [interp create -safe]
  set name [interactive::Interaction #auto -inchan $newchan -outchan $newchan \
                           -prompt2 "? " \
                           -interp $interp \
                           -telnet 1]
  $name configure -onclose "gotclose $newchan $name"
  $interp alias change_edit_mode change_edit_mode $name $interp
  $interp alias exit after idle close $newchan
  $interp eval {
    set editmode emacs
    trace variable editmode w "change_edit_mode"
  }
}

proc change_edit_mode {interaction interp name1 name2 op} {
  global editmode
  if {"" != $interp} {
    $interaction configure -editmode [$interp eval "set editmode"]
  } else {
    $interaction configure -editmode $editmode
  }
}

proc gotclose {chan obj} {
  interp delete [$obj cget -interp]
  after idle "itcl::delete object $obj"
}

set name [interactive::Interaction #auto -inchan stdin -outchan stdout \
  -prompt2 "? " \
  -onclose "set forever 1" \
  -telnet 0]

set editmode emacs
trace variable editmode w "change_edit_mode $name {}"

vwait forever
