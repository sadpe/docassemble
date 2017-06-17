FROM debian:jessie
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update
RUN DEBIAN_FRONTEND=noninteractive bash -c "until apt-get -q -y install apt-utils tzdata python python-dev wget unzip git locales pandoc texlive texlive-latex-extra apache2 postgresql libapache2-mod-wsgi libapache2-mod-xsendfile poppler-utils libffi-dev libffi6 imagemagick gcc supervisor libaudio-flac-header-perl libaudio-musepack-perl libmp3-tag-perl libogg-vorbis-header-pureperl-perl make perl libvorbis-dev libcddb-perl libinline-perl libcddb-get-perl libmp3-tag-perl libaudio-scan-perl libaudio-flac-header-perl libparallel-forkmanager-perl libav-tools autoconf automake libjpeg-dev zlib1g-dev libpq-dev logrotate tmpreaper cron pdftk libxml2 libxslt1.1 libxml2-dev libxslt1-dev libcurl4-openssl-dev libssl-dev redis-server rabbitmq-server libreoffice libtool libtool-bin pacpl syslog-ng rsync s3cmd curl mktemp dnsutils tesseract-ocr tesseract-ocr-dev tesseract-ocr-afr tesseract-ocr-ara tesseract-ocr-aze tesseract-ocr-bel tesseract-ocr-ben tesseract-ocr-bul tesseract-ocr-cat tesseract-ocr-ces tesseract-ocr-chi-sim tesseract-ocr-chi-tra tesseract-ocr-chr tesseract-ocr-dan tesseract-ocr-deu tesseract-ocr-deu-frak tesseract-ocr-ell tesseract-ocr-eng tesseract-ocr-enm tesseract-ocr-epo tesseract-ocr-equ tesseract-ocr-est tesseract-ocr-eus tesseract-ocr-fin tesseract-ocr-fra tesseract-ocr-frk tesseract-ocr-frm tesseract-ocr-glg tesseract-ocr-grc tesseract-ocr-heb tesseract-ocr-hin tesseract-ocr-hrv tesseract-ocr-hun tesseract-ocr-ind tesseract-ocr-isl tesseract-ocr-ita tesseract-ocr-ita-old tesseract-ocr-jpn tesseract-ocr-kan tesseract-ocr-kor tesseract-ocr-lav tesseract-ocr-lit tesseract-ocr-mal tesseract-ocr-mkd tesseract-ocr-mlt tesseract-ocr-msa tesseract-ocr-nld tesseract-ocr-nor tesseract-ocr-osd tesseract-ocr-pol tesseract-ocr-por tesseract-ocr-ron tesseract-ocr-rus tesseract-ocr-slk tesseract-ocr-slk-frak tesseract-ocr-slv tesseract-ocr-spa tesseract-ocr-spa-old tesseract-ocr-sqi tesseract-ocr-srp tesseract-ocr-swa tesseract-ocr-swe tesseract-ocr-tam tesseract-ocr-tel tesseract-ocr-tgl tesseract-ocr-tha tesseract-ocr-tur tesseract-ocr-ukr tesseract-ocr-vie build-essential nodejs npm exim4-daemon-heavy libsvm3 libsvm-dev liblinear1 liblinear-dev cm-super; do sleep 1; done"
RUN apt-get -q -y remove pacpl && cd /tmp && git clone git://git.code.sf.net/p/pacpl/code pacpl-code && sleep 5 && cd pacpl-code && ( ./configure || true) && sleep 5 && ( make || true ) && sleep 5 && ( make install || true ) 
RUN cd /tmp && wget https://github.com/jgm/pandoc/releases/download/1.19.2.1/pandoc-1.19.2.1-1-amd64.deb && dpkg -i pandoc-1.19.2.1-1-amd64.deb && mkdir -p /etc/ssl/docassemble /usr/share/docassemble/local /usr/share/docassemble/certs /usr/share/docassemble/backup /usr/share/docassemble/config /usr/share/docassemble/webapp /usr/share/docassemble/files /var/www/.pip /var/www/.cache /usr/share/docassemble/log /tmp/docassemble /var/www/html/log && chown -R www-data.www-data /var/www && chsh -s /bin/bash www-data && update-alternatives --install /usr/bin/node node /usr/bin/nodejs 10 && npm install -g azure-storage-cmd
RUN TERM=xterm cd /usr/share/docassemble && git clone https://github.com/letsencrypt/letsencrypt && cd letsencrypt && ./letsencrypt-auto --help && echo "host   all   all  0.0.0.0/0   md5" >> /etc/postgresql/9.4/main/pg_hba.conf && echo "listen_addresses = '*'" >> /etc/postgresql/9.4/main/postgresql.conf
COPY . /tmp/docassemble/
RUN cp /tmp/docassemble/docassemble_webapp/docassemble.wsgi /usr/share/docassemble/webapp/ && cp /tmp/docassemble/Docker/*.sh /usr/share/docassemble/webapp/ && cp /tmp/docassemble/Docker/VERSION /usr/share/docassemble/webapp/ && cp /tmp/docassemble/Docker/pip.conf /usr/share/docassemble/local/ && cp /tmp/docassemble/Docker/config/* /usr/share/docassemble/config/ && cp /tmp/docassemble/Docker/cgi-bin/index.sh /usr/lib/cgi-bin/ && cp /tmp/docassemble/Docker/syslog-ng.conf /usr/share/docassemble/webapp/syslog-ng.conf && cp /tmp/docassemble/Docker/syslog-ng-docker.conf /usr/share/docassemble/webapp/syslog-ng-docker.conf && cp /tmp/docassemble/Docker/docassemble-syslog-ng.conf /usr/share/docassemble/webapp/docassemble-syslog-ng.conf && cp /tmp/docassemble/Docker/apache.logrotate /etc/logrotate.d/apache2 && cp /tmp/docassemble/Docker/docassemble.logrotate /etc/logrotate.d/docassemble && cp /tmp/docassemble/Docker/cron/docassemble-cron-monthly.sh /etc/cron.monthly/docassemble && cp /tmp/docassemble/Docker/cron/docassemble-cron-weekly.sh /etc/cron.weekly/docassemble && cp /tmp/docassemble/Docker/cron/docassemble-cron-daily.sh /etc/cron.daily/docassemble && cp /tmp/docassemble/Docker/cron/docassemble-cron-hourly.sh /etc/cron.hourly/docassemble && cp /tmp/docassemble/Docker/docassemble.conf /etc/apache2/conf-available/ && cp /tmp/docassemble/Docker/docassemble-behindlb.conf /etc/apache2/conf-available/ && cp /tmp/docassemble/Docker/docassemble-supervisor.conf /etc/supervisor/conf.d/docassemble.conf && cp /tmp/docassemble/Docker/ssl/* /usr/share/docassemble/certs/ && cp /tmp/docassemble/Docker/rabbitmq.config /etc/rabbitmq/ && cp /tmp/docassemble/Docker/config/exim4-router /etc/exim4/conf.d/router/101_docassemble && cp /tmp/docassemble/Docker/config/exim4-filter /etc/exim4/docassemble-filter && cp /tmp/docassemble/Docker/config/exim4-main /etc/exim4/conf.d/main/01_docassemble && cp /tmp/docassemble/Docker/config/exim4-acl /etc/exim4/conf.d/acl/29_docassemble && cp /tmp/docassemble/Docker/config/exim4-update /etc/exim4/update-exim4.conf.conf && update-exim4.conf && bash -c "chown -R www-data.www-data /usr/share/docassemble /tmp/docassemble && chmod ogu+r /usr/share/docassemble/config/config.yml.dist && chmod 755 /etc/ssl/docassemble && cd /tmp && wget https://bootstrap.pypa.io/get-pip.py && python get-pip.py && pip install --upgrade virtualenv"

USER www-data
RUN bash -c "cd /tmp && virtualenv /usr/share/docassemble/local && source /usr/share/docassemble/local/bin/activate && pip install --upgrade pip && pip install 'git+https://github.com/nekstrom/pyrtf-ng#egg=pyrtf-ng' /tmp/docassemble/docassemble /tmp/docassemble/docassemble_base /tmp/docassemble/docassemble_demo /tmp/docassemble/docassemble_webapp"

USER root
RUN sed -i -e 's/^\(daemonize\s*\)yes\s*$/\1no/g' -e 's/^bind 127.0.0.1/bind 0.0.0.0/g' /etc/redis/redis.conf && sed -i -e 's/#APACHE_ULIMIT_MAX_FILES/APACHE_ULIMIT_MAX_FILES/' -e 's/ulimit -n 65536/ulimit -n 8192/' /etc/apache2/envvars && echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && locale-gen && update-locale LANG=en_US.UTF-8 && a2dismod ssl; a2enmod wsgi; a2enmod rewrite; a2enmod xsendfile; a2enmod proxy; a2enmod proxy_http; a2enmod proxy_wstunnel; a2enconf docassemble; echo 'export TERM=xterm' >> /etc/bash.bashrc
EXPOSE 80 443 9001 514 25 465 8080 8081 5432 6379 4369 5671 5672 25672
ENV CONTAINERROLE="all" LOCALE="en_US.UTF-8 UTF-8" TIMEZONE="America/New_York" EC2="" S3ENABLE="" S3BUCKET="" S3ACCESSKEY="" S3SECRETACCESSKEY="" DAHOSTNAME="" USEHTTPS="" USELETSENCRYPT="" LETSENCRYPTEMAIL="" DBHOST="" LOGSERVER="" REDIS="" RABBITMQ=""

VOLUME  ["/usr/share/docassemble/certs", "/usr/share/docassemble/backup"]

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]
