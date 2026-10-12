# ---------- Étape 1 : build ----------
FROM eclipse-temurin:21-jdk AS build
WORKDIR /app

# Copier d'abord le wrapper Maven et le pom pour profiter du cache Docker
COPY mvnw pom.xml ./
COPY .mvn .mvn
RUN chmod +x mvnw && ./mvnw dependency:go-offline -B

# Copier les sources et compiler
COPY src src
RUN ./mvnw clean package -DskipTests -B

# ----------  exécution ----------
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Utilisateur non-root
RUN addgroup -S spring && adduser -S spring -G spring

COPY --from=build /app/target/*.jar app.jar

USER spring
EXPOSE 8080
ENTRYPOINT ["java", "-jar", "app.jar"]
