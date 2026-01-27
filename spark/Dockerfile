FROM apache/spark:3.5.1

USER root

# curl để tải thư viện
RUN apt-get update && apt-get install -y curl

# Tải các JARs vào thư mục của Apache Spark
RUN curl -o /opt/spark/jars/iceberg-spark-runtime-3.5_2.12-1.4.3.jar https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-spark-runtime-3.5_2.12/1.4.3/iceberg-spark-runtime-3.5_2.12-1.4.3.jar
RUN curl -o /opt/spark/jars/iceberg-aws-1.4.3.jar https://repo1.maven.org/maven2/org/apache/iceberg/iceberg-aws/1.4.3/iceberg-aws-1.4.3.jar
RUN curl -o /opt/spark/jars/bundle-2.20.18.jar https://repo1.maven.org/maven2/software/amazon/awssdk/bundle/2.20.18/bundle-2.20.18.jar
RUN curl -o /opt/spark/jars/hadoop-aws-3.3.4.jar https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar
# RUN curl -o /opt/spark/jars/aws-java-sdk-bundle-1.12.262.jar https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar
# RUN curl -o /opt/spark/jars/postgresql-42.6.0.jar https://jdbc.postgresql.org/download/postgresql-42.6.0.jar
COPY aws-java-sdk-bundle-1.12.262.jar /opt/spark/jars/aws-java-sdk-bundle-1.12.262.jar
COPY postgresql-42.6.0.jar /opt/spark/jars/postgresql-42.6.0.jar

RUN mkdir -p /opt/spark/spark-events && \
    chmod 777 /opt/spark/spark-events

USER spark