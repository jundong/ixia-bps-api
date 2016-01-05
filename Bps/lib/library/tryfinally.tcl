 #----------------------------------------------------------------------
 #
 # try --
 #
 #       Execute a Tcl script with a mandatory cleanup.
 #
 # Usage:
 #       try script1 finally script2
 #
 # Parameters:
 #       script1 -- Script to execute
 #       finally -- The literal keyword, "finally".
 #       script2 -- Script to execute after script2
 #
 # Results:
 #       See below.
 #
 # Side effects:
 #       Whatever 'script1' and 'script2' do.
 #
 # The [try] command evaluates the script, 'script1'.  It saves the
 # result of evaluating the script temporarily, and then evaluates
 # 'script2'.  If 'script2' returns normally, the result of the
 # 'try' is the result of evaluating 'script1', which may be
 # a value, an error, or a return, continue, or break.  If 'script2'
 # returns an error, or if it breaks, continues, or returns, the
 # action of 'script2' overrides that of 'script1'; the result
 # of the [try] is to return the error, break, continue, or return.
 #
 # Bugs:
 #       [return -code] within either script cannot be implemented.
 #       For this reason, [try] should not be used around scripts
 #       that implement control structures.
 #
 # Example:
 #    The following script:
 #
 #       set f [open $fileName r]
 #       try {
 #            while { [gets $f line] >= 0 } {
 #                processOneLine $line
 #            }
 #       } finally {
 #            close $f
 #       }
 #
 #    has the effect of ensuring that the file is closed, irrespective
 #    of what processOneLine does.  (If [close] returns an error, that
 #    error is returned in preference to any error from the 'try'
 #    block.)
 #
 #----------------------------------------------------------------------

 proc try { script1 finally script2 } {
     if { [string compare $finally {finally}] } {
         append message \
             "syntax error: should be \"" [lindex [info level 0] 0] \
             " script1 finally script2\""
         return -code error $message
     }
     set status1 [catch {
         uplevel 1 $script1
     } result1]
     if { $status1 == 1 } {
         set info1 $::errorInfo
         set code1 $::errorCode
     }
     set status2 [catch {
         uplevel 1 $script2
     } result2]
     switch -exact -- $status2 {
         0 {                             # TCL_OK - 'finally' was ok
             switch -exact -- $status1 {
                 0 {                     # TCL_OK - 'try' was also ok
                     return $result1
                 }
                 1 {                     # TCL_ERROR - 'try' failed
                     return -code error \
                            -errorcode $code1 \
                            -errorinfo $info1 \
                            $result1
                 }
                 2 {                     #  TCL_RETURN
                     return -code return $result1
                 }
                 3 {                     # TCL_BREAK
                     return -code break
                 }
                 4 {                     # TCL_CONTINUE
                     return -code continue
                 }
                 default {               # Another code
                     return -code $code $result1
                 }
             }
         }
         1 {                             # TCL_ERROR -- 'finally' failed
             set info2 $::errorInfo
             set code2 $::errorCode
             append info2 "\n    (\"finally\" block)"
             return -code error -errorcode $code2 -errorinfo $info2 \
                 $result2
         }
         2 {                             # TCL_RETURN
             # A 'return' in a 'finally' block overrides
             # any status from the 'try' ?

             return -code return $result2
         }
         3 {                             # TCL_BREAK
             # A 'break' in a 'finally' block overrides
             # any status from the 'try' ?

             return -code break
         }
         4 {                             # TCL_CONTINUE
             # A 'continue' in a 'finally' block overrides
             # any status from the 'try' ?

             return -code break
         }
         default {                       # Another code in 'finally'
             # Another code in a 'finally' block is returned
             # overriding any status from the 'try'

             return -code $code $result2
         }
     }
 }


package provide tryfinally 0.1
