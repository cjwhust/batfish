parser grammar AristaParser;

import
Arista_common,
Legacy_common,
Arista_aspath,
Arista_bgp,
Arista_cvx,
Arista_email,
Arista_igmp,
Arista_interface,
Arista_logging,
Arista_mac,
Arista_mlag,
Arista_multicast,
Arista_pim,
Arista_ptp,
Arista_vlan,
Legacy_aaa,
Legacy_acl,
Legacy_crypto,
Legacy_interface,
Legacy_isis,
Legacy_mpls,
Legacy_ntp,
Legacy_ospf,
Legacy_pim,
Legacy_qos,
Legacy_rip,
Legacy_routemap,
Legacy_snmp;


options {
   superClass = 'org.batfish.grammar.arista.parsing.AristaBaseParser';
   tokenVocab = AristaLexer;
}

address_aiimgp_stanza
:
   ADDRESS null_rest_of_line
;

address_family_multicast_stanza
:
   ADDRESS_FAMILY
   (
      IPV4
      | IPV6
   ) NEWLINE address_family_multicast_tail
;

address_family_multicast_tail
:
   (
      (
         MULTIPATH NEWLINE
      )
      |
      (
         INTERFACE ALL ENABLE NEWLINE
      )
      | null_af_multicast_tail
      | interface_multicast_stanza
   )*
;

ags_null
:
   NO?
   (
      DESCRIPTION
      | ID
   ) null_rest_of_line
;

aiimgp_stanza
:
   address_aiimgp_stanza
;

al_null
:
   NO?
   (
      HIDEKEYS
      | LOGGING
      | NOTIFY
   ) null_rest_of_line
;

allow_iimgp_stanza
:
   ALLOW null_rest_of_line aiimgp_stanza*
;

allowed_ip
:
   (
      (
         hostname = IP_ADDRESS mask = IP_ADDRESS
      )
      | hostname = IPV6_ADDRESS
   ) iname = variable NEWLINE
;

ap_null
:
   NO?
   (
      AP_BLACKLIST_TIME
      | ENET_LINK_PROFILE
      | FLUSH_R1_ON_NEW_R0
      | GENERAL_PROFILE
      | GROUP
      | LLDP
      | MESH_CLUSTER_PROFILE
      | MESH_HT_SSID_PROFILE
      | MESH_RADIO_PROFILE
      | PROVISIONING_PROFILE
      | SPECTRUM
      | WIRED_AP_PROFILE
      | WIRED_PORT_PROFILE
   ) null_rest_of_line
;

ap_regulatory_domain_profile
:
   REGULATORY_DOMAIN_PROFILE null_rest_of_line
   (
      aprdp_null
   )*
;

ap_system_profile
:
   SYSTEM_PROFILE null_rest_of_line
   (
      apsp_null
   )*
;

apg_null
:
   NO?
   (
      AP_SYSTEM_PROFILE
      | DOT11A_RADIO_PROFILE
      | DOT11G_RADIO_PROFILE
      | IDS_PROFILE
      | VIRTUAL_AP
   ) null_rest_of_line
;

apn_null
:
   NO?
   (
      VIRTUAL_AP
   ) null_rest_of_line
;

aprdp_null
:
   NO?
   (
      COUNTRY_CODE
      | VALID_11A_40MHZ_CHANNEL_PAIR
      | VALID_11A_80MHZ_CHANNEL_GROUP
      | VALID_11A_CHANNEL
      | VALID_11G_40MHZ_CHANNEL_PAIR
      | VALID_11G_CHANNEL
   ) null_rest_of_line
;

apsp_null
:
   NO?
   (
      BKUP_LMS_IP
      | DNS_DOMAIN
      | LMS_IP
      | LMS_PREEMPTION
   ) null_rest_of_line
;

archive_log
:
   LOG null_rest_of_line
   (
      al_null
   )*
;

archive_null
:
   NO?
   (
      MAXIMUM
      | PATH
      | WRITE_MEMORY
   ) null_rest_of_line
;

av_null
:
   NO?
   (
      CAPTURE
      | INTERFACE
      | MODE
      | SHUTDOWN
      | TIMESOURCE
   ) null_rest_of_line
;

bfd_null
:
   NO?
   (
      TRAP
   ) null_rest_of_line
;

bfd_template_null
:
  NO?
  (
    ECHO
    | INTERVAL
  ) null_rest_of_line
;

arista_configuration
:
   NEWLINE?
   (sl += stanza)+
   COLON? NEWLINE? EOF
;

configure_maintenance
:
   MAINTENANCE null_rest_of_line
   (
      configure_maintenance_null
      | configure_maintenance_router
   )*
;

configure_maintenance_null
:
   NO?
   (
      IP
   ) null_rest_of_line
;

configure_maintenance_router
:
   NO?
   (
      ROUTER
   ) null_rest_of_line
   (
      configure_maintenance_router_null
   )*
;

configure_maintenance_router_null
:
   NO?
   (
      ISOLATE
   ) null_rest_of_line
;

configure_null
:
   NO?
   (
      | SESSION
      | TERMINAL
   ) null_rest_of_line
;

cops_listener
:
   LISTENER
   (
      copsl_access_list
   )
;

copsl_access_list
:
   ACCESS_LIST name = variable_permissive NEWLINE
;

cp_ip_access_group
:
   (
      IP
      | IPV6
   ) ACCESS_GROUP name = variable
   (
      VRF vrf = vrf_name
   )?
   (
      IN
      | OUT
   ) NEWLINE
;

cp_ip_flow
:
   IP FLOW MONITOR name = variable
   (
      INPUT
      | OUTPUT
   ) NEWLINE
;

cp_management_plane
:
   MANAGEMENT_PLANE NEWLINE mgp_stanza*
;

cp_null
:
   NO?
   (
      EXIT
      | SCALE_FACTOR
   ) null_rest_of_line
;

cp_service_policy
:
   SERVICE_POLICY
   (
      INPUT
      | OUTPUT
   ) name = variable NEWLINE
;

cps_null
:
   NO?
   (
      AUTO_CERT_ALLOW_ALL
      | AUTO_CERT_ALLOWED_ADDRS
      | AUTO_CERT_PROV
   ) null_rest_of_line
;

cqg_null
:
   NO?
   (
      PRECEDENCE
      | QUEUE
      | RANDOM_DETECT_LABEL
   ) null_rest_of_line
;

cmf_null
:
   NO?
   (
      ALIAS
      | CALL_FORWARD
      | DEFAULT_DESTINATION
      | DIALPLAN_PATTERN
      | IP
      | KEEPALIVE
      | LIMIT_DN
      | MAX_CONFERENCES
      | MAX_DN
      | MAX_EPHONES
      | SECONDARY_DIALTONE
      | TIME_FORMAT
      | TIME_ZONE
      | TRANSFER_SYSTEM
      | TRANSLATION_PROFILE
   ) null_rest_of_line
;

ctlf_null
:
   NO?
   (
      RECORD_ENTRY
      | SHUTDOWN
   ) null_rest_of_line
;

d11_null
:
   NO?
   (
      ACCOUNTING
      | AUTHENTICATION
      | GUEST_MODE
      | MAX_ASSOCIATIONS
      | MBSSID
      | VLAN
   ) null_rest_of_line
;

daemon_null
:
   NO?
   (
      EXEC
      | SHUTDOWN
   ) null_rest_of_line
;

dapr_null
:
   NO?
   (
      ACTION
      | USER_MESSAGE
   ) null_rest_of_line
;

dapr_webvpn
:
   WEBVPN NEWLINE
   (
      daprw_null
   )*
;

daprw_null
:
   NO?
   (
      ALWAYS_ON_VPN
      | SVC
      | URL_LIST
   ) null_rest_of_line
;

del_stanza
:
   DEL null_rest_of_line
;

dhcp_null
:
   NO?
   (
      INTERFACE
   ) null_rest_of_line
;

dhcp_profile
:
   NO? PROFILE null_rest_of_line
   (
      dhcp_profile_null
   )*
;

dhcp_profile_null
:
   NO?
   (
      DEFAULT_ROUTER
      | DOMAIN_NAME
      | DNS_SERVER
      | HELPER_ADDRESS
      | LEASE
      | POOL
      | SUBNET_MASK
   ) null_rest_of_line
;

dialer_group
:
   GROUP null_rest_of_line
   (
      dialer_group_null
   )*
;

dialer_group_null
:
   NO?
   (
      DIAL_STRING
      | INIT_STRING
   ) null_rest_of_line
;

