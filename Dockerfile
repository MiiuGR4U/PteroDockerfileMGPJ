# ----------------------------------
# Pterodactyl Minecraft Plugin Generator
# Environment: Python + Java + Maven + Gradle
# ----------------------------------
FROM openjdk:17-jdk-slim

LABEL author="Minecraft Plugin Generator" maintainer="admin@pterodactyl.io"

# Install system dependencies
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
    && rm -rf /var/lib/apt/lists/*

# Install Gradle
RUN wget -q https://services.gradle.org/distributions/gradle-8.5-bin.zip \
    && unzip -q gradle-8.5-bin.zip \
    && mv gradle-8.5 /opt/gradle \
    && ln -s /opt/gradle/bin/gradle /usr/bin/gradle \
    && rm gradle-8.5-bin.zip

# Install Python dependencies for Minecraft Plugin Generator
RUN pip3 install --no-cache-dir google-generativeai python-dotenv

# Configure Java environment
ENV JAVA_HOME=/usr/local/openjdk-17
ENV PATH=$JAVA_HOME/bin:$PATH

# Create container user (required by Pterodactyl)
RUN useradd --create-home --home-dir /home/container --shell /bin/bash container

# Set container user and environment
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Copy entrypoint script
COPY ./entrypoint.sh /entrypoint.sh

# Set entrypoint
CMD ["/bin/bash", "/entrypoint.sh"]