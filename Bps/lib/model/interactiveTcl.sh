#!/bin/sh
# \
exec /usr/local/ActiveTcl/bin/tclsh "$0" "$@"

set sdir [file dirname [info script]]
lappend auto_path $sdir [file join $sdir .. interactive]

source cheesy.itcl
source testmodel.itcl

source datatype.itcl

# payload
model::defineEnum :: PayloadType {zeroes ones random predefined}
model::defineString :: PayloadString -maxlength 1024 -charclass xdigit
model::defineStruct :: Payload {
  type PayloadType
  data PayloadString
} {
  { type required }
  { type equals predefined data required }
}

model::defineEnum :: DistType {constant random}
model::defineInt :: SizeRange 64 9000
model::defineStruct :: PacketSizeDistribution {
  type DistType
  value SizeRange
  rangeMin SizeRange
  rangeMax SizeRange
} {
  { type required }
  { type equals constant value required }
  { type equals random rangeMin required }
  { type equals random rangeMax required }
  { rangeMin lessThan rangeMax }
}

model::defineInt :: RateRange 1 1000
model::defineStruct :: PacketRateDistribution {
  type DistType
  value RateRange
  rangeMin RateRange
  rangeMax RateRange
} {
  { type required }
  { type equals constant value required }
  { type equals random rangeMin required }
  { type equals random rangeMax required }
  { rangeMin lessThan rangeMax }
}

model::defineStruct :: BitBlasterParams {
  payload Payload
  sizeDistribution PacketSizeDistribution
  rateDistribution PacketRateDistribution
} {
  { payload required }
  { sizeDistribution required }
  { rateDistribution required }
}

BitBlasterParams p -value {
  payload {type random} 
  sizeDistribution {type constant value 64}
  rateDistribution {type constant value 1000}
}

proc say {category args} {
  puts "$category: $args"
}

package require interactive
interactive::interact
