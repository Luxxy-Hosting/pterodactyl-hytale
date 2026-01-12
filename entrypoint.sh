#!/bin/bash
cd /home/container || exit 1

echo "Java version:"
java -version

# Replace variables and start server
eval ${STARTUP}