dialer_null
:
   NO?
   (
      WATCH_LIST
   ) null_rest_of_line
;

domain_lookup
:
   LOOKUP
   (
      SOURCE_INTERFACE iname = interface_name
      | DISABLE
   ) NEWLINE
;

domain_name
:
   NAME hostname = variable_hostname NEWLINE
;

domain_name_server
:
   NAME_SERVER hostname = variable_hostname NEWLINE
;

dspf_null
:
   NO?
   (
      ASSOCIATE
      | DESCRIPTION
      | CODEC
      | MAXIMUM
      | SHUTDOWN
   ) null_rest_of_line
;

ednt_null
:
   NO?
   (
      CALL_FORWARD
   ) null_rest_of_line
;

eh_null
:
   NO?
   (
      ACTION
      | ASYNCHRONOUS
      | DELAY
      | TRIGGER
   ) null_rest_of_line
;

enable_null
:
   (
      ENCRYPTED_PASSWORD
      | READ_ONLY_PASSWORD
      | SUPER_USER_PASSWORD
      | TELNET
   ) null_rest_of_line
;

enable_password
:
   PASSWORD (LEVEL level = dec)?
   (
      ep_plaintext
      | ep_sha512
   ) NEWLINE
;

enable_secret
:
   SECRET
   (
      (
         dec pass = variable_secret
      )
      | double_quoted_string
   ) NEWLINE
;

ep_plaintext
:
   pass = variable
;

ep_sha512
:
   (sha512pass = SHA512_PASSWORD) (seed = PASSWORD_SEED)?
;

event_null
:
   NO?
   (
      ACTION
      | EVENT
      | SET
   ) null_rest_of_line
;

flow_null
:
   NO?
   (
      CACHE
      | COLLECT
      | DESCRIPTION
      | DESTINATION
      | EXPORT_PROTOCOL
      | EXPORTER
      | MATCH
      | OPTION
      | RECORD
      | SOURCE
      | STATISTICS
      | TRANSPORT
   ) null_rest_of_line
;

flow_version
:
   NO? VERSION null_rest_of_line
   (
      flowv_null
   )*
;

flowv_null
:
   NO?
   (
      OPTIONS
      | TEMPLATE
   ) null_rest_of_line
;

gae_null
:
   NO?
   (
      SMTP_SERVER
   ) null_rest_of_line
;

gpsec_null
:
   NO?
   (
      AGE
      | DELETE_DYNAMIC_LEARN
   ) null_rest_of_line
;

ids_ap_classification_rule
:
   AP_CLASSIFICATION_RULE double_quoted_string NEWLINE
   (
      ids_ap_classification_rule_null
   )*
;

ids_ap_classification_rule_null
:
   NO?
   (
      CONF_LEVEL_INCR
      | DISCOVERED_AP_CNT
      | SSID
      | SNR_MAX
      | SNR_MIN
   ) null_rest_of_line
;

ids_ap_rule_matching
:
   AP_RULE_MATCHING NEWLINE
   (
      ids_ap_rule_matching_null
   )*
;

ids_ap_rule_matching_null
:
   NO?
   (
      RULE_NAME
   ) null_rest_of_line
;

ids_dos_profile
:
   DOS_PROFILE double_quoted_string NEWLINE
   (
      ids_dos_profile_null
   )*
;

ids_dos_profile_null
:
   NO?
   (
      DETECT_AP_FLOOD
      | DETECT_CHOPCHOP_ATTACK
      | DETECT_CLIENT_FLOOD
      | DETECT_CTS_RATE_ANOMALY
      | DETECT_EAP_RATE_ANOMALY
      | DETECT_HT_40MHZ_INTOLERANCE
      | DETECT_INVALID_ADDRESS_COMBINATION
      | DETECT_MALFORMED_ASSOCIATION_REQUEST
      | DETECT_MALFORMED_AUTH_FRAME
      | DETECT_MALFORMED_HTIE
      | DETECT_MALFORMED_LARGE_DURATION
      | DETECT_OVERFLOW_EAPOL_KEY
      | DETECT_OVERFLOW_IE
      | DETECT_RATE_ANOMALIES
      | DETECT_RTS_RATE_ANOMALY
      | DETECT_TKIP_REPLAY_ATTACK
   ) null_rest_of_line
;

ids_general_profile
:
   GENERAL_PROFILE double_quoted_string NEWLINE
   (
      ids_general_profile_null
   )*
;

ids_general_profile_null
:
   NO?
   (
      WIRED_CONTAINMENT
      | WIRELESS_CONTAINMENT
   ) null_rest_of_line
;

ids_impersonation_profile
:
   IMPERSONATION_PROFILE double_quoted_string NEWLINE
   (
      ids_impersonation_profile_null
   )*
;

ids_impersonation_profile_null
:
   NO?
   (
      DETECT_AP_IMPERSONATION
      | DETECT_BEACON_WRONG_CHANNEL
      | DETECT_HOTSPOTTER
   ) null_rest_of_line
;

ids_null
:
   NO?
   (
      MANAGEMENT_PROFILE
      | RATE_THRESHOLDS_PROFILE
      | SIGNATURE_PROFILE
      | WMS_LOCAL_SYSTEM_PROFILE
   ) null_rest_of_line
;

ids_profile
:
   PROFILE double_quoted_string NEWLINE
   (
      ids_profile_null
   )*
;

ids_profile_null
:
   NO?
   (
      DOS_PROFILE
      | GENERAL_PROFILE
      | SIGNATURE_MATCHING_PROFILE
      | IMPERSONATION_PROFILE
      | UNAUTHORIZED_DEVICE_PROFILE
   ) null_rest_of_line
;

ids_signature_matching_profile
:
   SIGNATURE_MATCHING_PROFILE double_quoted_string NEWLINE
   (
      ids_signature_matching_profile_null
   )*
;

ids_signature_matching_profile_null
:
   NO?
   (
      SIGNATURE
   ) null_rest_of_line
;

ids_unauthorized_device_profile
:
   UNAUTHORIZED_DEVICE_PROFILE double_quoted_string NEWLINE
   (
      ids_unauthorized_device_profile_null
   )*
;

ids_unauthorized_device_profile_null
:
   NO?
   (
      DETECT_ADHOC_NETWORK
      | DETECT_BAD_WEP
      | DETECT_HT_GREENFIELD
      | DETECT_INVALID_MAC_OUI
      | DETECT_MISCONFIGURED_AP
      | DETECT_VALID_SSID_MISUSE
      | DETECT_WIRELESS_BRIDGE
      | DETECT_WIRELESS_HOSTED_NETWORK
      | PRIVACY
      | PROTECT_SSID
      | PROTECT_VALID_STA
      | REQUIRE_WPA
      | SUSPECT_ROGUE_CONF_LEVEL
      | VALID_AND_PROTECTED_SSID
   ) null_rest_of_line
;

ids_wms_general_profile
:
   WMS_GENERAL_PROFILE NEWLINE
   (
      ids_wms_general_profile_null
   )*
;

ids_wms_general_profile_null
:
   NO?
   (
      COLLECT_STATS
   ) null_rest_of_line
;

ifmap_null
:
   NO?
   (
      ENABLE
   ) null_rest_of_line
;

iimgp_stanza
:
   allow_iimgp_stanza
;

imgp_stanza
:
   interface_imgp_stanza
   | null_imgp_stanza
;

inband_mgp_stanza
:
   (
      INBAND
      | OUT_OF_BAND
   ) NEWLINE imgp_stanza*
;

interface_imgp_stanza
:
   INTERFACE null_rest_of_line iimgp_stanza*
;

interface_multicast_stanza
:
   INTERFACE interface_name NEWLINE interface_multicast_tail*
;

interface_multicast_tail
:
   (
      BOUNDARY
      | BSR_BORDER
      | DISABLE
      | DR_PRIORITY
      | ENABLE
      | ROUTER
   ) null_rest_of_line
;

ip_as_path_regex_mode_stanza
:
   IP AS_PATH REGEX_MODE
   (
      ASN
      | STRING
   ) NEWLINE
;

ip_dhcp_null
:
   (
      EXCLUDED_ADDRESS
      | PACKET
      | SMART_RELAY
      | SNOOPING
      | USE
   ) null_rest_of_line
;

ip_dhcp_pool
:
   POOL name = variable NEWLINE
   (
      ip_dhcp_pool_null
   )*
;

