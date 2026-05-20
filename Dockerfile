# Multi-stage build: Build stage
FROM eclipse-temurin:21-jdk AS builder

WORKDIR /build

# Copy gradle wrapper and build files
COPY gradle gradle/
COPY gradlew build.gradle settings.gradle ./

# Copy source code
COPY src src/

# Convert CRLF to LF, make gradlew executable and build fat jar with shadowJar task
RUN sed -i 's/\r$//' gradlew && \
    chmod +x gradlew && \
    ./gradlew shadowJar --no-daemon

# Runtime stage - lightweight JRE
FROM eclipse-temurin:21-jre-alpine

WORKDIR /app

# Create logs directory and define as volume
RUN mkdir -p /app/logs
VOLUME ["/app/logs"]

# Set default PORT environment variable
ENV PORT=7000

# Copy the fat jar from builder stage
COPY --from=builder /build/build/libs/app.jar /app/app.jar

# Expose port (dynamic from ENV)
EXPOSE ${PORT}

# Run the application
ENTRYPOINT ["java", "-jar", "/app/app.jar"]

