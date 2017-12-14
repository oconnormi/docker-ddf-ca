FROM centos
ENV ENTRYPOINT_HOME=/entrypoint
ENV GOPATH=/go
ENV  PATH=$PATH:$GOPATH/bin
RUN yum install -y git go \
  && go get -u github.com/cloudflare/cfssl/cmd/cfssl \
               github.com/cloudflare/cfssl/cmd/cfssljson \
  && mkdir -p /ca/db \
  && mkdir -p /ca/config \
  && mkdir -p /ca/certs \
  && mkdir -p /ca/.db_seed \
  && mkdir -p /entrypoint
COPY files/db/certs.db /ca/.db_seed/certs.db
COPY scripts/* /entrypoint/
VOLUME /ca/config /ca/certs /ca/db
EXPOSE 80
ENTRYPOINT ["/entrypoint/run.sh"]
