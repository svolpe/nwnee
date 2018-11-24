FROM nwnxee/builder as builder
WORKDIR /nwnx/home
COPY ./ .
# Compile nwnx

RUN echo exit 0 > /usr/sbin/policy-rc.d
RUN Scripts/buildnwnx.sh -j $(nproc)

FROM beamdog/nwserver
RUN mkdir /nwn/nwnx
RUN echo exit 0 > /usr/sbin/policy-rc.d
COPY --from=builder /nwnx/home/Binaries/* /nwn/nwnx/
# Install plugin run dependencies
RUN runDeps="hunspell \
    libmariadbclient18 \
    libpq-dev \
    libruby2.3 \
    luajit libluajit-5.1 \
    libssl1.1" \
    && apt-get update \
    && apt-get -y install --no-install-recommends $runDeps \
    && rm -r /var/cache/apt /var/lib/apt/lists
# Configure nwserver to run with nwnx
ENV NWNX_CORE_LOAD_PATH=/nwn/nwnx/
ENV NWN_LD_PRELOAD="/nwn/nwnx/NWNX_Core.so"
# Use NWNX_ServerLogRedirector as default log manager
ENV NWNX_SERVERLOGREDIRECTOR_SKIP=n \
    NWN_TAIL_LOGS=n \
    NWNX_CORE_LOG_LEVEL=7 \
    NWNX_SERVERLOGREDIRECTOR_LOG_LEVEL=6
# Disable all other plugins by default. Remember to add new plugins to this list.
ENV NWNX_ADMINISTRATION_SKIP=y \
    NWNX_BEHAVIOURTREE_SKIP=y \
    NWNX_CHAT_SKIP=y \
    NWNX_CREATURE_SKIP=y \
    NWNX_DAMAGE_SKIP=y \
    NWNX_DATA_SKIP=y \
    NWNX_DIALOG_SKIP=y \
    NWNX_EVENTS_SKIP=y \
    NWNX_ITEM_SKIP=y \
    NWNX_JVM_SKIP=y \
    NWNX_LUA_SKIP=y \
    NWNX_METRICS_INFLUXDB_SKIP=y \
    NWNX_MONO_SKIP=y \
    NWNX_OBJECT_SKIP=y \
    NWNX_PLAYER_SKIP=y \
    NWNX_PROFILER_SKIP=y \
    NWNX_SPELLCHECKER_SKIP=y \
    NWNX_REDIS_SKIP=y \
    NWNX_RUBY_SKIP=y \
    NWNX_SQL_SKIP=y \
    NWNX_THREADWATCHDOG_SKIP=y \
    NWNX_TIME_SKIP=y \
    NWNX_TRACKING_SKIP=y \
    NWNX_TWEAKS_SKIP=y \
    NWNX_UTIL_SKIP=y \
    NWNX_WEAPON_SKIP=y \
    NWNX_WEBHOOK_SKIP=y


# Update repos
RUN apt-get update

# Install minimum
RUN apt-get install -y apache2 mysql-server php

# Install and configure OpenSSH
RUN apt-get install -y openssh-server
#RUN mkdir /var/run/sshd
#RUN sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config
#RUN ssh-keygen -q -N "" -t dsa -f /etc/ssh/ssh_host_ecdsa_key
#RUN ssh-keygen -q -N "" -t rsa -f /etc/ssh/ssh_host_rsa_key 
RUN ssh-keygen -A
RUN echo 'root:screencast' | chpasswd
RUN sed -i 's/#PermitRootLogin/PermitRootLogin/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication/PasswordAuthentication/' /etc/ssh/sshd_config

# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd

ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
#CMD [" && /usr/sbin/sshd -D"]
COPY /run-server.sh /nwn/
RUN chmod +x /nwn/run-server.sh
EXPOSE 22

# Create NWN user
RUN groupadd --gid 5000 nwnuser
RUN useradd --uid 5000 --gid 5000 -ms /bin/bash nwnuser
RUN echo 'nwnuser:nwnuser' | chpasswd
RUN adduser nwnuser sudo


# Install apache2 settings:
# Install apache and write hello world message
RUN echo "Hello World!" > /var/www/index.html

# Configure apache
RUN a2enmod rewrite
RUN chown -R www-data:www-data /var/www


ENV APACHE_RUN_USER  www-data
ENV APACHE_RUN_GROUP www-data
ENV APACHE_LOG_DIR   /var/log/apache2
ENV APACHE_PID_FILE  /var/run/apache2/apache2.pid
ENV APACHE_RUN_DIR   /var/run/apache2
ENV APACHE_LOCK_DIR  /var/lock/apache2
ENV APACHE_LOG_DIR   /var/log/apache2

RUN mkdir -p $APACHE_RUN_DIR
RUN mkdir -p $APACHE_LOCK_DIR
RUN mkdir -p $APACHE_LOG_DIR

EXPOSE 80

# CMD ["sed", "-n", "74p", "/etc/apache2/apache2.conf"]
# CMD ["cat", "/etc/apache2/envvars"]
# CMD ["/usr/sbin/apache2", "-D",  "FOREGROUND"]

