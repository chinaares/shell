FROM centos:7
MAINTAINER KINGHU88 517834203@qq.com

RUN yum -y install openssh openssh-server openssh-clients passwd

RUN ssh-keygen -q -t rsa -b 2048 -f /etc/ssh/ssh_host_rsa_key -N '' && \
    ssh-keygen -q -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key -N '' && \
    ssh-keygen -t dsa -f /etc/ssh/ssh_host_ed25519_key  -N '' && \
    echo 123456 | passwd --stdin root
ADD run.sh /run.sh
RUN chmod a+x /run.sh

EXPOSE 22
CMD ["/run.sh"]