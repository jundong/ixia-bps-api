package require tdom

if {[info commands unknown] != ""} {
  rename unknown domunknown_orig_unknown
}

proc unknown {args} {
  set cmd [lindex $args 0]
  if {[namespace qualifiers $cmd] == "domNode"} {
    dom createNodeCmd -returnNodeCmd elementNode $cmd
    return [uplevel $args]
  } else {
  	set code [catch {uplevel domunknown_orig_unknown $args} ret]
  	global errorInfo errorCode
  	return -code $code -errorcode $errorCode -errorinfo $errorInfo $ret
  }
}

dom createNodeCmd -returnNodeCmd textNode domNode::text
dom createNodeCmd -returnNodeCmd cdata domNode::cdata

package provide domunknown 0.1
