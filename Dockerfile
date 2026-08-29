FROM ghcr.io/binhex/arch-base:latest
LABEL org.opencontainers.image.authors="binhex"
LABEL org.opencontainers.image.source="https://github.com/binhex/arch-minecraftbedrockserver"

ARG APPNAME
ARG RELEASETAG
ARG TARGETARCH

ADD build/root/install-packages.sh /root/install-packages.sh
RUN chmod +x /root/install-packages.sh && \
	/bin/bash /root/install-packages.sh "${APPNAME}" "${TARGETARCH}"

ADD build/root/install.sh /root/install.sh
RUN chmod +x /root/install.sh && \
	/bin/bash /root/install.sh "${APPNAME}" "${RELEASETAG}" "${TARGETARCH}"

ADD build/*.conf /etc/supervisor/conf.d/
ADD run/nobody/*.sh /home/nobody/

HEALTHCHECK \
	--interval=2m \
	--timeout=2m \
	--retries=3 \
	--start-period=2m \
  CMD /usr/local/bin/system/scripts/docker/healthcheck.sh || exit 1

CMD ["/bin/bash", "init.sh"]
