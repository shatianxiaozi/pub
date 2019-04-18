FROM centos:6
MAINTAINER "zhangjian mail--> zhangjian@cditv.tv"
COPY CentOS-Base.repo /etc/yum.repos.d/
COPY redhat.repo /etc/yum.repos.d/
RUN rpm -ivh http://nginx.org/packages/centos/6/noarch/RPMS/nginx-release-centos-6-0.el6.ngx.noarch.rpm && \
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-6 && \
    yum makecache && yum install -y nginx* --nogpgcheck --exclude=nginx-module-geoip* --exclude=nginx-nr-agent* --exclude=nx-module-geoip* && \
    yum clean all 

COPY nginx.conf /etc/nginx/
COPY common_params /etc/nginx/
COPY common_vhosts /etc/nginx/
COPY localtime /etc/localtime

RUN mkdir /etc/nginx/run && \
    ln -sf /dev/stdout /var/log/nginx/access.log && \
    ln -sf /dev/stderr /var/log/nginx/error.log


EXPOSE 80
CMD ["nginx","-g","daemon off;"]