ip_dhcp_pool_null
:
   NO?
   (
      AUTHORITATIVE
      | BOOTFILE
      | CLIENT_IDENTIFIER
      | CLIENT_NAME
      | DEFAULT_ROUTER
      | DNS_SERVER
      | DOMAIN_NAME
      | HARDWARE_ADDRESS
      | HOST
      | LEASE
      | NETWORK
      | NEXT_SERVER
      | OPTION
   ) null_rest_of_line
;

ip_dhcp_relay
:
   RELAY
   (
      NEWLINE
      | ip_dhcp_relay_null
      | ip_dhcp_relay_server
   )
;

ip_dhcp_relay_null
:
   (
      ALWAYS_ON
      | INFORMATION
      | OPTION
      | SOURCE_ADDRESS
      | SOURCE_INTERFACE
      | SUB_OPTION
      | USE_LINK_ADDRESS
   ) null_rest_of_line
;

ip_dhcp_relay_server
:
   SERVER
   (
      ip = IP_ADDRESS
      | ip6 = IPV6_ADDRESS
   ) NEWLINE
;

ip_domain_lookup
:
   LOOKUP
   (VRF vrf = vrf_name)?
   (SOURCE_INTERFACE iname = interface_name)?
   NEWLINE
;

ip_domain_name
:
   NAME
   (VRF vrf = vrf_name)?
   hostname = variable_hostname NEWLINE
;

ip_domain_null
:
   (
      LIST
   ) null_rest_of_line
;

ip_nat_null
:
   IP NAT (
      LOG
      | TRANSLATION
   ) null_rest_of_line
;

ip_nat_pool
:
   IP NAT POOL name = variable first = IP_ADDRESS last = IP_ADDRESS
   (
      NETMASK mask = IP_ADDRESS
      | PREFIX_LENGTH prefix_length = dec
   )? NEWLINE
;

ip_nat_pool_range
:
   IP NAT POOL name = variable PREFIX_LENGTH prefix_length = dec NEWLINE
   (
      RANGE first = IP_ADDRESS last = IP_ADDRESS NEWLINE
   )+
;

ip_probe_null
:
   NO?
   (
      BURST_SIZE
      | FREQUENCY
      | MODE
      | RETRIES
   ) null_rest_of_line
;

ip_route_nexthop
:
   null0 = NULL0
   | nexthopip = IP_ADDRESS
   | nexthopint = interface_name_unstructured (nexthopip = IP_ADDRESS)?
;

ip_route_track_bfd: TRACK BFD;

s_ip_route
:
  ROUTE (VRF vrf = vrf_name)? prefix = ip_prefix nh = ip_route_nexthop
   (
     distance = protocol_distance
     | NAME variable
     | TAG tag = uint32
     | track = ip_route_track_bfd
   )* NEWLINE
;

no_ip_route
:
  ROUTE (VRF vrf = vrf_name)? prefix = ip_prefix
  (nh = ip_route_nexthop)?
  (distance = protocol_distance)?
  NEWLINE
;

no_ip_routing: ROUTING (VRF name = variable)? NEWLINE;

ip_sla_null
:
   NO?
   (
      FREQUENCY
      | HISTORY
      | HOPS_OF_STATISTICS_KEPT
      | ICMP_ECHO
      | OWNER
      | PATH_ECHO
      | PATHS_OF_STATISTICS_KEPT
      | REQUEST_DATA_SIZE
      | SAMPLES_OF_HISTORY_KEPT
      | TAG
      | THRESHOLD
      | TIMEOUT
      | TOS
      | UDP_JITTER
   ) null_rest_of_line
;

ip_ssh_null
:
   (
      AUTHENTICATION_RETRIES
      | CLIENT
      | LOGGING
      | MAXSTARTUPS
      | PORT
      | RSA
      | SERVER
      |
      (
         NO SHUTDOWN
      )
      | SOURCE_INTERFACE
      | TIME_OUT
   ) null_rest_of_line
;

ip_ssh_pubkey_chain
:
   PUBKEY_CHAIN NEWLINE
   (
      (
         KEY_HASH
         | QUIT
         | USERNAME
      ) null_rest_of_line
   )+
;

ip_ssh_version
:
   VERSION version = dec NEWLINE
;

ipc_association
:
   ASSOCIATION null_rest_of_line
   (
      ipca_null
   )*
;

ipca_null
:
   NO?
   (
      ASSOC_RETRANSMIT
      | LOCAL_IP
      | LOCAL_PORT
      | PATH_RETRANSMIT
      | PROTOCOL
      | REMOTE_IP
      | REMOTE_PORT
      | RETRANSMIT_TIMEOUT
      | SHUTDOWN
   ) null_rest_of_line
;

ipdg_address
:
   ip = IP_ADDRESS NEWLINE
;

ipdg_null
:
   (
      IMPORT
   ) null_rest_of_line
;

ispla_operation
:
   NO? OPERATION null_rest_of_line
   (
      ipslao_type
   )*
;

ipsla_reaction
:
   NO? REACTION null_rest_of_line
   (
      ipslar_react
   )*
;

ipsla_responder
:
   NO? RESPONDER null_rest_of_line
   (
      ipslarp_null
   )*
;

ipsla_schedule
:
   NO? SCHEDULE null_rest_of_line
   (
      ipslas_null
   )*
;

ipslao_type
:
   NO? TYPE null_rest_of_line
   (
      ipslaot_null
      | ipslaot_statistics
   )*
;

ipslaot_null
:
   NO?
   (
      DESTINATION
      | FREQUENCY
      | SOURCE
      | TIMEOUT
      | TOS
      | VERIFY_DATA
   ) null_rest_of_line
;

ipslaot_statistics
:
   NO? STATISTICS null_rest_of_line
   (
      ipslaots_null
   )*
;

ipslaots_null
:
   NO?
   (
      BUCKETS
   ) null_rest_of_line
;

ipslar_react
:
   NO? REACT null_rest_of_line
   (
      ispalrr_null
   )*
;

ipslarp_null
:
   NO?
   (
      TYPE
   ) null_rest_of_line
;

ispalrr_null
:
   NO?
   (
      ACTION
      | THRESHOLD
   ) null_rest_of_line
;

ipslas_null
:
   NO?
   (
      LIFE
      | START_TIME
   ) null_rest_of_line
;

l2_null
:
   NO?
   (
      BRIDGE_DOMAIN
      | MTU
      | NEIGHBOR
      | VPN
   ) null_rest_of_line
;

l2tpc_null
:
   NO? DEFAULT?
   (
      AUTHENTICATION
      | COOKIE
      | HELLO
      | HIDDEN_LITERAL
      | HOSTNAME
      | PASSWORD
      | RECEIVE_WINDOW
      | RETRANSMIT
      | TIMEOUT
   ) null_rest_of_line
;

l2vpn_bridge_group
:
   BRIDGE GROUP name = variable NEWLINE
   (
      lbg_bridge_domain
   )*
;

l2vpn_logging
:
   LOGGING NEWLINE
   (
      (
         BRIDGE_DOMAIN
         | PSEUDOWIRE
         | VFI
      ) NEWLINE
   )+
;

l2vpn_xconnect
:
   XCONNECT GROUP variable NEWLINE
   (
      l2vpn_xconnect_p2p
   )*
;

l2vpn_xconnect_p2p
:
   NO? P2P null_rest_of_line
   (
      lxp_neighbor
      | lxp_null
   )*
;

lbg_bridge_domain
:
   BRIDGE_DOMAIN name = variable NEWLINE
   (
      lbgbd_mac
      | lbgbd_null
      | lbgbd_vfi
   )*
;

lbgbd_mac
:
   NO? MAC null_rest_of_line
   (
      lbgbdm_limit
   )*
;

lbgbd_null
:
   NO?
   (
      INTERFACE
      | MTU
      | NEIGHBOR
      | ROUTED
   ) null_rest_of_line
;

lbgbd_vfi
:
   NO? VFI null_rest_of_line
   (
      lbgbdv_null
   )*
;

lbgbdm_limit
:
   NO? LIMIT null_rest_of_line
   (
      lbgbdml_null
   )*
;

lbgbdml_null
:
   NO?
   (
      ACTION
      | MAXIMUM
   ) null_rest_of_line
;

lbgbdv_null
:
   NO?
   (
      NEIGHBOR
   ) null_rest_of_line
;

license_null
:
   NO?
   (
      CENTRALIZED_LICENSING_ENABLE
   ) null_rest_of_line
;

lpts_null
:
   NO?
   (
      FLOW
   ) null_rest_of_line
;

lxp_neighbor
:
   NO? NEIGHBOR null_rest_of_line
   (
      lxpn_l2tp
      | lxpn_null
   )*
