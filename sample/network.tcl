#!/bin/sh
lappend auto_path [file dirname [file dirname [info script]]]

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set network {MyNetwork}
set newNetwork {MyNetworkXYZ}

Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]

@tester createNetwork $newNetwork -template $network
set profile [ @tester getNetwork $newNetwork ]

#====================== Network ===========================
set action "add"
set type "interface"
set parameters [ list ]
@tester configureNetwork $newNetwork $action $type $parameters \
    -description "New interface" \
    -mac_address "02:1A:D5:01:00:00" \
    -number 1 \
    -id NewInterface1

set action "config"
set type "interface"
set parameters [ list NewInterface1]
@tester configureNetwork $newNetwork $action $type $parameters -description "Updated interface"

set action "remove"
set type "interface"
set parameters [ list NewInterface1 ]
@tester configureNetwork $newNetwork $action $type $parameters

set action "add"
set type "path"
set parameters [ list path1 path2 ]
@tester configureNetwork $newNetwork $action $type $parameters 

set action "remove"
set type "path"
set parameters [ list path1 path2 ]
@tester configureNetwork $newNetwork $action $type $parameters
#====================== Network ===========================

#Available network elements
#$network elementTypes
#interface {label Interface category {IP Infrastructure} description {Untagged Virtual Interface}} vlan {label VLAN category {IP Infrastructure} description {Virtual Interface}} ip_dhcp_server {label {IPv4 DHCP Server} category {IP Infrastructure} description {Simulated DHCP server}} ip6_dhcp_server {label {IPv6 DHCP Server} category {IP Infrastructure} description {Simulated DHCPv6 server}} ip_router {label {IPv4 Router} category {IP Infrastructure} description {Simulated IPv4 router}} ipsec_router {label {IPsec IPv4 Router} category {IP Infrastructure} description {Simulated IPsec IPv4 router}} ip6_router {label {IPv6 Router} category {IP Infrastructure} description {Simulated IPv6 router}} ip_dns_config {label {IPv4 DNS Configuration} category {IP Configuration} description {Shared DNS configuration for IPv4 endpoints}} ip6_dns_config {label {IPv6 DNS Configuration} category {IP Configuration} description {Shared DNS configuration for IPv6 endpoints}} ipsec_config {label {IPsec Configuration} category {IP Configuration} description {IPsec Configuration}} ip_external_hosts {label {IPv4 External Hosts} category Endpoint description {External hosts used as a test target}} ip6_external_hosts {label {IPv6 External Hosts} category Endpoint description {External hosts used as a test target}} ip_static_hosts {label {IPv4 Static Hosts} category Endpoint description {Simulated IPv4 endpoints}} ip6_static_hosts {label {IPv6 Hosts} category Endpoint description {Simulated IPv6 endpoints}} ip_dhcp_hosts {label {IPv4 DHCP Hosts} category Endpoint description {Simulated DHCP endpoints}} sixrd_ce {label {6RD Customer Edge Routers} category Endpoint description {Simulated 6RD Customer Edge Routers}} ue {label {User Equipment} category Endpoint description {Devices that transmit data over a 3G or LTE mobile network}} enodeb_mme {label {eNodeB/MME (GTPv2)} category LTE description {Simulates eNodeB/MME S1-U and S11 interfaces}} enodeb_mme6 {label {eNodeB/MME IPv6 (GTPv2)} category LTE description {Simulates eNodeB/MME S1-U and S11 interfaces IPv6}} enodeb_mme_sgw {label {eNodeB/MME/SGW (GTPv2)} category LTE description {Simulates SGW S5/S8 interface w/ eNodeB and MME}} enodeb_mme_sgw6 {label {eNodeB/MME/SGW IPv6(GTPv2)} category LTE description {Simulates SGW S5/S8 interface w/ eNodeB and MME  IPv6}} enodeb {label {eNodeB (S1AP / GTPv1)} category LTE description {Simulates a set of eNodeBs emulating S11 and S1-U interfaces}} enodeb6 {label {eNodeB IPv6(S1AP / GTPv1)} category LTE description {Simulates a set of eNodeBs emulating S11 and S1-U interfaces using IPv6}} sgw_pgw {label SGW/PGW category LTE description {Serving Gateway/PDN Gateway}} sgw_pgw6 {label {SGW/PGW IPv6} category LTE description {Serving Gateway/PDN Gateway IPv6}} mme_sgw_pgw {label MME/SGW/PGW category LTE description {Mobile Management Entity/Serving Gateway/PDN Gateway}} mme_sgw_pgw6 {label {MME/SGW/PGW IPv6} category LTE description {Mobile Management Entity/Serving Gateway/PDN Gateway IPv6}} pgw {label PGW category LTE description {Simulates the PDN Gateway S5/S8 Interface}} pgw6 {label {PGW IPv6} category LTE description {Simulates the PDN Gateway S5/S8 Interface IPv6}} ue_info {label {HSS/UE database} category {Mobile Configuration} description {Information required to properly represent User Equipment on an LTE mobile network}} plmn {label {Public Land Mobile Network} category {Mobile Configuration} description {A regulatory domain for a mobile network}} mobility_session_info {label {Mobility Session Information} category {Mobile Configuration} description {Information required for a device to connect to a mobile network}} ggsn {label GGSN category 3G description {Gateway GPRS Support Node}} ggsn6 {label {GGSN IPV6} category 3G description {Gateway GPRS Support Node IPV6}} sgsn {label SGSN category 3G description {Service GPRS Support Node}} sgsn6 {label {SGSN IPv6} category 3G description {Service GPRS Support Node IPv6}} ds_lite_b4 {label {DS-Lite B4} category {IP Infrastructure} description {IPv6-aware CPE with a B4 interface}} ds_lite_aftr {label {DS-Lite AFTR} category {IP Infrastructure} description {AFTR Router}} slaac_cfg {label {IPv6 SLAAC Client Configuration} category {IP Configuration} description {Shared IPv6 SLAAC Client Configuration}} dhcpv6c_cfg {label {DHCPv6 Client Configuration} category {IP Configuration} description {Shared DHCPv6 Client Configuration}} dhcpv6c_req_opts_cfg {label {DHCPv6 Request Options Configuration} category {IP Configuration} description {DHCPv6 Request Options}} dhcpv6c_tout_and_retr_cfg {label {DHCPv6 Timeout and Retransmission} category {IP Configuration} description {DHCPv6 Timing Options}}
