FROM couchdb:1.6

RUN apt-get -y update && apt-get -y install \
  git \
  curl \
  sudo \
  python-dev \
  libffi-dev \
  libssl-dev

COPY image-init.sh /image-init.sh
COPY init.sh /init.sh
RUN chmod +x /image-init.sh
RUN chmod +x /init.sh
RUN /image-init.sh

CMD ["/init.sh"]
