yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel perl-devel
yum install git

groupadd git
useradd git -g git

#收集所有需要登录的用户的公钥，公钥位于id_rsa.pub文件中，把我们的公钥导入到/home/git/.ssh/authorized_keys文件里，一行一个。
cd /home/git/
mkdir .ssh
chmod 700 .ssh
touch .ssh/authorized_keys
chmod 600 .ssh/authorized_keys

cd /home
mkdir gitrepo
chown git:git gitrepo/
cd gitrepo

git init --bare TEST.git


/etc/ssh/sshd_config
RSAAuthentication yes     
PubkeyAuthentication yes     
AuthorizedKeysFile  .ssh/authorized_keys