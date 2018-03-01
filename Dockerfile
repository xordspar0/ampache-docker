FROM ubuntu:14.04
MAINTAINER xordspar0

ENV AMPACHE_VERSION 3.8.6

RUN echo 'deb http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list
RUN echo 'deb-src http://download.videolan.org/pub/debian/stable/ /' >> /etc/apt/sources.list
RUN echo 'deb http://archive.ubuntu.com/ubuntu trusty main multiverse' >> /etc/apt/sources.list

# Install dependencies.
RUN apt-get update && apt-get -y upgrade
RUN DEBIAN_FRONTEND=noninteractive apt-get -y install wget inotify-tools
RUN wget -O - https://download.videolan.org/pub/debian/videolan-apt.asc | apt-key add - && apt-get update

RUN DEBIAN_FRONTEND=noninteractive apt-get -y install apache2 php5 php5-json php5-curl php5-mysqlnd pwgen lame libvorbis-dev vorbis-tools flac libmp3lame-dev libavcodec-extra* libfaac-dev libtheora-dev libvpx-dev libav-tools unzip

# Install Ampache.
ADD https://github.com/ampache/ampache/releases/download/${AMPACHE_VERSION}/ampache-${AMPACHE_VERSION}_all.zip /tmp/ampache.zip
RUN rm -r /var/www/html && \
	unzip /tmp/ampache.zip -d /var/www/ && \
	rm /tmp/ampache.zip && \
	chown -R www-data /var/www
ADD run.sh /run.sh
RUN chmod 755 /run.sh

# Set up Apache with default ampache vhost.
ADD 001-ampache.conf /etc/apache2/sites-available/
RUN rm -rf /etc/apache2/sites-enabled/*
RUN ln -s /etc/apache2/sites-available/001-ampache.conf /etc/apache2/sites-enabled/
RUN a2enmod rewrite

# Add job to cron to clean the library every night.
RUN echo '30 7    * * *   www-data php /var/www/bin/catalog_update.inc' >> /etc/crontab

VOLUME ["/media"]
VOLUME ["/var/www/config"]
VOLUME ["/var/www/themes"]
EXPOSE 80

CMD ["/run.sh"]
