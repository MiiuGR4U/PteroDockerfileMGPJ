# ----------------------------------
# Pterodactyl Minecraft Plugin Generator
# Environment: Python + Java 21 + Maven + Gradle
# ----------------------------------
# CORREÇÃO: Usa a imagem base oficial do Eclipse Temurin para Java 21, que é multi-plataforma.
FROM eclipse-temurin:21-jdk-slim

LABEL author="MiiuGR4U" maintainer="minecraft-plugin-generator"

# Instala dependências do sistema
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    openssl \
    git \
    tar \
    bash \
    wget \
    unzip \
    python3 \
    python3-pip \
    python3-venv \
    maven \
    dos2unix \
    && rm -rf /var/lib/apt/lists/*

# Instala o Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-8.5-bin.zip \
    && unzip -q gradle-8.5-bin.zip \
    && mv gradle-8.5 /opt/gradle \
    && ln -s /opt/gradle/bin/gradle /usr/bin/gradle \
    && rm gradle-8.5-bin.zip

# Instala as dependências Python necessárias para o agente de IA
RUN pip3 install --no-cache-dir google-generativeai python-dotenv PyGithub requests

# CORREÇÃO: Configura o ambiente Java para o caminho correto da imagem Temurin
ENV JAVA_HOME=/opt/java/openjdk
ENV PATH=$JAVA_HOME/bin:$PATH

# Cria o utilizador do contêiner (requerido pelo Pterodactyl)
RUN useradd --create-home --home-dir /home/container --shell /bin/bash container

# Copia o script de entrada
COPY entrypoint.sh /entrypoint.sh

# Converte os finais de linha para o formato Unix e dá permissão de execução
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

# Define o utilizador e o ambiente do contêiner
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Define o ponto de entrada
CMD ["/bin/bash", "/entrypoint.sh"]
