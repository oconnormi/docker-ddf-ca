FROM centos
ENV ENTRYPOINT_HOME=/entrypoint
ENV GOPATH=/go
ENV GOROOT=/usr/local/go
ENV  PATH=$PATH:$GOPATH/bin:$GOROOT/bin
RUN yum install -y git gcc \
  && curl -LsSk https://dl.google.com/go/go1.9.4.linux-amd64.tar.gz -o go1.9.4.linux-amd64.tar.gz \
  && tar -xvf go1.9.4.linux-amd64.tar.gz \
  && mv go /usr/local \
  && rm -rf go1.9.4.linux-amd64.tar.gz \
  && go get -u github.com/cloudflare/cfssl/cmd/cfssl \
               github.com/cloudflare/cfssl/cmd/cfssljson \
               github.com/cloudflare/cfssl/cmd/mkbundle \
  && mkdir -p /ca/db \
  && mkdir -p /ca/config \
  && mkdir -p /ca/certs \
  && mkdir -p /ca/.db_seed \
  && mkdir -p /entrypoint
COPY files/db/certs.db /ca/.db_seed/certs.db
COPY scripts/* /entrypoint/
VOLUME /ca/config /ca/certs /ca/db
EXPOSE 443 80
ENTRYPOINT ["/entrypoint/run.sh"]
