proc jdkStackTrace {} {
    global errorCode errorInfo
    set ret {}
    if { [string match {JAVA*} $errorCode] } {
        set exception [lindex $errorCode 1]
        set stream [java::new java.io.ByteArrayOutputStream]
        set printWriter [java::new \
                {java.io.PrintWriter java.io.OutputStream} $stream]
        $exception {printStackTrace java.io.PrintWriter} $printWriter
        $printWriter flush

        append ret "[$stream toString]"
        append ret "    while executing"
    }
    append ret $errorInfo
    return $ret
}

package provide jdkstacktrace 0.1
