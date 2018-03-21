# DDF CA

Generates a DDF Demo CA server

This is meant to be used for testing only, not for production

# Usage

```bash
docker run -d --name=ddf-ca -p 8080:80 oconnormi/ddf-ca
```

For more usage info see the [cfssl Readme](https://github.com/cloudflare/cfssl/blob/master/README.md)

# Persistence

To persist cert database mount a volume to `/ca/db`
To persist CA configuration mount a volume to `/ca/config`
To persist CA certificates mount a volume to `/ca/certs`

# Customizing

## Customizing CA Config

The following environment variables can be used to customize the generated cfssl configuration

| Variable                    | Description                                                | Default                                               |
|:---------------------------:|:----------------------------------------------------------:|:-----------------------------------------------------:|
| `CA_SIGNING_DEFAULT_EXPIRY` | Sets the default expiry for issued certificates (in hours) | `87600h`                                              |
| `CA_PROFILES_SERVER_EXPIRY` | Sets the expiry for issued server certificates (in hours)  | `87600h`                                              |
| `CA_PROFILES_SERVER_USAGES` | Sets the key usage restrictions for server certificates    | `signing, key encipherment, server auth`              |
| `CA_PROFILES_CLIENT_EXPIRY` | Sets the expiry for issued client certificates (in hours)  | `87600h`                                              |
| `CA_PROFILES_CLIENT_USAGES` | Sets the key usage restrictions for client certificates    | `signing, key encipherment, client auth`              |
| `CA_PROFILES_PEER_EXPIRY`   | Sets the expiry for issued peer certificates (in hours)    | `87600h`                                              |
| `CA_PROFILES_PEER_USAGES`   | Sets the key usage restrictions for peer certificates      | `signing, key encipherment, server auth, client auth` |


## Customizing CA Cert

The following environment variables can be used to customize the generated CA Certificate

| Variable                      | Description                                                         | Default                    |
|:-----------------------------:|:-------------------------------------------------------------------:|:--------------------------:|
| `KEY_ALGORITHM`               | Sets the algorithm to be used for the generated CA Certificate      | `rsa`                      |
| `KEY_SIZE`                    | Sets the key size to be used for the generated CA Certificate       | `2048`                     |
| `ROOT_CA_HOSTS`               | Hostnames for the CA                                                | `"localhost", "127.0.0.1"` |
| `ROOT_CA_CN`                  | Sets the CN value for the generated CA Certificate                  | `DDF Demo Root CA`         |
| `ROOT_CA_COUNTRY`             | Sets the Coutry value for the generated CA Certificate              | `US`                       |
| `ROOT_CA_LOCALITY`            | Sets the Lacality value for the generated CA Certificate            | ``                         |
| `ROOT_CA_ORGANIZATION`        | Sets the Organization value for the generated CA Certificate        | `DDF`                      |
| `ROOT_CA_ORGANIZATIONAL_UNIT` | Sets the Organizational Unit value for the generated CA Certificate | `Dev`                      |
| `ROOT_CA_STATE`               | Sets the State value for the generated CA Certificate               | `AZ`                       |

# Disabling TLS

By default the CA is served on port 443 over TLS
To disable this and run on port 80 set the environment variable `TLS_ENABLED=false`
