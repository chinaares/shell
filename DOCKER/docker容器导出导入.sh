docker容器导出导入：
dcoker export 容器id > ./filename.tar


cat ./filename.tar |docker import - test/ubuntu:v1.0
导入的时候，可以重新定义镜像标签
REPOSITORY          TAG                 IMAGE ID            CREATED             SIZE
test/ubuntu         v1.0                40f6315386cf        43 minutes ago      124.8 MB
docker.io/ubuntu    latest              ccc7a11d65b1        3 weeks ago         120.1 MB


dcoker镜像载入存出：
docker save -o ubuntu_new1.tar ubuntu:latest

dcoker load < ubuntu_new1.tar