;

lxp_null
:
   NO?
   (
      INTERFACE
      | MONITOR_SESSION
   ) null_rest_of_line
;

lxpn_null
:
   NO?
   (
      SOURCE
   ) null_rest_of_line
;

lxpn_l2tp
:
   NO? L2TP null_rest_of_line
   (
      lxpnl_null
   )*
;

lxpnl_null
:
   NO?
   (
      LOCAL
      | REMOTE
   ) null_rest_of_line
;

map_class_null
:
   NO?
   (
      DIALER
   ) null_rest_of_line
;

management_api
:
   API HTTP_COMMANDS NEWLINE
   (
      management_api_null
      | management_api_vrf
   )*
;

management_api_null
:
   NO?
   (
      AUTHENTICATION
      | EXIT
      | IDLE_TIMEOUT
      | PROTOCOL
      | SHUTDOWN
   ) null_rest_of_line
;

management_api_vrf
:
   VRF name = vrf_name NEWLINE
   (
      management_api_vrf_null
   )*
;

management_api_vrf_null
:
   NO?
   (
      SHUTDOWN
   ) null_rest_of_line
;

management_console
:
   CONSOLE NEWLINE
   (
      management_console_null
   )*
;

management_console_null
:
   NO?
   (
      IDLE_TIMEOUT
   ) null_rest_of_line
;

management_cvx
:
   CVX NEWLINE
   (
      management_cvx_null
   )*
   (
      EXIT NEWLINE
   )?
;

management_cvx_null
:
   NO?
   (
      SERVER
      | SHUTDOWN
   ) null_rest_of_line
;

management_egress_interface_selection
:
   MANAGEMENT EGRESS_INTERFACE_SELECTION NEWLINE
   (
      management_egress_interface_selection_null
   )*
   (
      EXIT NEWLINE
   )?
;

management_egress_interface_selection_null
:
   NO?
   (
      APPLICATION
   ) null_rest_of_line
;

management_ssh
:
   SSH NEWLINE
   management_ssh_inner*
;

management_ssh_inner:
  management_ssh_ip_access_group
  | management_ssh_null
  | management_ssh_vrf
;

management_ssh_ip_access_group
:
   IP ACCESS_GROUP acl=variable (VRF vrf=variable)? (IN | OUT) NEWLINE
;

management_ssh_null
:
   NO?
   (
      AUTHENTICATION
      | IDLE_TIMEOUT
      | SHUTDOWN
   ) null_rest_of_line
;

management_ssh_vrf:
  VRF name=variable NEWLINE
  management_ssh_vrf_inner*
;

management_ssh_vrf_inner
:
  management_ssh_vrf_no
;

management_ssh_vrf_no: NO SHUTDOWN NEWLINE;

management_telnet
:
   TELNET NEWLINE
   (
      management_telnet_ip_access_group
      | management_telnet_null
   )*
;

management_telnet_ip_access_group
:
   IP ACCESS_GROUP name = variable
   (
      IN
      | OUT
   ) NEWLINE
;

management_telnet_null
:
   NO?
   (
      IDLE_TIMEOUT
      | SHUTDOWN
   ) null_rest_of_line
;

mgp_stanza
:
   inband_mgp_stanza
;

monitor_destination
:
   NO? DESTINATION null_rest_of_line
   (
      monitor_destination_null
   )*
;

monitor_destination_null
:
   NO?
   (
      ERSPAN_ID
      | IP
      | MTU
      | ORIGIN
   ) null_rest_of_line
;

monitor_null
:
   NO?
   (
      BUFFER_SIZE
      | DESCRIPTION
      | SHUTDOWN
      | SOURCE
   ) null_rest_of_line
;

monitor_session_null
:
   NO?
   (
      DESTINATION
   ) null_rest_of_line
;

mp_null
:
   NO?
   (
      CONNECT_SOURCE
      | DESCRIPTION
      | MESH_GROUP
      | REMOTE_AS
      | SHUTDOWN
   ) null_rest_of_line
;

mt_null
:
   NO?
   (
      ADDRESS
   ) null_rest_of_line
;

multicast_routing_stanza
:
   MULTICAST_ROUTING NEWLINE
   (
      address_family_multicast_stanza
   )*
;

no_aaa_group_server_stanza
:
   NO AAA GROUP SERVER null_rest_of_line
;

no_failover
:
   NO FAILOVER NEWLINE
;

no_ip_access_list_stanza
:
   NO IP ACCESS_LIST null_rest_of_line
;

null_af_multicast_tail
:
   NSF NEWLINE
;

null_imgp_stanza
:
   NO?
   (
      VRF
   ) null_rest_of_line
;

nv_satellite
:
   NO?
   (
      SATELLITE
   ) null_rest_of_line
   (
      nvs_null
   )*
;

nvs_null
:
   NO?
   (
      DESCRIPTION
      | IP
      | SERIAL_NUMBER
      | TYPE
   ) null_rest_of_line
;

of_null
:
   NO?
   (
      BIND
      | CONTROLLER
      | DEFAULT_ACTION
      | DESCRIPTION
      | ENABLE
   ) null_rest_of_line
;

peer_sa_filter
:
   SA_FILTER
   (
      IN
      | OUT
   )
   (
      LIST
      | RP_LIST
   ) name = variable NEWLINE
;

peer_stanza
:
   PEER IP_ADDRESS NEWLINE
   (
      mp_null
      | peer_sa_filter
   )*
;

phone_proxy_null
:
   NO?
   (
      CIPC
      | CTL_FILE
      | DISABLE
      | MEDIA_TERMINATION
      | PROXY_SERVER
      | TFTP_SERVER
      | TLS_PROXY
   ) null_rest_of_line
;

qm_length
:
   LENGTH null_rest_of_line
;

qm_streaming
:
   STREAMING NEWLINE
   (
      qms_null
   )*
;

qms_null
:
   NO?
   (
      MAX_CONNECTIONS
      | SHUTDOWN
   ) null_rest_of_line
;

redundancy_linecard_group
:
   LINECARD_GROUP null_rest_of_line
   (
      rlcg_null
   )*
;

redundancy_main_cpu
:
   MAIN_CPU null_rest_of_line
   (
      redundancy_main_cpu_null
   )*
;

redundancy_main_cpu_null
:
   NO?
   (
      AUTO_SYNC
   ) null_rest_of_line
;

redundancy_null
:
   NO?
   (
      KEEPALIVE_ENABLE
      | MODE
      | NOTIFICATION_TIMER
      | PROTOCOL
      | SCHEME
   ) null_rest_of_line
;

rf_arm_profile
:
   ARM_PROFILE double_quoted_string NEWLINE
   (
      rf_arm_profile_null
   )*
;

rf_arm_profile_null
:
   NO?
   (
      ASSIGNMENT
      | BACKOFF_TIME
      | ERROR_RATE_THRESHOLD
      | FREE_CHANNEL_INDEX
      | IDEAL_COVERAGE_INDEX
      | MAX_TX_POWER
      | MIN_TX_POWER
      | ROGUE_AP_AWARE
      | SCANNING
   ) null_rest_of_line
;

rf_null
:
   NO?
   (
      AM_SCAN_PROFILE
      | ARM_RF_DOMAIN_PROFILE
      | EVENT_THRESHOLDS_PROFILE
      | OPTIMIZATION_PROFILE
   ) null_rest_of_line
;

rf_dot11a_radio_profile
:
   DOT11A_RADIO_PROFILE double_quoted_string NEWLINE
   (
      rf_dot11a_radio_profile_null
   )*
;

rf_dot11a_radio_profile_null
:
   NO?
   (
      ARM_PROFILE
      | MODE
      | SPECTRUM_LOAD_BALANCING
      | SPECTRUM_MONITORING
   ) null_rest_of_line
;

rf_dot11g_radio_profile
:
   DOT11G_RADIO_PROFILE double_quoted_string NEWLINE
   (
      rf_dot11g_radio_profile_null
   )*
;

rf_dot11g_radio_profile_null
:
   NO?
   (
      ARM_PROFILE
      | MODE
      | SPECTRUM_LOAD_BALANCING
      | SPECTRUM_MONITORING
   ) null_rest_of_line
;

rlcg_null
:
   NO?
   (
      MEMBER
      | MODE
      | REVERTIVE
      | RF_SWITCH
   ) null_rest_of_line
;

rmc_null
:
   NO?
   (
      MAXIMUM
   ) null_rest_of_line
;

