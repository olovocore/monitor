FROM gcr.io/cadvisor/cadvisor:latest

RUN groupadd docker && \
    usermod -aG docker root && \
    chown root:docker /var/run/docker.sock
