#!/bin/bash
cd /home/container

# Output versions for debugging
echo "=== Minecraft Plugin Generator Environment ==="
echo "Python: $(python3 --version)"
echo "Java: $(java -version 2>&1 | head -1)"
echo "Maven: $(mvn --version | head -1)"
echo "Gradle: $(gradle --version | grep Gradle)"
echo "JAVA_HOME: $JAVA_HOME"
echo "=============================================="

# Install Python dependencies if requirements.txt exists
if [ -f "requirements.txt" ]; then
    echo "[INFO] Installing Python dependencies from requirements.txt..."
    pip3 install --user -r requirements.txt
fi

# Replace Startup Variables (Pterodactyl standard)
MODIFIED_STARTUP=$(eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g'))
echo ":/home/container$ ${MODIFIED_STARTUP}"

# Run the Server

eval ${MODIFIED_STARTUP}