router_multicast_stanza
:
   IPV6? ROUTER
   (
      IGMP
      | MLD
      | MSDP
   ) NEWLINE router_multicast_tail
;

router_multicast_tail
:
   (
      address_family_multicast_stanza
      |
      (
         INTERFACE ALL null_rest_of_line
      )
      | interface_multicast_stanza
      | peer_stanza
      | rmc_null
   )*
;

s_access_line
:
   (
      linetype = HTTP
      | linetype = SSH
      | linetype = TELNET
   ) allowed_ip
;

s_airgroupservice
:
   AIRGROUPSERVICE null_rest_of_line
   (
      ags_null
   )*
;

s_ap
:
   AP
   (
      ap_null
      | ap_regulatory_domain_profile
      | ap_system_profile
   )
;

s_ap_group
:
   AP_GROUP double_quoted_string NEWLINE
   (
      apg_null
   )*
;

s_ap_name
:
   AP_NAME double_quoted_string NEWLINE
   (
      apn_null
   )*
;

s_application
:
   APPLICATION NEWLINE SERVICE name = variable null_rest_of_line
   (
      PARAM null_rest_of_line
   )*
   (
      GLOBAL NEWLINE SERVICE name = variable null_rest_of_line
   )?
;

s_application_var
:
   APPLICATION name = variable NEWLINE
   (
      av_null
   )*
;

s_archive
:
   ARCHIVE null_rest_of_line
   (
      archive_log
      | archive_null
   )*
;

s_authentication
:
   AUTHENTICATION null_rest_of_line
;

s_banner_eos
:
  BANNER type = eos_banner_type NEWLINE body = BANNER_BODY? BANNER_DELIMITER_EOS // delimiter includes newline
;

eos_banner_type
:
  EXEC
  | LOGIN
  | MOTD
;

s_bfd
:
   BFD null_rest_of_line
   (
      bfd_null
   )*
;

s_bfd_template
:
  BFD_TEMPLATE SINGLE_HOP name = variable_permissive NEWLINE bfd_template_null*
;

s_boot
:
  BOOT null_rest_of_line
;

s_cluster
:
   NO? CLUSTER
   (
      ENABLE
      | RUN
   ) null_rest_of_line
;

s_call_manager_fallback
:
   NO? CALL_MANAGER_FALLBACK NEWLINE
   (
      cmf_null
   )+
;

s_configure
:
   NO? CONFIGURE
   (
      configure_maintenance
      | configure_null
   )
;

s_control_plane
:
   CONTROL_PLANE
   (
      SLOT dec
   )? NEWLINE s_control_plane_tail*
;

s_control_plane_tail
:
   cp_ip_access_group
   | cp_ip_flow
   | cp_management_plane
   | cp_null
   | cp_service_policy
;

s_control_plane_security
:
   CONTROL_PLANE_SECURITY NEWLINE
   (
      cps_null
   )*
;

s_cops
:
   COPS
   (
      cops_listener
   )
;

s_cos_queue_group
:
   COS_QUEUE_GROUP null_rest_of_line
   (
      cqg_null
   )*
;

s_ctl_file
:
   NO? CTL_FILE null_rest_of_line
   (
      ctlf_null
   )*
;

s_daemon
:
   DAEMON null_rest_of_line
   (
      daemon_null
   )*
;

s_default
:
  DEFAULT
  (
    default_ip
    | sdef_hardware
    | default_mac
    | default_snmp_server
    | default_vlan_internal
  )
;

default_ip
:
  IP default_ip_igmp
;

sdef_hardware
:
  HARDWARE null_rest_of_line
;

s_dhcp
:
   NO? DHCP null_rest_of_line
   (
      dhcp_null
      | dhcp_profile
   )*
;

s_dialer
:
   DIALER
   (
      dialer_group
      | dialer_null
   )
;

s_dial_peer
:
   DIAL_PEER null_rest_of_line
   (
      NO?
      (
         CALL_BLOCK
         | CODEC
         | DESCRIPTION
         | DESTINATION_PATTERN
         | DIRECT_INWARD_DIAL
         | DTMF_RELAY
         | FAX
         | FORWARD_DIGITS
         | INCOMING
         |
         (
            IP
            (
               QOS
            )
         )
         | MEDIA
         | PORT
         | PREFERENCE
         | PREFIX
         | PROGRESS_IND
         | SERVICE
         | SESSION
         | SHUTDOWN
         | SIGNALING
         | TRANSLATION_PROFILE
         | VAD
         | VOICE_CLASS
      ) null_rest_of_line
   )*
;

s_domain
:
   DOMAIN
   (
      VRF vrf = vrf_name
   )?
   (
      domain_lookup
      | domain_name
      | domain_name_server
   )
;

s_domain_name
:
   DOMAIN_NAME hostname = variable_hostname NEWLINE
;

s_dot11
:
   DOT11 null_rest_of_line
   (
      d11_null
   )*
;

s_dspfarm
:
   NO? DSPFARM null_rest_of_line
   (
      dspf_null
   )*
;

s_dynamic_access_policy_record
:
   NO? DYNAMIC_ACCESS_POLICY_RECORD null_rest_of_line
   (
      dapr_null
      | dapr_webvpn
   )*
;

s_enable
:
   ENABLE
   (
      enable_null
      | enable_password
      | enable_secret
   )
;

s_end
:
  // in principle, this terminates the file. But since we want to have incremental patches appended
  // we will just parse and ignore.
  END NEWLINE
;

s_ephone_dn_template
:
   EPHONE_DN_TEMPLATE null_rest_of_line
   (
      ednt_null
   )*
;

s_errdisable
:
  ERRDISABLE null_rest_of_line
;

s_event
:
   NO? EVENT null_rest_of_line
   (
      event_null
   )*
;

s_event_handler
:
   NO? EVENT_HANDLER null_rest_of_line
   (
      eh_null
   )*
;

s_event_monitor
:
   EVENT_MONITOR NEWLINE
;

s_flow
:
   FLOW
   (
      EXPORTER
      | EXPORTER_MAP
      | HARDWARE
      | MONITOR
      | MONITOR_MAP
      | PLATFORM
      | RECORD
   ) null_rest_of_line
   (
      flow_null
      | flow_version
   )*
;

s_flow_sampler_map
:
   NO? FLOW_SAMPLER_MAP null_rest_of_line fsm_mode?
;

fsm_mode
:
   MODE RANDOM ONE_OUT_OF dec NEWLINE
;

s_global_port_security
:
   GLOBAL_PORT_SECURITY NEWLINE
   (
      gpsec_null
   )*
;

s_guest_access_email
:
   GUEST_ACCESS_EMAIL NEWLINE
   (
      gae_null
   )*
;

s_hardware
:
  HARDWARE null_rest_of_line
;

s_hostname
:
   (
      HOSTNAME
      | SWITCHNAME
   )
   (
      quoted_name = double_quoted_string
      |
      (
         (
            name_parts += ~NEWLINE
         )+
      )
   ) NEWLINE
;

s_ids
:
   IDS
   (
      ids_ap_classification_rule
      | ids_ap_rule_matching
      | ids_dos_profile
      | ids_general_profile
      | ids_impersonation_profile
      | ids_null
      | ids_profile
      | ids_signature_matching_profile
      | ids_unauthorized_device_profile
      | ids_wms_general_profile
   )
;

s_ifmap
:
   IFMAP null_rest_of_line
   (
      ifmap_null
   )*
;

s_interface_line
:
   NO? INTERFACE BREAKOUT null_rest_of_line
;

s_ip
:
  IP
  (
    s_ip_access_list
    | s_ip_as_path
    | s_ip_domain_name
    | s_ip_igmp
    | s_ip_name_server
    | s_ip_nbar
    | s_ip_pim
    | s_ip_probe
    | s_ip_route
    | s_ip_routing
    | s_ip_tacacs_source_interface
    | s_ip_virtual_router
  )
;

s_ip_default_gateway
:
   NO? IP DEFAULT_GATEWAY
   (
      ipdg_address
      | ipdg_null
   )
;

s_ip_dhcp
:
   NO?
   (
      IP
      | IPV6
   ) DHCP
   (
      ip_dhcp_null
      | ip_dhcp_pool
      | ip_dhcp_relay
   )
;

s_ip_domain
:
   NO? IP DOMAIN
   (
      ip_domain_lookup
      | ip_domain_name
      | ip_domain_null
   )
;

s_ip_domain_name
:
   DOMAIN_NAME hostname = variable_hostname NEWLINE
;

