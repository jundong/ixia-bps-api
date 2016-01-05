package require tryfinally
package require fileutil

namespace eval multipart {
  namespace export post
}

proc multipart::httpprogress {passthru type token total completed} {
  set pcent 0
  if {$total > 0} {
  	  set pcent [expr int(100.0 * $completed / $total)]
  }
  eval $passthru $type $pcent
}

proc multipart::post {url headers progress args} {
  set tmpfile [fileutil::tempfile httpquery]
  set bound "-----NEXT_PART_[clock seconds].[pid]"

  if {$progress != ""} {
    set dprog [list -progress [list multipart::httpprogress $progress download]]
    set uprog [list -queryprogress [list multipart::httpprogress $progress upload]]
  } else {
    set dprog {}
    set uprog {}
  }

  eval [list multipart::CreateQuery $tmpfile $bound $dprog] $args

#  set headers [concat $headers [list Content-Length [file size $tmpfile]]]
  set q [open $tmpfile r]
  try {
    set tok [eval [list http::geturl $url \
        -headers $headers \
        -type "multipart/form-data; boundary=$bound" \
        -queryblocksize [expr [file size $tmpfile] / 100]] \
        $uprog \
        [list -querychannel $q]]
    try {
      if {[http::status $tok] != "ok"} {
        error "Error downloading url $url: [http::code $tok]"
      }
      if {[http::ncode $tok] != 200} {
        error [http::code $tok]
      }
      set data [http::data $tok]
      return $data
    } finally {
      http::cleanup $tok
    }
  } finally {
    close $q
  }
}

proc multipart::CreateQuery {tmpfile bound progress args} {
  set f [open $tmpfile w]
  try {
    fconfigure $f -translation crlf

    foreach {type val} $args {
      switch -exact -- $type {
        -field {
          foreach {elem data} $val break
          puts $f "--${bound}\nContent-Disposition: form-data;\
 name=\"$elem\"\n\n$data"
        }
        -file {
          foreach {elem filename file} $val break
          set i [open $file r]
          try {
            fconfigure $i -translation binary
            puts $f "--${bound}\nContent-Disposition: form-data;\
 name=\"$elem\"; filename=\"$filename\""
            puts $f "Content-Type: application/octet-stream\n"
            fconfigure $f -translation binary
            fcopy $i $f
            fconfigure $f -translation crlf
            puts $f ""
          } finally {
            close $i
          }
        }
        -url {
          foreach {elem filename url query} $val break
          puts $f "--${bound}\nContent-Disposition: form-data;\
 name=\"$elem\"; filename=\"$filename\""
          puts $f "Content-Type: application/octet-stream\n"

          if {$query != ""} {
            set query [concat -query $query]
          }
          fconfigure $f -translation binary
          set tok [eval [list http::geturl $url \
             -blocksize 10000] \
             $progress \
             [list -channel $f -binary true] $query]
          fconfigure $f -translation crlf
          try {
            if {[http::status $tok] != "ok"} {
              error "Error downloading url $url: [http::code $tok]"
            }
            if {[http::ncode $tok] != 200} {
              error [http::code $tok]
            }
          } finally {
            http::cleanup $tok
          }
          puts $f ""
        }
        default {
          error "Invalid option $type"
        }
      }
    }

    puts $f "--${bound}--\n"
  } finally {
    close $f
  }
  #file delete $tmpfile
}

package provide multipart 0.1
