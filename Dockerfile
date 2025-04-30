FROM registry.access.redhat.com/ubi8/ubi:latest

RUN yum install -y java-17-openjdk java-17-openjdk-devel wget curl unzip python3 python3-pip && \
    yum clean all
ENV JAVA_HOME=/usr/lib/jvm/jre-17 \
    KAFKA_VERSION=4.0.0 \
    SCALA_VERSION=2.13  \
    KAFKA_HOME=/opt/kafka
    
RUN curl -sSSL "https://downloads.apache.org/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz" | tar -xz -C /opt && \
    mv /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} ${KAFKA_HOME}

#add snowflake connector for kafka
RUN curl -sSSL "https://repo1.maven.org/maven2/com/snowflake/snowflake-kafka-connector/1.9.2/snowflake-kafka-connector-1.9.2.jar" -o ${KAFKA_HOME}/libs/snowflake-kafka-connector-1.9.2.jar

ENV PATH = ${KAFKA_HOME}/bin:$PATH

RUN chmod +x ${KAFKA_HOME}/bin/connect-distributed.sh

COPY connect-distributed.properties /opt/kafka/config/
COPY snowflake-connector.properties /opt/kafka/config/

EXPOSE 8083

CMD ["sh", "-c", "${KAFKA_HOME}/bin/connect-distributed.sh /opt/kafka/config/connect-distributed.properties"]