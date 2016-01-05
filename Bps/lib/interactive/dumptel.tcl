#!/bin/sh
# \
exec tclsh8.3 "$0" "$@"

if {[llength $argv] > 0} {
  set client 0
  socket -server gotconnect 2001
} else {
  set client 1
  set c [socket localhost 23]
  fileevent $c readable "charval $c"
  fconfigure $c -blocking no -buffering none
}

fileevent stdin readable "readinput"
fconfigure stdin -blocking no -buffering none
fconfigure stdout -buffering none

set client_init 0
proc gotconnect {newchan client_address client_port} {
  global client_init
  fileevent $newchan readable "charval $newchan"
  fconfigure $newchan -blocking 0 -buffering none
  # send the init stuff the telnet server sends...
  puts $newchan [format %c%c%c%c%c%c%c%c%c%c%c%c \
      0xff 0xfd 0x18 \
      0xff 0xfd 0x20 \
      0xff 0xfd 0x23 \
      0xff 0xfd 0x27]
  # remind ourselves to finish initializing things
  set client_init 1
}

proc getbin {charlistvar} {
  upvar $charlistvar charlist

  binary scan [lindex $charlist 0] H* thischar
  set thischar 0x$thischar
  set charlist [lreplace $charlist 0 0]
  return $thischar
}

proc charval {s} {
  global client env client_init
  if [eof $s] {
    close $s
    puts "$s disconnected"
    if {$client} {
      exit
    }
    return
  }
  set data [read $s]

  set cmdlist [split $data {}]
  while {[llength $cmdlist] > 0} {
    set thischar [getbin cmdlist]
    if {$thischar != 0xff} {
      puts -nonewline [format %c $thischar]
      continue
    }

    puts -nonewline "$thischar "
    set thischar [getbin cmdlist]
    puts -nonewline "$thischar "
    switch $thischar {
      0xfd {
        # "DO", respond with "WILL"
        set opt [getbin cmdlist]
        puts -nonewline "$opt "
        puts -nonewline $s [format %c%c%c 255 251 $opt]
      }
      0xfb {
        # "WILL"
        set opt [getbin cmdlist]
        puts -nonewline "$opt "
        if {$client_init} {
          # request the client to send values for these options
          puts $s [format %c%c%c%c%c%c \
                 0xff 0xfa $opt 0x01 \
                 0xff 0xf0]
        } else {
          # no response needed, just read off the rest
        }
      }
      0xfa {
        # "subnegotiation", scan up to the "end sub"
        set opt [getbin cmdlist]
        puts -nonewline "$opt "

        set request [getbin cmdlist]
        puts -nonewline "$request "

        set val {}
        while {1} {
          set char [lindex $cmdlist 0]
          set closeopt [getbin cmdlist]
          if {$closeopt == 255} {
            # I'm going to assume the next char is the expected 240
            puts -nonewline "$closeopt "
            set closeopt [getbin cmdlist]
            puts -nonewline "$closeopt "
            break
          }
          append val $char
          puts -nonewline $char
        }

        # decide what to do...
        switch $request {
          0x01 {
            # this is a request for the value, return it...
            switch $opt {
              0x18 {
                # terminal type
                puts -nonewline $s [format %c%c%c%c 255 250 0x18 0x00]
                if {[info exists env(TERM)]} {
                  puts -nonewline $s $env(TERM)
                } else {
                  puts -nonewline $s NONE
                }
                puts -nonewline $s [format %c%c 255 240]
              }
              0x20 {
                # terminal speed
                puts -nonewline $s [format %c%c%c%c 255 250 0x20 0x00]
                puts -nonewline $s 38400,38400
                puts -nonewline $s [format %c%c 255 240]
              }
              0x23 {
                # x display location
                if {[info exists env(DISPLAY)]} {
                  puts -nonewline $s [format %c%c%c%c 255 250 0x23 0x00]
                  puts -nonewline $s $env(DISPLAY)
                  puts -nonewline $s [format %c%c 255 240]
                }
              }
              0x27 {
                # New - Environment variables
                puts -nonewline $s [format %c%c%c%c 255 250 0x27 0x00]
                set sep 0x03
                foreach x {DISPLAY XAUTHORITY} {
                  if {[info exists env($x)]} {
                    puts -nonewline $s [format %c $sep]
                    set sep 0x00
                    puts -nonewline $s $x
                    puts -nonewline $s [format %c 0x01]
                    puts -nonewline $s $env($x)
                  }
                }
                puts -nonewline $s [format %c%c 255 240]
              }
            }
          }
          0x00 {
            # response with a value
            switch $opt {
              0x18 {
                puts "got a terminal type of $val"
              }
              0x20 {
                puts "got a term speed of $val"
              }
              0x23 {
                puts "got an X display of $val"
              }
              0x27 {
                puts "got some env vars..."
              }
            }
          }
        }
      }
    }
  }
  if {$client_init} {
    set client_init 0
    puts -nonewline $s [format %c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c%c \
           0xff 0xfb 0x03 \
           0xff 0xfd 0x01 \
           0xff 0xfd 0x1f \
           0xff 0xfb 0x05 \
           0xff 0xfd 0x21 \
           0xff 0xfe \
           0xff 0xfb 0x01]
  }
}

proc readinput {} {
  global c
  set s [read stdin]
  puts -nonewline $c $s
}

vwait forever