s_ip_name_server
:
   NAME_SERVER
     (VRF vrf = vrf_name)?
     (hostnames += ip_hostname)+
     NEWLINE
;

s_ip_nat
:
   ip_nat_null
   | ip_nat_pool
   | ip_nat_pool_range
;

s_ip_nbar
:
   NBAR CUSTOM null_rest_of_line
;

s_ip_probe
:
   PROBE null_rest_of_line
   (
      ip_probe_null
   )*
;

s_ip_routing
:
  ROUTING (VRF name = vrf_name)? NEWLINE
;

s_ip_sla
:
   NO? IP SLA null_rest_of_line
   (
      ip_sla_null
   )*
;

s_ip_source_route
:
   NO? IP SOURCE_ROUTE NEWLINE
;

s_ip_ssh
:
   NO? IP SSH
   (
      ip_ssh_pubkey_chain
      | ip_ssh_version
      | ip_ssh_null
   )
;

s_ip_tacacs_source_interface
:
   TACACS
     (VRF vrf = vrf_name)?
     SOURCE_INTERFACE iname = interface_name
     NEWLINE
;

s_ip_virtual_router
:
  VIRTUAL_ROUTER MAC_ADDRESS null_rest_of_line
;

s_ipc
:
   IPC null_rest_of_line
   (
      ipc_association
   )*
;

s_ipv6
:
  IPV6
  ipv6_route
;

ipv6_route
:
  ROUTE prefix = ipv6_prefix null_rest_of_line
;

s_ipsla
:
   NO? IPSLA null_rest_of_line
   (
      ispla_operation
      | ipsla_reaction
      | ipsla_responder
      | ipsla_schedule
   )*
;

s_l2
:
   NO? L2 null_rest_of_line
   (
      l2_null
   )*
;

s_l2tp_class
:
   NO? L2TP_CLASS name = variable NEWLINE
   (
      l2tpc_null
   )*
;

s_l2vpn
:
   NO? L2VPN null_rest_of_line
   (
      l2vpn_bridge_group
      | l2vpn_logging
      | l2vpn_xconnect
   )*
;

s_license
:
   NO? LICENSE null_rest_of_line
   (
      license_null
   )*
;

s_lpts
:
   NO? LPTS null_rest_of_line
   (
      lpts_null
   )*
;

s_management
:
   MANAGEMENT
   (
      management_api
      | management_console
      | management_cvx
      | management_egress_interface_selection
      | management_ssh
      | management_telnet
   )
;

s_map_class
:
   NO? MAP_CLASS null_rest_of_line
   (
      map_class_null
   )*
;

s_media_termination
:
   NO? MEDIA_TERMINATION null_rest_of_line
   (
      mt_null
   )*
;

s_monitor
:
   NO? MONITOR null_rest_of_line
   (
      monitor_destination
      | monitor_null
   )*
;

s_monitor_session
:
   NO? MONITOR_SESSION null_rest_of_line
   (
      monitor_session_null
   )*
;

s_name
:
   NAME variable variable null_rest_of_line
;

s_no
:
  NO
  (
    no_aaa
    | no_errdisable
    | no_ip
    | no_logging
    | no_mac
    | no_router
    | no_snmp_server
    | no_vlan
    | no_vlan_internal
  )
;

no_errdisable
:
  ERRDISABLE null_rest_of_line
;

no_ip
:
  IP
  (
    no_ip_igmp
    | no_ip_route
    | no_ip_routing
  )
;

no_router
:
   ROUTER s_no_router_ospf
;


s_no_bfd
:
   NO BFD null_rest_of_line
;

s_no_enable
:
   NO ENABLE PASSWORD (LEVEL level = dec)? NEWLINE
;

s_nv
:
   NO? NV NEWLINE
   (
      nv_satellite
   )*
;

s_openflow
:
   NO? OPENFLOW null_rest_of_line
   (
      of_null
   )*
;

s_passwd
:
   NO? PASSWD pass = variable ENCRYPTED? NEWLINE
;

s_peer_filter
:
   PEER_FILTER name = WORD NEWLINE
   (
      peer_filter_line
   )*
;

peer_filter_line
:
   (seq = dec)? MATCH
   AS_RANGE asn_range = eos_as_range RESULT action = (ACCEPT | REJECT)
   NEWLINE
;

s_phone_proxy
:
   NO? PHONE_PROXY null_rest_of_line
   (
      phone_proxy_null
   )*
;

s_privilege
:
   NO? PRIVILEGE
   (
      CLEAR
      | CMD
      | CONFIGURE
      | EXEC
      | INTERFACE
      | IPENACL
      | ROUTER
      | SHOW
   ) null_rest_of_line
;

s_process_max_time
:
   NO? PROCESS_MAX_TIME dec NEWLINE
;

s_queue_monitor
:
   QUEUE_MONITOR
   (
      qm_length
      | qm_streaming
   )
;

s_radius_server
:
   RADIUS SERVER name = variable NEWLINE
   (
      (
         ADDRESS
         | KEY
         | RETRANSMIT
         | TIMEOUT
      ) null_rest_of_line
   )+
;

s_redundancy
:
   NO? REDUNDANCY null_rest_of_line
   (
      redundancy_linecard_group
      | redundancy_main_cpu
      | redundancy_null
   )*
;

s_rf
:
   RF
   (
      rf_arm_profile
      | rf_null
      | rf_dot11a_radio_profile
      | rf_dot11g_radio_profile
   )
;

s_role
:
   NO? ROLE null_rest_of_line
;

s_router
:
  ROUTER (
    router_bgp_stanza
    | router_isis_stanza
    | s_router_multicast
    | s_router_ospf
    | s_router_ospfv3
    | s_router_pim
    | s_router_rip
    | s_router_vrrp
  )
;

s_router_vrrp
:
   VRRP NEWLINE
   (
      vrrp_interface
   )*
;

s_sccp
:
   NO? SCCP null_rest_of_line
   (
      sccp_null
   )*
;

s_service
:
   NO? SERVICE
   (
      words += variable
   )+ NEWLINE
;

s_service_policy_global
:
   SERVICE_POLICY name = variable GLOBAL NEWLINE
;

s_sip_ua
:
   SIP_UA NEWLINE
   (
      sip_ua_null
   )*
;

s_sntp
:
   SNTP sntp_server
;

s_spanning_tree
:
   NO? SPANNING_TREE
   (
      spanning_tree_mst
      | spanning_tree_portfast
      | spanning_tree_pseudo_information
      | spanning_tree_null
      | NEWLINE
   )
;

s_statistics
:
   NO? STATISTICS null_rest_of_line
   (
      statistics_null
   )*
;

s_stcapp
:
   STCAPP null_rest_of_line
   (
      (
         CALL
         | CPTONE
         | FALLBACK_DN
         | PICKUP
         | PORT
         | PREFIX
      ) null_rest_of_line
   )*
;

s_switchport
:
   SWITCHPORT DEFAULT MODE
   (
      ACCESS
      | ROUTED
   ) NEWLINE
;

s_system
:
   NO? SYSTEM
   (
      system_default
      | system_null
      | system_qos
   )
   s_system_inner*
;

s_system_inner
:
   s_system_service_policy
;

s_system_service_policy
:
   SERVICE_POLICY TYPE QUEUING (INPUT | OUTPUT) policy_map = variable NEWLINE
;

s_tacacs_server
:
   NO? TACACS_SERVER
   (
      ts_common
      | ts_host
      |
      (
         ts_host ts_common*
      )
   )
;

s_tap
:
   NO? TAP null_rest_of_line
   (
      tap_null
   )*
;

s_telephony_service
:
   TELEPHONY_SERVICE null_rest_of_line
   (
      telephony_service_null
   )*
;

s_template
:
  TEMPLATE null_rest_of_line
  (
    template_null
  )*
;

s_time_range
:
   TIME_RANGE name = variable PERIODIC? NEWLINE
   (
      tr_null
   )*
;

s_track
:
  TRACK name = variable
  (
    track_block
    | track_interface
    | track_list
  )
;

s_tunnel_group
:
   NO? TUNNEL_GROUP null_rest_of_line
   (
      tg_null
   )*
;

s_user_role
:
   USER_ROLE name = variable_permissive NEWLINE
   (
      ur_access_list
      | ur_null
   )*
;

s_username
:
   USERNAME
   (
      quoted_user = double_quoted_string
      | user = variable
   )
   (
      (
         u+ NEWLINE
      )
      |
      (
         NEWLINE
         (
            u NEWLINE
         )*
      )
   )
;

s_username_attributes
:
   USERNAME user = variable ATTRIBUTES NEWLINE
   (
      ua_null
   )*
