FROM openjdk:8-jdk
EXPOSE 8080
ARG JAR_FILE=target/rest-service-0.0.2-SNAPSHOT.jar
ADD ${JAR_FILE} app.jar
ENTRYPOINT ["java","-jar","/app.jar"]