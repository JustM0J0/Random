# Use a lightweight base image
FROM alpine:latest

# Install necessary tools
RUN apk add --no-cache \
    bash \
    coreutils \
    findutils \
    tree

# Create directories to store copied host files
RUN mkdir -p /host-files/etc \
             /host-files/var \
             /host-files/home \
             /host-files/root-listing

# Copy host files into the container
# Note: These COPY commands will be executed on the host during build
COPY /etc/os-release /host-files/etc/os-release
COPY /etc/passwd /host-files/etc/passwd
COPY /etc/group /host-files/etc/group
COPY /etc/hostname /host-files/etc/hostname
COPY /etc/hosts /host-files/etc/hosts

# Copy some system directories (be careful with permissions)
COPY /var/log /host-files/var/log
COPY /proc/version /host-files/proc-version
COPY /proc/meminfo /host-files/proc-meminfo
COPY /proc/cpuinfo /host-files/proc-cpuinfo

RUN chmod +x script.sh

# Set the default command
CMD ["script.sh"]
