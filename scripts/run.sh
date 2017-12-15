#!/bin/bash

# Constants
_ca_db_name=certs.db
_ca_cert_name=ca.pem
_ca_key_name=ca-key.pem
_ca_root_bundle_name=ca-bundle.pem
_ca_config_name=config.json
_ca_dbconfig_name=dbconfig.json
_ca_csr_name=ca-csr.json
_ca_directory=/ca
_ca_config_directory=${_ca_directory}/config
_ca_certs_directory=${_ca_directory}/certs
_ca_keys_directory=${_ca_directory}/keys
_ca_bundles_directory=${_ca_directory}/bundles
_ca_db_directory=${_ca_directory}/db
_ca_db_seed_file=${_ca_directory}/.db_seed/${_ca_db_name}

_cfssl_serve_address=0.0.0.0
_cfssl_serve_port=443
_cfssl_serve_config=${_ca_config_directory}/${_ca_config_name}
_cfssl_serve_dbconfig=${_ca_config_directory}/${_ca_dbconfig_name}
_cfssl_serve_ca_bundle=${_ca_bundles_directory}/${_ca_root_bundle_name}
_cfssl_serve_ca_cert=${_ca_certs_directory}/${_ca_cert_name}
_cfssl_serve_ca_key=${_ca_keys_directory}/${_ca_key_name}

# Key Properties
_cfssl_key_alg=${KEY_ALGORITHM:="rsa"}
_cfssl_key_size=${KEY_SIZE:=2048}

# Root CA Properties
_cfssl_root_ca_hosts=${ROOT_CA_HOSTS:='"localhost", "127.0.0.1"'}
_cfssl_root_ca_cn=${ROOT_CA_CN:="DDF Demo Root CA"}
_cfssl_root_ca_names_country=${ROOT_CA_COUNTRY:="US"}
_cfssl_root_ca_names_locality=${ROOT_CA_LOCALITY:=""}
_cfssl_root_ca_names_organization=${ROOT_CA_ORGANIZATION:="DDF"}
_cfssl_root_ca_names_organization_unit=${ROOT_CA_ORGANIZATIONAL_UNIT:="Dev"}
_cfssl_root_ca_names_state=${ROOT_CA_STATE:="AZ"}

function initCACSR() {
  if [ ! -f ${_ca_config_directory}/${_ca_csr_name} ]; then
    echo "CA CSR config doen't exist already, creating now"
    cat > ${_ca_config_directory}/${_ca_csr_name} << EOF
{
    "CN": "${_cfssl_root_ca_cn}",
    "hosts": [ ${_cfssl_root_ca_hosts} ],
    "key": {
        "algo": "${_cfssl_key_alg}",
        "size": ${_cfssl_key_size}
    },
    "names": [
        {
            "C": "${_cfssl_root_ca_names_country}",
            "L": "${_cfssl_root_ca_names_locality}",
            "O": "${_cfssl_root_ca_names_organization}",
            "OU": "${_cfssl_root_ca_names_organization_unit}",
            "ST": "${_cfssl_root_ca_names_state}"
        }
    ]
}
EOF
  else
    echo "CA CSR already exists"
  fi
  echo "CA CSR:"
  cat ${_ca_config_directory}/${_ca_csr_name}
}

function initCA() {
  initCACSR

  if [ ! -f ${_ca_certs_directory}/${_ca_cert_name} ] || [ ! -f ${_ca_keys_directory}/${_ca_key_name} ] || [ ! -f ${_ca_bundles_directory}/${_ca_root_bundle_name} ]; then
    echo "CA doesn't already exist, initializing now"
    mkdir -p /tmp/ca-certs && pushd /tmp/ca-certs
    cfssl genkey -initca ${_ca_config_directory}/${_ca_csr_name} | cfssljson -bare ca
    mkbundle -f ${_ca_bundles_directory}/${_ca_root_bundle_name} ca.pem
    cp ca.pem ${_ca_certs_directory}
    cp ca-key.pem ${_ca_keys_directory}
    popd
  else
    echo "CA already initialized, loading"
  fi
  echo "CA Cert Info:"
  cfssl certinfo -cert ${_ca_certs_directory}/${_ca_cert_name}
}

function initDB() {
  if [ ! -f ${_ca_db_directory}/${_ca_db_name} ]; then
    echo "Cert database not found, seeding with initial database now"
    cp ${_ca_db_seed_file} ${_ca_db_directory}/
  else
    echo "Cert database already exists, loading"
  fi

  if [ ! -f ${_cfssl_serve_dbconfig} ]; then
    echo "CA database config file not found, seeding initial config now"
    cat > ${_cfssl_serve_dbconfig} << EOF
{"driver":"sqlite3","data_source":"${_ca_db_directory}/${_ca_db_name}"}
EOF
  else
    echo "CA database config file found"
  fi
  echo "CA DB Config:"
  cat ${_cfssl_serve_dbconfig}
}

function init() {
  mkdir -p ${_ca_certs_directory}
  mkdir -p ${_ca_keys_directory}
  mkdir -p ${_ca_bundles_directory}
  mkdir -p ${_ca_db_directory}

  $ENTRYPOINT_HOME/init_config.sh ${_cfssl_serve_config}
  initDB
  initCA
}

function start() {
  cfssl serve \
    -address=${_cfssl_serve_address} \
    -port=${_cfssl_serve_port} \
    -ca=${_cfssl_serve_ca_cert} \
    -ca-key=${_cfssl_serve_ca_key} \
    -config=${_cfssl_serve_config} \
    -db-config=${_cfssl_serve_dbconfig} \
    -ca-bundle=${_cfssl_serve_ca_bundle} \
    -tls-key=${_cfssl_serve_ca_key} \
    -tls-cert=${_cfssl_serve_ca_cert} \
    -responder=${_cfssl_serve_ca_cert} \
    -responder-key=${_cfssl_serve_ca_key}
}

function main() {
  init
  start
}

main
