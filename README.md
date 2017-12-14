# DDF CA

Builds a CA on top of `oconnormi/cfssl` that uses the DDF Demo CA certificate

# Usage

```bash
docker run -d --name=ddf-ca -p 8080:80 oconnormi/ddf-ca
```

For more usage info see the [cfssl Readme](https://github.com/cloudflare/cfssl/blob/master/README.md)
