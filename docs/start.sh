#!/bin/bash
docker run -d -p 8000:80 -v "$(pwd):/usr/share/nginx/html" nginx
# python -m SimpleHTTPServer 8000 &
sleep 1
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --kiosk http://localhost:8000
