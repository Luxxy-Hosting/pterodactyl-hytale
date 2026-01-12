#!/bin/bash
cd /home/container || exit 1

echo "Java version:"
java -version

eval '/start.sh'