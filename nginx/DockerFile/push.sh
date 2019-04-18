#!/bin/bash

#仓库 用户 密码 url
regUser=admin
regPasswd=Cditv12345
regUrl=10.101.0.216
#镜像版本号设置
version=t1
#仓库设置 dev prod
regEnv=dev

docker build -t cditv/nginx:t1 .
docker login --username ${regUser} --password ${regPasswd} ${regUrl}
docker tag cditv/nginx:${version} 10.101.0.216/${regEnv}/nginx:${version}
docker push 10.101.0.216/${regEnv}/nginx:${version}
if [ $? -eq 0 ];then
echo "push 10.101.0.216/${regEnv}/nginx:${version} success"
else
echo "push image error"
fi
