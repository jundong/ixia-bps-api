#!/bin/sh
lappend auto_path [file dirname [file dirname [info script]]]

package require IxiaBps
namespace import IXIA::*

IxdebugOn

set superflow {MySuperflow}
set newSuperflow {MySuperflow}

Tester @tester 172.16.174.131 admin admin
set conn [ @tester getConnection ]

@tester createSuperflow $newSuperflow -template $superflow
set flow [ @tester getSuperflow $newSuperflow ]

#====================== Flow ===========================
set type "flow"
set action "add"
#set parameters [ list protocol from to ]
set parameters [ list httpadv Client Server ]
@tester configureSuperflow $newSuperflow $action $type $parameters

set action "modify"
#set parameters [ list actionid ]
set parameters [ list 2 ]
@tester configureSuperflow $newSuperflow $action $type $parameters -to Client -from Server -client-profile ie

set action "unset"
set parameters [ list 2 ]
@tester configureSuperflow $newSuperflow $action $type $parameters -client-profile

set action "remove"
#set parameters [ list actionid ]
set parameters [ list 2 ]
@tester configureSuperflow $newSuperflow $action $type $parameters
#====================== Flow ===========================

#====================== Action ===========================
set type "action"
set action "add"
#set parameters [ list flowid source type ]
set parameters [ list 1 client get_uri ]
@tester configureSuperflow $newSuperflow $action $type $parameters -proxied true

set action "modify"
#set parameters [ list actionid ]
set parameters [ list 3 ]
@tester configureSuperflow $newSuperflow $action $type $parameters -proxied true

set action "unset"
set parameters [ list 3 ]
@tester configureSuperflow $newSuperflow $action $type $parameters -proxied
set parameters [ list 4 ]
@tester configureSuperflow $newSuperflow $action $type $parameters -proxied

set action "remove"
#set parameters [ list actionid ]
set parameters [ list 4 ]
@tester configureSuperflow $newSuperflow $action $type $parameters
#====================== Action ===========================

#====================== Host ===========================
set type "host"
set action "add"
#set parameters [ list name iface dnsname ]
set parameters [ list HttpServer target http%n ]
@tester configureSuperflow $newSuperflow $action $type $parameters

set action "modify"
#set parameters [ list name ]
set parameters [ list HttpServer ]
@tester configureSuperflow $newSuperflow $action $type $parameters -iface origin

set action "remove"
#set parameters [ list name ]
set parameters [ list HttpServer ]
@tester configureSuperflow $newSuperflow $action $type $parameters
#====================== Host ===========================

#====================== Mathch Action ===========================
set type "action"
set action "add"
#set parameters [ list flowid source type ]
set parameters [ list 1 client expect ]
@tester configureSuperflow $newSuperflow $action $type $parameters \
    -match1 {200 OK} \
    -match2 {301 Moved} \
    -match3 {404 Not} \
    -nomatch.timeout 3

set type "maction"
set action "add"
#set parameters [ list actionid match flowid source name ]
set parameters [ list 5 1 1 client get_uri ]
@tester configureSuperflow $newSuperflow $action $type $parameters -uri /match1.html

set action "modify"
#set parameters [ list actionid matchid subid ]
set parameters [ list 5 1 1 ]
@tester configureSuperflow $newSuperflow $action $type $parameters -uri /match2.html

set action "unset"
#set parameters [ list actionid matchid subid ]
set parameters [ list 5 1 1 ]
@tester configureSuperflow $newSuperflow $action $type $parameters -uri

set action "remove"
#set parameters [ list actionid matchid subid ]
set parameters [ list 5 1 1 ]
@tester configureSuperflow $newSuperflow $action $type $parameters

set type "action"
set action "remove"
#set parameters [ list actionid ]
set parameters [ list 4 ]
@tester configureSuperflow $newSuperflow $action $type $parameters
#====================== Action ===========================

#Available action type
#::bps::BPSConnection::IXIA::Tester::bPSConnection0::MySuperflow getActionChoices 1
#server tls_accept client tls_start client tls_close_notify server tls_close_notify client tls_discard server tls_discard client delay server delay client raw_message server raw_message client expect client content_expect client check_bpsvar server content_expect client update_server_addr client update_dest_port client update_dest_tuple client update_rwnd server expect client verify_file client goto client close server close client fail server fail client log_msg client flow_dict client add_split_dict client markov_flow_dict client stop_rtp client simple_request client get_uri client partial_get client get_uri_nonterminal client pipelined_gets client get_uris_from_file client get_with_auth client post_uri client post_uri_nonterminal client put client think client connect server response_ok server response_partial_ok server response_oks_from_file server response_not_modified server response_not_found server response_auth_fail server error server response_redirect_permanent server response_redirect_temporary server response_redirect_see_other server response_temporary_redirect

