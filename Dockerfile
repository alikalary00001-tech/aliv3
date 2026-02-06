FROM node:20-bookworm-slim

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    openssh-server ca-certificates \
  && rm -rf /var/lib/apt/lists/*

# SSH setup
RUN mkdir -p /var/run/sshd \
 && echo 'root:root' | chpasswd \
 && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
 && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config \
 && printf "\nListenAddress 127.0.0.1\n" >> /etc/ssh/sshd_config

WORKDIR /app
COPY package.json package-lock.json* /app/
RUN npm install --omit=dev || npm install --production

COPY server.js /app/server.js

EXPOSE 8080

# Start sshd, then start HTTP/WS server on $PORT
CMD ["/bin/sh","-c","/usr/sbin/sshd && node /app/server.js"]
