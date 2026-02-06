FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV PORT=8080

RUN apt update && apt install -y \
    openssh-server \
    curl \
    ca-certificates \
    netcat-openbsd \
    && rm -rf /var/lib/apt/lists/*

# Install wstunnel
RUN curl -L https://github.com/erebe/wstunnel/releases/download/v9.2.3/wstunnel-linux-x64 \
    -o /usr/local/bin/wstunnel && chmod +x /usr/local/bin/wstunnel

# SSH setup
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

EXPOSE 8080

CMD sh -c "\
  /usr/sbin/sshd && \
  /usr/local/bin/wstunnel server \
    --port ${PORT} \
    --host 0.0.0.0 \
    --restrictTo 127.0.0.1:22 \
    --websocketPingIntervalSec 30 \
"
