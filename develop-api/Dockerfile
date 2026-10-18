# --- Compilación
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -B dependency:go-offline
COPY src ./src
RUN mvn -q -B -DskipTests package

# --- Ejecución
FROM eclipse-temurin:17-jre
WORKDIR /app
RUN useradd --system --uid 1001 animanga && mkdir -p /app/uploads && chown animanga /app/uploads
COPY --from=build /app/target/*.jar app.jar

# Arranque rápido en máquinas con poca CPU (plan gratuito de Render):
# se extrae el jar y se hace un "arranque de entrenamiento" que guarda las clases ya cargadas (CDS).
# En el arranque real la JVM las reutiliza y se ahorra buena parte del tiempo.
RUN java -Djarmode=tools -jar app.jar extract --destination application \
    && cd application \
    && JWT_SECRET=solo-para-el-entrenamiento-de-cds-0123456789abcdef \
       SPRING_PROFILES_ACTIVE=demo STORAGE_LOCATION=/tmp/cds-uploads \
       java -XX:ArchiveClassesAtExit=app.jsa -Dspring.context.exit=onRefresh -jar app.jar \
    && chown -R animanga /app/application

USER animanga
WORKDIR /app/application
# TieredStopAtLevel=1 y SerialGC arrancan antes; para una demo con poco tráfico compensa
ENV SPRING_PROFILES_ACTIVE=demo \
    STORAGE_LOCATION=/app/uploads \
    JAVA_OPTS="-XX:MaxRAMPercentage=75 -XX:TieredStopAtLevel=1 -XX:+UseSerialGC -Xss512k -XX:SharedArchiveFile=app.jsa"
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
