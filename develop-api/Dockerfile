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
USER animanga
ENV SPRING_PROFILES_ACTIVE=demo \
    STORAGE_LOCATION=/app/uploads \
    JAVA_OPTS="-XX:MaxRAMPercentage=75"
EXPOSE 8080
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
