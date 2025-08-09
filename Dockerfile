# ----------------------------------
# Pterodactyl Minecraft Plugin Generator
# Base: Debian Bullseye
# Environment: Python 3, Java 21 (Temurin), Maven, Gradle
# ----------------------------------
FROM debian:bullseye-slim

LABEL author="MiiuGR4U" maintainer="minecraft-plugin-generator"

ENV DEBIAN_FRONTEND=noninteractive

# Instala dependências essenciais, incluindo ferramentas para adicionar repositórios e compilar
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

# Instala o Java 21 (Eclipse Temurin) e define-o como o padrão do sistema
RUN wget -qO - https://packages.adoptium.net/artifactory/api/gpg/key/public | apt-key add - \
    && echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/adoptium.list \
    && apt-get update \
    && apt-get install -y temurin-21-jdk \
    && rm -rf /var/lib/apt/lists/*

# Instala o Maven manualmente
RUN wget -q https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz \
    && tar -xzf apache-maven-3.9.6-bin.tar.gz -C /opt \
    && ln -s /opt/apache-maven-3.9.6/bin/mvn /usr/bin/mvn \
    && rm apache-maven-3.9.6-bin.tar.gz

# Instala o Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-8.5-bin.zip \
    && unzip -q gradle-8.5-bin.zip \
    && mv gradle-8.5 /opt/gradle \
    && ln -s /opt/gradle/bin/gradle /usr/bin/gradle \
    && rm gradle-8.5-bin.zip

# Instala as dependências Python
RUN pip3 install --no-cache-dir --upgrade pip && \
    pip3 install --no-cache-dir google-generativeai python-dotenv PyGithub requests

# Configura o ambiente Java
ENV JAVA_HOME=/usr/lib/jvm/temurin-21-jdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Cria o utilizador do contêiner (requerido pelo Pterodactyl)
RUN useradd --create-home --home-dir /home/container --shell /bin/bash container

# Copia o script de entrada
COPY entrypoint.sh /entrypoint.sh

# Garante permissões e formato corretos para o entrypoint
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

# Define o utilizador e o ambiente do contêiner
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Define o ponto de entrada
CMD ["/bin/bash", "/entrypoint.sh"]
