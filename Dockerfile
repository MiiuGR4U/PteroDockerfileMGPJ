# ----------------------------------
# Pterodactyl Minecraft Plugin Generator
# Environment: Python + Java + Maven + Gradle
# ----------------------------------
FROM --platform=linux/amd64 openjdk:17-jdk-slim

LABEL author="MiiuGR4U" maintainer="minecraft-plugin-generator"

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

# Copy entrypoint script and give execute permission
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set container user and environment
USER container
ENV USER=container HOME=/home/container
WORKDIR /home/container

# Set entrypoint
CMD ["/bin/bash", "/entrypoint.sh"]
