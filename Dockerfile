######################################################
#
#  EC MySQL 5.0 CentOS Docker Image
#
#  Base Image:
#  - CentOS 6.9 (EOL)
#
#  Additions:
#  - MySQL 5.0.51a
#
######################################################

# Start from CentOS base image
FROM centos:centos6.9

ENV container=docker

# CentOS Tweaks to work with Docker, see:
# https://hub.docker.com/_/centos/
# https://github.com/docker/docker/issues/7459
RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

# Copy files for src compilation
COPY deps/ /mysql-build

# Update existing system packages
RUN yum clean all && yum update -y

# Install additional system packages
RUN yum install -y epel-release
RUN yum install -y initscripts which wget gcc gcc-c++ make autoconf re2c libxml2-devel nano git bind bind-utils openssl-devel systemtap-sdt-devel curl-devel gmp-devel libc-client-devel libicu-devel libmcrypt-devel libmhash-devel patch perl-DBI

# Setup gosu for easier command execution
RUN mv /mysql-build/gosu-amd64 /usr/local/bin/gosu && \
    chmod +x /usr/local/bin/gosu

# Install MySQL 5.0.51a client libraries
RUN cd /mysql-build && \
rpm -Uvh MySQL-client-community-5.0.51a-0.rhel5.x86_64.rpm && \
rpm -Uvh MySQL-devel-community-5.0.51a-0.rhel5.x86_64.rpm

# Install MySQL 5.0.51a server libraries
RUN cd /mysql-build && \
rpm -Uvh MySQL-server-community-5.0.51a-0.rhel5.x86_64.rpm

# Setup MySQL directories
RUN mkdir -p /etc/mysql/conf.d /var/lib/mysql /var/run/mysqld \
	&& chown -R mysql:mysql /var/lib/mysql /var/run/mysqld \
	&& chmod 777 /var/run/mysqld /var/lib/mysql

VOLUME /var/lib/mysql

# Copy local configs to container filesystem
COPY docker/mysql/docker-entrypoint.sh /usr/local/bin/
COPY docker/mysql/config/my.cnf /etc/my.cnf

# Make sure bash script is executable
RUN ["chmod", "+x", "/usr/local/bin/docker-entrypoint.sh"]

# Clean up build files
RUN rm -R /mysql-build

# Setup entrypoint and run
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 3306
CMD ["mysqld"]