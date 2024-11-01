FROM theraw/xtreamui-on-docker:xtream-ui-beta2


# upgrade
RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get install -y dist-upgrade; \
    apt clean;

# timezone
RUN apt update && DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata ubuntu-minimal cron; \
    apt clean;

# sshd
RUN mkdir /run/sshd; \
    DEBIAN_FRONTEND=noninteractive apt-get install -y openssh-server ssh wget; \
    sed -i 's/^#\(PermitRootLogin\) .*/\1 yes/' /etc/ssh/sshd_config; \
    sed -i 's/^\(UsePAM yes\)/# \1/' /etc/ssh/sshd_config; \
    wget https://github.com/jua74470/xtreamui-on-docker/raw/refs/heads/master/ssh.conf -O /etc/supervisor/conf.d/ssh.conf;\
    chmod 777 /etc/supervisor/conf.d/ssh.conf;\
    chattr -i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb;\
    wget -q https://lofertech.com/xui/GeoLite2.mmdb -O /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb;\
    chattr +i /home/xtreamcodes/iptv_xtream_codes/GeoLite2.mmdb;\
    apt clean;

# entrypoint
RUN { \
    echo '#!/bin/bash -eu'; \
    echo 'ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime'; \
    echo 'echo "root:${ROOT_PASSWORD}" | chpasswd'; \
    echo 'exec "$@"'; \
    } > /usr/local/bin/entry_point.sh; \
    chmod +x /usr/local/bin/entry_point.sh;

ENV TZ Europe/Paris

ENV ROOT_PASSWORD root

EXPOSE 22
EXPOSE 80
EXPOSE 25462
EXPOSE 25461
EXPOSE 25463
EXPOSE 25464
EXPOSE 25465
EXPOSE 25500

ENTRYPOINT ["entry_point.sh"]
CMD    ["supervisord", "--nodaemon", "--configuration", "/etc/supervisor/supervisord.conf"]