#A part of availabled actions, you can find available options for a action
#::bps::BPSConnection::IXIA::Tester::bPSConnection0::MySuperflow getActions
#1 {source client flowid 1 type get_uri proxied false method GET uri {} keep-alive true accept {} accept-encoding {} accept-language {} user-agent {} cookie-name {} cookie-value {} custom-header-name {} custom-header-value {} custom_header_behavior replace} 2 {source server flowid 1 type response_ok compression none keep-alive true content-md5 false chunked false content-type {} configuration_file generate_attachment.json response-data {} html_inline_text_language English exclude_etag false cookie-name {} cookie-value {} custom-header-name {} custom-header-value {} custom_header_behavior replace} 3 {source server flowid 1 type tls_accept tls_enabled true tls_min_version TLS_VERSION_3_0 tls_max_version TLS_VERSION_3_0 tls_ciphers TLS_CIPHERSUITE_ALL tls_ciphers2 TLS_CIPHERSUITE_NONE tls_ciphers3 TLS_CIPHERSUITE_NONE tls_ciphers4 TLS_CIPHERSUITE_NONE tls_ciphers5 TLS_CIPHERSUITE_NONE tls_resume_max 100 tls_resume_expire 300 tls_handshake_timeout 0 tls_client_auth_enabled false tls_own_cert BreakingPoint_serverA_512.crt tls_own_key BreakingPoint_serverA_512.key tls_own_dh_params BreakingPoint_server_dhparams_128.pem tls_peer_common_name clientA_512.client.int tls_peer_ca_cert BreakingPoint_cacert_client.crt tls_peer_cert_verify_mode TLS_CERT_VERIFY_NOCHECK tls_decrypt_mode L4_TLS_DECRYPT_MODE_AUTO} 4 {source server flowid 1 type tls_accept tls_enabled true tls_min_version TLS_VERSION_3_0 tls_max_version TLS_VERSION_3_0 tls_ciphers TLS_CIPHERSUITE_ALL tls_ciphers2 TLS_CIPHERSUITE_NONE tls_ciphers3 TLS_CIPHERSUITE_NONE tls_ciphers4 TLS_CIPHERSUITE_NONE tls_ciphers5 TLS_CIPHERSUITE_NONE tls_resume_max 100 tls_resume_expire 300 tls_handshake_timeout 0 tls_client_auth_enabled false tls_own_cert BreakingPoint_serverA_512.crt tls_own_key BreakingPoint_serverA_512.key tls_own_dh_params BreakingPoint_server_dhparams_128.pem tls_peer_common_name clientA_512.client.int tls_peer_ca_cert BreakingPoint_cacert_client.crt tls_peer_cert_verify_mode TLS_CERT_VERIFY_NOCHECK tls_decrypt_mode L4_TLS_DECRYPT_MODE_AUTO}

#Available options for Host
#::bps::BPSConnection::IXIA::Tester::bPSConnection0::MySuperflow getHosts
#Client {iface origin dnsname client%n}
#Server {iface target dnsname server%n}

#Available options for MatchAction
#::bps::BPSConnection::IXIA::Tester::bPSConnection0::MySuperflow getMatchActionParameters 5 1 1
#-transflag continue -proxied false -method GET -uri {} -http_version_override 1.1 -uri_escape true -keep-alive true -accept {} -accept-encoding {} -accept-language {} -user-agent {} -if-none-match {} -cookie-name {} -cookie-value {} -custom-header-name {} -custom-header-value {} -custom-headers-file {} -custom_header_behavior replace

#::bps::BPSConnection::IXIA::Tester::bPSConnection0::MySuperflow getMatchActions 5 1
#1 {source client type get_uri uri /match1.html}

#Available flow options
#::bps::BPSConnection::IXIA::Tester::bPSConnection0::MySuperflow getFlows
#1 {protocol httpadv from Client to Server flow_mode sync l4transport 0 sctp-port 9899 sctp-checksum-type CRC32 sctp-shared-flow-enabled 0 sctp-key-offset-client 12 sctp-key-offset-server 12 sctp-shared-flow-master-only-enabled 0 ip4_tos_dscp 0 ip6_traffic_class 0 ip6_flowlabel 0 mobile_bearer_id 5 server-port-range-full Disabled client-profile desktop_mix server-profile default http_version 1.1 server-hostname default persist-cookies true num-rand-cookies 0 min-cookie-length 1 max-cookie-length 15 rand-cookie-value-persist false client-port 0 server-port 80}

#::bps::BPSConnection::IXIA::Tester::bPSConnection0::MySuperflow getFlowParameters 2
#-flow_mode sync -src_addr_bind 0.0.0.0 -dst_addr_bind 0.0.0.0 -l4transport 0 -sctp-port 9899 -sctp-checksum-type CRC32 -sctp-shared-flow-enabled 0 -sctp-key-offset-client 12 -sctp-key-offset-server 12 -sctp-shared-flow-master-only-enabled 0 -ip4_tos_dscp 0 -ip6_traffic_class 0 -ip6_flowlabel 0 -mobile_bearer_id 5 -l7transport stun2 -turn_channel_number {} -l7transport_flow_id 1 -server-port-range {} -server-port-range-full Disabled -client-profile desktop_mix -client-browser-version 0 -client-os windows7 -server-profile default -http_version 1.1 -server-hostname default -persist-cookies true -num-rand-cookies 0 -min-cookie-length 1 -max-cookie-length 15 -rand-cookie-value-persist false -client-port 0 -server-port 80