#!/bin/bash

# Initializes the ca config
# if the ca config file already exists then it does nothing

_ca_config=$1

_ca_config_signing_default_expiry=${CA_SIGNING_DEFAULT_EXPIRY:="87600h"}
_ca_config_profiles_server_expiry=${CA_PROFILES_SERVER_EXPIRY:="87600h"}
_ca_config_profiles_server_usages=${CA_PROFILES_SERVER_USAGES:='"signing", "key encipherment", "server auth"'}
_ca_config_profiles_client_expiry=${CA_PROFILES_CLIENT_EXPIRY:="87600h"}
_ca_config_profiles_client_usages=${CA_PROFILES_CLIENT_USAGES:='"signing", "key encipherment", "client auth"'}
_ca_config_profiles_peer_expiry=${CA_PROFILES_PEER_EXPIRY:="87600h"}
_ca_config_profiles_peer_usages=${CA_PROFILES_PEER_USAGES:='"signing", "key encipherment", "server auth", "client auth"'}

if [ ! -f ${_ca_config} ]; then
  echo "No existing configuration found in ${_ca_config}, initializing now"
  cat >${_ca_config} << EOF
{
    "signing": {
        "default": {
            "expiry": "${_ca_config_signing_default_expiry}"
        },
        "profiles": {
            "server": {
                "expiry": "${_ca_config_profiles_server_expiry}",
                "usages": [ ${_ca_config_profiles_server_usages} ]
            },
            "client": {
                "expiry": "${_ca_config_profiles_client_expiry}",
                "usages": [ ${_ca_config_profiles_client_usages} ]
            },
            "peer": {
                "expiry": "${_ca_config_profiles_peer_expiry}",
                "usages": [ ${_ca_config_profiles_peer_usages} ]
            }
        }
    }
}
EOF
else
  echo "Existing configuration found in ${_ca_config}, loading"
fi
  echo "CA Config:"
  cat ${_ca_config}
