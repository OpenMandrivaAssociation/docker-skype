FROM openmandriva/openmandriva32-2014.0:latest

ENV SKYPE_USER=skype

RUN urpmi.addmedia non-free http://abf-downloads.rosalinux.ru/openmandriva2014.0/repository/i586/non-free/release/ \
 && urpmi.addmedia non-free_updates http://abf-downloads.rosalinux.ru/openmandriva2014.0/repository/i586/non-free/updates/ \
 && mkdir -p /var/cache/skype/ \
 && urpmi.update -a \
 && urpmi --auto --auto-update \
 && urpmi --no-suggests --auto systemd fontconfig sudo skype \
 && rm -rf /var/cache/urpmi/rpms/*

COPY scripts/ /var/cache/skype/
COPY entrypoint.sh /sbin/entrypoint.sh
RUN chmod 755 /sbin/entrypoint.sh

ENTRYPOINT ["/sbin/entrypoint.sh"]
