#!/bin/bash

# Fetches and install Spark and its dependencies. To be invoked by the Dockerfile

# echo commands to the terminal output
set -ex

# Install JDK
apt-get update -y && \
    apt-get install -y software-properties-common && \
    add-apt-repository ppa:openjdk-r/ppa && \
    apt-get update -y && \
    apt-get install -y --force-yes ca-certificates-java && \
    apt-get install -y --force-yes openjdk-8-jdk && \
    apt-get install -y wget && \
    update-java-alternatives -s java-1.8.0-openjdk-amd64 && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

mkdir -p /opt/spark
mkdir -p /opt/spark/work-dir
touch /opt/spark/RELEASE

# Fetch Spark Distribution
wget https://archive.apache.org/dist/spark/spark-3.4.0/spark-3.4.0-bin-hadoop3.tgz -O spark-dist.tgz
echo '67bc912e9192ef2159540cb480820e5466dfd91e907c97c5a4787587e3020be042b76c40c51854f2a5dbeb8c3775fe12d9021c1200c4704463ec644132243a69  spark-dist.tgz' > spark-dist.tgz.sha512 && sha512sum --check spark-dist.tgz.sha512
mkdir -p spark-dist
tar -xvf spark-dist.tgz -C spark-dist --strip-components 1

#Copy over required files
cp -rf spark-dist/jars /opt/spark/jars
cp -rf spark-dist/examples /opt/spark/examples
cp -rf spark-dist/python /opt/spark/python
cp -rf spark-dist/bin /opt/spark/bin
cp -rf spark-dist/sbin /opt/spark/sbin
cp -rf spark-dist/data /opt/spark/data
# Entrypoint for Driver/Executor pods
cp spark-dist/kubernetes/dockerfiles/spark/entrypoint.sh /opt/entrypoint.sh
chmod +x /opt/entrypoint.sh

rm -rf spark-dist.tgz
rm -rf spark-dist

# Hadoop dist (via Apache) has older AWS SDK version. Fetch required AWS jars from maven directly (not-ideal) to support IAM role
# https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-minimum-sdk.html
wget https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.4.0/hadoop-aws-3.4.0.jar -P /opt/spark/jars
wget https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar -P /opt/spark/jars
