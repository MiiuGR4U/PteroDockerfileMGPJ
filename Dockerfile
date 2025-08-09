# ----------------------------------
# Pterodactyl Minecraft Plugin Generator
# Base: Debian Bullseye (ARM64)
# Environment: Python 3, Java 21 (Temurin), Maven, Gradle
# ----------------------------------
FROM debian:bullseye-slim

LABEL author="MiiuGR4U" maintainer="minecraft-plugin-generator"

ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências essenciais
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    gnupg \
    software-properties-common \
    git \
    tar \
    bash \
    wget \
    unzip \
    python3 \
    python3-pip \
    dos2unix \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Instala o Java 21 (Temurin) ARM64 e define como padrão
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" > /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Define JAVA_HOME correto para ARM64 e adiciona para todos os usuários
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk-arm64
ENV PATH=$JAVA_HOME/bin:$PATH
RUN echo "export JAVA_HOME=$JAVA_HOME" > /etc/profile.d/java.sh && \
    echo "export PATH=\$JAVA_HOME/bin:\$PATH" >> /etc/profile.d/java.sh

# Instala Maven manualmente
RUN wget -q https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz \
    && tar -xzf apache-maven-3.9.6-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.9.6/bin/mvn /usr/bin/mvn \
    && rm apache-maven-3.9.6-bin.tar.gz

# Instala Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-8.5-bin.zip \
    && unzip -q gradle-8.5-bin.zip \
    && mv gradle-8.5 /opt/gradle \
    && ln -s /opt/gradle/bin/gradle /usr/bin/gradle \
    && rm gradle-8.5-bin.zip

# Instala dependências Python
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir google-generativeai python-dotenv PyGithub requests

# Cria usuário do container (Pterodactyl)
RUN useradd --create-home --home-dir /home/container --shell /bin/bash container

# Copia entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

# Define usuário e diretório de trabalho
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Ponto de entrada
CMD ["/bin/bash", "/entrypoint.sh"]