;

s_vpc
:
   NO? VPC null_rest_of_line
   (
      vpc_null
   )*
;

s_vpdn_group
:
   NO? VPDN_GROUP null_rest_of_line
   (
      vpdng_accept_dialin
      | vpdng_null
   )*
;

s_vpn
:
   NO? VPN null_rest_of_line
   (
      vpn_null
   )*
;

s_vpn_dialer
:
   VPN_DIALER name = variable NEWLINE
   (
      vpn_dialer_null
   )*
;

// a way to define a VRF on EOS
s_vrf_definition
:
   // DEFINITION is for IOS and older versions of EOS (pre-4.23)
   // INSTANCE is for EOS 4.23 and later
   VRF (DEFINITION | INSTANCE) name = vrf_name NEWLINE
   (
      vrfd_description
      | vrfd_rd
   )*
;

s_web_server
:
   WEB_SERVER PROFILE NEWLINE
   (
      web_server_null
   )*
;

s_webvpn
:
   NO? WEBVPN null_rest_of_line
   (
      webvpn_null
   )*
;

s_wlan
:
   WLAN
   (
      wlan_null
      | wlan_ssid_profile
      | wlan_virtual_ap
   )
;

s_wsma
:
   WSMA null_rest_of_line
   (
      wsma_null
   )*
;

s_xconnect_logging
:
   NO? XCONNECT LOGGING null_rest_of_line
;

sccp_null
:
   NO?
   (
      ASSOCIATE
      | BIND
      | DESCRIPTION
      | SWITCHBACK
   ) null_rest_of_line
;

sd_null
:
   (
      DCE_MODE
      | INTERFACE
      | LINK_FAIL
   ) null_rest_of_line
;

sd_switchport
:
   SWITCHPORT
   (
      sd_switchport_blank
      | sd_switchport_null
      | sd_switchport_shutdown
   )
;

sd_switchport_blank
:
   NEWLINE
;

sd_switchport_null
:
   (
      FABRICPATH
      | MONITOR
   ) null_rest_of_line
;

sd_switchport_shutdown
:
   SHUTDOWN NEWLINE
;

sip_ua_null
:
   NO?
   (
      CONNECTION_REUSE
      | RETRY
      | SET
      | SIP_SERVER
      | TIMERS
   ) null_rest_of_line
;

sntp_server
:
   SERVER hostname = variable
   (
      VERSION version = dec
   )? NEWLINE
;

spanning_tree_mst
:
   MST null_rest_of_line spanning_tree_mst_null*
;

spanning_tree_mst_null
:
   NO?
   (
      INSTANCE
      | NAME
      | REVISION
   ) null_rest_of_line
;

spanning_tree_portfast
:
   PORTFAST
   (
      bpdufilter = BPDUFILTER
      | bpduguard = BPDUGUARD
      | defaultLiteral = DEFAULT
      | edge = EDGE
   )* NEWLINE
;

spanning_tree_pseudo_information
:
   PSEUDO_INFORMATION NEWLINE
   (
      spti_null
   )*
;

spanning_tree_null
:
   (
      BACKBONEFAST
      | BPDUFILTER
      | BRIDGE
      | COST
      | DISPUTE
      | ETHERCHANNEL
      | EXTEND
      | FCOE
      | GUARD
      | LOGGING
      | LOOPGUARD
      | MODE
      | OPTIMIZE
      | PATHCOST
      | PORT
      | UPLINKFAST
      | VLAN
   ) null_rest_of_line
;

spti_null
:
   NO?
   (
      MST
   ) null_rest_of_line
;

srlg_interface_numeric_stanza
:
   dec null_rest_of_line
;

srlg_interface_stanza
:
   INTERFACE null_rest_of_line srlg_interface_numeric_stanza*
;

srlg_stanza
:
   SRLG NEWLINE srlg_interface_stanza*
;

stanza
:
   del_stanza
   | extended_ipv6_access_list_stanza
   | ip_as_path_regex_mode_stanza
   | ip_community_list_expanded_stanza
   | ip_community_list_standard_stanza
   | ip_prefix_list_stanza
   | ipv6_prefix_list_stanza
   | multicast_routing_stanza
   | no_aaa_group_server_stanza
   | no_failover
   | no_ip_access_list_stanza
   | no_ip_prefix_list_stanza
   | no_route_map_stanza
   | route_map_stanza
   | router_multicast_stanza
   | rsvp_stanza
   | s_aaa
   | s_access_line
   | s_airgroupservice
   | s_ap
   | s_ap_group
   | s_ap_name
   | s_application
   | s_application_var
   | s_archive
   | s_arp_access_list_extended
   | s_authentication
   | s_banner_eos
   | s_bfd
   | s_bfd_template
   | s_boot
   | s_call_manager_fallback
   | s_class_map
   | s_cluster
   | s_configure
   | s_control_plane
   | s_control_plane_security
   | s_cops
   | s_cos_queue_group
   | s_crypto
   | s_ctl_file
   | s_cvx
   | s_daemon
   | s_default
   | s_dhcp
   | s_dialer
   | s_dial_peer
   | s_domain
   | s_domain_name
   | s_dot11
   | s_dspfarm
   | s_dynamic_access_policy_record
   | s_email
   | s_enable
   | s_end
   | s_eos_mlag
   | s_ephone_dn_template
   | s_errdisable
   | s_ethernet_services
   | s_event
   | s_event_handler
   | s_event_monitor
   | s_flow
   | s_flow_sampler_map
   | s_global_port_security
   | s_guest_access_email
   | s_hardware
   | s_hostname
   | s_ids
   | s_ifmap
   |
   // do not move below s_interface
   s_interface_line
   | s_eos_vxlan_interface
   | s_interface
   | s_ip
   | s_ip_default_gateway
   | s_ip_dhcp
   | s_ip_domain
   | s_ip_name_server
   | s_ip_nat
   | s_ip_sla
   | s_ip_source_route
   | s_ip_ssh
   | s_ipc
   | s_ipv6
   | s_ipv6_router_ospf
   | s_ipsla
   | s_key
   | s_l2
   | s_l2tp_class
   | s_l2vpn
   | s_license
   | s_logging
   | s_lpts
   | s_mac
   | s_management
   | s_map_class
   | s_media_termination
   | s_monitor
   | s_monitor_session
   | s_mpls_label_range
   | s_mpls_ldp
   | s_mpls_traffic_eng
   | s_name
   | s_netdestination
   | s_netdestination6
   | s_netservice
   | s_no
   | s_no_bfd
   | s_no_enable
   | s_ntp
   | s_nv
   | s_openflow
   | s_passwd
   | s_peer_filter
   | s_phone_proxy
   | s_policy_map
   | s_privilege
   | s_process_max_time
   | s_ptp
   | s_qos_mapping
   | s_queue_monitor
   | s_radius_server
   | s_redundancy
   | s_rf
   | s_role
   | s_router
   | s_sccp
   | s_service
   | s_service_policy_global
   | s_service_template
   | s_sip_ua
   | s_snmp_server
   | s_sntp
   | s_spanning_tree
   | s_statistics
   | s_stcapp
   | s_switchport
   | s_system
   | s_table_map
   | s_tacacs_server
   | s_tap
   | s_telephony_service
   | s_template
   | s_time_range
   | s_track
   | s_tunnel_group
   | s_user_role
   | s_username
   | s_username_attributes
   | s_vlan
   | s_vlan_internal
   | s_vpc
   | s_vpdn_group
   | s_vpn
   | s_vpn_dialer
   | s_vrf_definition
   | s_web_server
   | s_webvpn
   | s_wlan
   | s_wsma
   | s_xconnect_logging
   | srlg_stanza
   | standard_ipv6_access_list_stanza
   | switching_mode_stanza
;

statistics_null
:
   NO?
   (
      EXTENDED_COUNTERS
      | TM_VOQ_COLLECTION
   ) null_rest_of_line
;

switching_mode_stanza
:
   SWITCHING_MODE null_rest_of_line
;

system_default
:
   DEFAULT
   (
      sd_null
      | sd_switchport
   )
;

system_null
:
   (
      ADMIN_VDC
      | AUTO_UPGRADE
      | FABRIC
      | FABRIC_MODE
      | FLOWCONTROL
      | INTERFACE
      | JUMBOMTU
      | MODE
      | MODULE_TYPE
      | MTU
      | ROUTING
      | URPF
      | VLAN
   ) null_rest_of_line
;

