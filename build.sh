docker login --username=hi29713477@aliyun.com registry.cn-chengdu.aliyuncs.com -p 

docker build -t registry.cn-chengdu.aliyuncs.com/bendon/hadoop:3.3.3 .
docker push registry.cn-chengdu.aliyuncs.com/bendon/hadoop:3.3.3

#docker run -p 9000:9000 -p 8088:8088 -p 9864:9864 -p 19888:19888 -p 9870:9870 registry.cn-chengdu.aliyuncs.com/bendon/hadoop:3.3.3
#使用hive前初始化本地数据库：schematool -initSchema -dbType derby

echo "完成构建"

