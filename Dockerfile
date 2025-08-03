# ----------------------------------
# Pterodactyl Minecraft Plugin Generator
# Environment: Python + Java + Maven + Gradle
# ----------------------------------
# CORREÇÃO: Remove a flag --platform para permitir que o Docker escolha a arquitetura correta.
# A imagem 'openjdk:17-jdk-slim' é multi-plataforma e suporta ARM64 (aarch64).
FROM openjdk:17-jdk-slim

LABEL author="MiiuGR4U" maintainer="minecraft-plugin-generator"

# Instala dependências do sistema, incluindo dos2unix para corrigir finais de linha.
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

# Configura o ambiente Java
ENV JAVA_HOME=/usr/local/openjdk-17
ENV PATH=$JAVA_HOME/bin:$PATH

# Cria o utilizador do contêiner (requerido pelo Pterodactyl)
RUN useradd --create-home --home-dir /home/container --shell /bin/bash container

# Copia o script de entrada
COPY entrypoint.sh /entrypoint.sh

# CORREÇÃO: Converte os finais de linha para o formato Unix e dá permissão de execução
RUN dos2unix /entrypoint.sh && chmod +x /entrypoint.sh

# Define o utilizador e o ambiente do contêiner
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Define o ponto de entrada
CMD ["/bin/bash", "/entrypoint.sh"]