system_qos
:
   QOS NEWLINE
   (
      system_qos_null
   )*
;

system_qos_null
:
   NO?
   (
      FEX
      | SERVICE_POLICY
   ) null_rest_of_line
;

t_key
:
   KEY dec? variable_permissive NEWLINE
;

tap_null
:
   NO?
   (
      MODE
   ) null_rest_of_line
;

telephony_service_null
:
   NO?
   (
      IP
      | MAX_CONFERENCES
      | MAX_EPHONES
      | SRST
      | TRANSFER_SYSTEM
   ) null_rest_of_line
;

template_null
:
  NO?
  (
    ACCESS_SESSION
    | AUTHENTICATION
    | DOT1X
    | MAB
    | RADIUS_SERVER
  ) null_rest_of_line
;

tg_null
:
   NO?
   (
      ACCOUNTING_SERVER_GROUP
      | ADDRESS_POOL
      | AUTHENTICATION
      | AUTHENTICATION_SERVER_GROUP
      | DEFAULT_GROUP_POLICY
      | GROUP_URL
      | IPV6_ADDRESS_POOL
      | ISAKMP
   ) null_rest_of_line
;

tr_null
:
   NO?
   (
      WEEKDAY
      | WEEKEND
   ) null_rest_of_line
;

track_block
:
  NEWLINE track_block_null*
;

track_block_null
:
  TYPE null_rest_of_line track_block_type_null*
;

track_block_type_null
:
  OBJECT null_rest_of_line
;

track_interface
:
  INTERFACE interface_name LINE_PROTOCOL NEWLINE
;

track_list
:
  LIST null_rest_of_line track_list_null*
;

track_list_null
:
  (
    DELAY
    | OBJECT
  ) null_rest_of_line
;

ts_common
:
   ts_null
;

ts_host
:
   HOST hostname =
   (
      IP_ADDRESS
      | IPV6_ADDRESS
   ) null_rest_of_line t_key?
;

ts_null
:
   (
      DEADTIME
      | DIRECTED_REQUEST
      | KEY
      | RETRANSMIT
      | TEST
      | TIMEOUT
   ) null_rest_of_line
;

vi_address_family
:
   NO? ADDRESS_FAMILY IPV4 NEWLINE
   (
      viaf_vrrp
   )*
;

u
:
   u_encrypted_password
   | u_nohangup
   | u_passphrase
   | u_password
   | u_privilege
   | u_role
;

u_encrypted_password
:
   ENCRYPTED_PASSWORD pass = variable_permissive
;

u_nohangup
:
   NOHANGUP
;

u_passphrase
:
   PASSPHRASE
   (
      GRACETIME gracetime = dec
      | LIFETIME lifetime = dec
      | WARNTIME warntime = dec
   )*
;

u_password
:
   (
      (
         PASSWORD
         | SECRET
      )
      (
         up_arista_md5
         | up_arista_sha512
      )
   )
   |
   (
      NOPASSWORD
   )
;

u_privilege
:
   PRIVILEGE privilege = variable
;

u_role
:
   (
      GROUP
      | ROLE
   ) role = variable
;

ua_null
:
   (
      GROUP_LOCK
      | VPN_GROUP_POLICY
   ) null_rest_of_line
;

up_arista_md5
:
   dec
   (
      pass = MD5_ARISTA
   )
;

up_arista_sha512
:
   SHA512 pass = SHA512_ARISTA
;

ur_access_list
:
   ACCESS_LIST SESSION name = variable_permissive NEWLINE
;

ur_null
:
   NO?
   (
      CAPTIVE_PORTAL
      | MAX_SESSIONS
      | VLAN
   ) null_rest_of_line
;

viaf_vrrp
:
   NO? VRRP groupnum = dec NEWLINE
   (
      viafv_address
      | viafv_null
      | viafv_preempt
      | viafv_priority
   )*
;

viafv_address
:
   ADDRESS address = IP_ADDRESS NEWLINE
;

viafv_null
:
   NO?
   (
      TIMERS
      | TRACK
   ) null_rest_of_line
;

viafv_preempt
:
   PREEMPT
   (
      DELAY delay = dec
   ) NEWLINE
;

viafv_priority
:
   PRIORITY priority = dec NEWLINE
;

vpc_null
:
   NO?
   (
      AUTO_RECOVERY
      | DELAY
      | DUAL_ACTIVE
      | GRACEFUL
      | IP
      | PEER_CONFIG_CHECK_BYPASS
      | PEER_GATEWAY
      | PEER_KEEPALIVE
      | PEER_SWITCH
      | ROLE
      | SYSTEM_PRIORITY
   ) null_rest_of_line
;

vpdng_accept_dialin
:
   NO? ACCEPT_DIALIN null_rest_of_line
   (
      vpdnga_null
   )*
;

vpdng_null
:
   NO?
   (
      L2TP
   ) null_rest_of_line
;

vpdnga_null
:
   NO?
   (
      PROTOCOL
      | VIRTUAL_TEMPLATE
   ) null_rest_of_line
;

vpn_dialer_null
:
   NO?
   (
      IKE
   ) null_rest_of_line
;

vpn_null
:
   NO?
   (
      CLUSTER
      | PARTICIPATE
      | PRIORITY
      | REDIRECT_FQDN
   ) null_rest_of_line
;

vrfd_description
:
   description_line
;

vrfd_rd
:
   RD (AUTO | rd = route_distinguisher) NEWLINE
;

vrrp_interface
:
   NO? INTERFACE iface = interface_name NEWLINE
   (
      vi_address_family
   )* NEWLINE?
;

wccp_id
:
   id = dec
   (
      (
         GROUP_LIST group_list = variable
      )
      |
      (
         MODE
         (
            CLOSED
            | OPEN
         )
      )
      |
      (
         PASSWORD dec? password = variable
      )
      |
      (
         REDIRECT_LIST redirect_list = variable
      )
      |
      (
         SERVICE_LIST service_list = variable
      )
   )* NEWLINE
;

wccp_null
:
   (
      CHECK
      | OUTBOUND_ACL_CHECK
      | SOURCE_INTERFACE
      | VERSION
      | WEB_CACHE
   ) null_rest_of_line
;

web_server_null
:
   NO?
   (
      CAPTIVE_PORTAL_CERT
      | IDP_CERT
      | SESSION_TIMEOUT
      | SWITCH_CERT
      | WEB_HTTPS_PORT_443
      | WEB_MAX_CLIENTS
   ) null_rest_of_line
;

webvpn_null
:
   NO?
   (
      ANYCONNECT
      | ANYCONNECT_ESSENTIALS
      | CACHE
      | CSD
      | DISABLE
      | ENABLE
      | ERROR_RECOVERY
      | KEEPOUT
      | TUNNEL_GROUP_LIST
   ) null_rest_of_line
;

wlan_null
:
   NO?
   (
      BCN_RPT_REQ_PROFILE
      | DOT11K_PROFILE
      | DOT11R_PROFILE
      | EDCA_PARAMETERS_PROFILE
      | HANDOVER_TRIGGER_PROFILE
      | HOTSPOT
      | HT_SSID_PROFILE
      | RRM_IE_PROFILE
      | TSM_REQ_PROFILE
      | VOIP_CAC_PROFILE
   ) null_rest_of_line
;

wlan_ssid_profile
:
   SSID_PROFILE double_quoted_string NEWLINE
   (
      wlan_ssid_profile_null
   )*
;

wlan_ssid_profile_null
:
   NO?
   (
      EAPOL_RATE_OPT
      | ESSID
      | HT_SSID_PROFILE
      | MAX_CLIENTS
      | MCAST_RATE_OPT
      | OPMODE
      | SSID_ENABLE
      | WMM
   ) null_rest_of_line
;

wlan_virtual_ap
:
   VIRTUAL_AP double_quoted_string NEWLINE
   (
      wlan_virtual_ap_null
   )*
;

wlan_virtual_ap_null
:
   NO?
   (
      AAA_PROFILE
      | AUTH_FAILURE_BLACKLIST_TIME
      | BAND_STEERING
      | BLACKLIST
      | BLACKLIST_TIME
      | BROADCAST_FILTER
      | DENY_INTER_USER_TRAFFIC
      | DYNAMIC_MCAST_OPTIMIZATION
      | DYNAMIC_MCAST_OPTIMIZATION_THRESH
      | SSID_PROFILE
      | VAP_ENABLE
      | VLAN
   ) null_rest_of_line
;

wsma_null
:
   NO?
   (
      PROFILE
      | TRANSPORT
   ) null_rest_of_line
;
