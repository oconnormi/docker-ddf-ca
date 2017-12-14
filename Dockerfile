FROM alpine
RUN apk add --no-cache curl openssl
RUN mkdir /certs
RUN curl -LsSk https://raw.githubusercontent.com/codice/ddf/master/distribution/ddf-common/src/main/resources/etc/certs/demoCA/cacert.pem -o /certs/ca.pem
RUN curl -LsSk https://raw.githubusercontent.com/codice/ddf/master/distribution/ddf-common/src/main/resources/etc/certs/demoCA/private/cakey.pem -o /certs/ca.key
RUN openssl rsa -in /certs/ca.key -out /certs/ca-key.pem -passin pass:secret

FROM oconnormi/cfssl
COPY files/config/config.json /config.json
COPY --from=0 /certs/ca.pem /ca.pem
COPY --from=0 /certs/ca.pem /root-bundle.crt
COPY --from=0 /certs/ca-key.pem /ca-key.pem

EXPOSE 80
CMD ["serve", "-address=0.0.0.0", "-port=80", "-ca=/ca.pem", "-ca-key=/ca-key.pem", "-config=/config.json", "-ca-bundle=/root-bundle.crt"]
