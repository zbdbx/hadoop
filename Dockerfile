FROM centos:centos7 as centos7_ssh
#更新源
RUN mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.aliyun.com/repo/Centos-7.repo
# 安装openssh-server和sudo软件包，并且将sshd的UsePAM参数设置成no  
RUN yum install -y openssh-server openssh-clients sudo \
    && ssh-keygen -A
# RUN sed -i 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config

# 添加测试用户root，密码root，并且将此用户添加到sudoers里  
RUN echo "root:root" | chpasswd && echo "root   ALL=(ALL)       ALL" >> /etc/sudoers
COPY ./ssh/ /root/.ssh
RUN chmod 750 ~ && chmod 700 ~/.ssh && chmod 600 ~/.ssh/*
# 启动sshd服务并且暴露22端口  
RUN mkdir /var/run/sshd
EXPOSE 22
# CMD ["/usr/sbin/sshd", "-D"]

FROM centos7_ssh
WORKDIR /data
ADD  https://github.com/adoptium/temurin8-binaries/releases/download/jdk8u362-b09/OpenJDK8U-jdk_x64_linux_hotspot_8u362b09.tar.gz /opt/module
ADD  https://dlcdn.apache.org/hadoop/common/hadoop-3.3.3/hadoop-3.3.3.tar.gz /opt/module
ADD  https://dlcdn.apache.org/hive/hive-3.1.3/apache-hive-3.1.3-bin.tar.gz /opt/module
RUN cd /opt/module/ && ls -la \
    && mv jdk8u362-b09 jdk8 \
    && mv apache-hive-3.1.3-bin hive-3.1.3
    # && mv hadoop-3.3.3 hadoop-3.3.3 
ENV JAVA_HOME=/opt/module/jdk8
ENV HADOOP_HOME=/opt/module/hadoop-3.3.3
ENV HIVE_HOME=/opt/module/hive-3.1.3
ENV PATH=$PATH:$JAVA_HOME/bin:$HADOOP_HOME/bin:$HADOOP_HOME/sbin:$HIVE_HOME/bin

ENV HADOOP_USER_NAME=root \
    # HADOOP_SHELL_EXECNAME=root \
    # HDFS_DATANODE_SECURE_USER=root \
    HDFS_NAMENODE_USER=root \
    HDFS_DATANODE_USER=root \
    HDFS_SECONDARYNAMENODE_USER=root \
    YARN_NODEMANAGER_USER=root \
    YARN_RESOURCEMANAGER_USER=root 
COPY ./config/profile.d/jdk-hadoop.sh /etc/profile.d/
COPY ./config/hadoop /opt/module/hadoop-3.3.3/etc/hadoop/
COPY ./config/run.sh /opt/
VOLUME [ "/data" ]
EXPOSE 9000 8088 9864 19888 9870


ENTRYPOINT ["sh"]

# CMD ["/usr/sbin/sshd", "-D"]
CMD ["/opt/run.sh"]
# CMD ["hdfs","namenode","-format"]

# Couldn't upload the file 2.json. 是因为客户端口没有映射主机IP的HOST，（172.10.0.2 hadoop1）