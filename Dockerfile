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

# Create a script to analyze the copied files
RUN cat > /usr/local/bin/analyze-host-files.sh << 'EOF'
#!/bin/bash

echo "================================"
echo "COPIED HOST FILES ANALYSIS"
echo "================================"

echo "Structure of copied host files:"
tree /host-files 2>/dev/null || find /host-files -type f | sort

echo ""
echo "================================"
echo "HOST OS RELEASE INFORMATION"
echo "================================"

if [ -f /host-files/etc/os-release ]; then
    echo "Contents of host /etc/os-release:"
    cat /host-files/etc/os-release
else
    echo "Host os-release not copied"
fi

echo ""
echo "================================"
echo "HOST SYSTEM FILES"
echo "================================"

echo "Host hostname:"
cat /host-files/etc/hostname 2>/dev/null || echo "Hostname not available"

echo ""
echo "Host /etc/hosts:"
cat /host-files/etc/hosts 2>/dev/null || echo "Hosts file not available"

echo ""
echo "Host kernel version:"
cat /host-files/proc-version 2>/dev/null || echo "Kernel version not available"

echo ""
echo "Host memory info (first 10 lines):"
head -10 /host-files/proc-meminfo 2>/dev/null || echo "Memory info not available"

echo ""
echo "Host CPU info:"
grep "model name" /host-files/proc-cpuinfo | head -1 2>/dev/null || echo "CPU info not available"

echo ""
echo "================================"
echo "HOST LOG FILES"
echo "================================"

echo "Available log files:"
find /host-files/var/log -type f 2>/dev/null | head -20 || echo "Log files not available"

echo ""
echo "Recent entries from syslog (if available):"
tail -10 /host-files/var/log/syslog 2>/dev/null || \
tail -10 /host-files/var/log/messages 2>/dev/null || \
echo "System log not available"

echo ""
echo "================================"
echo "CONTAINER vs HOST COMPARISON"
echo "================================"

echo "Container OS Release:"
cat /etc/os-release 2>/dev/null || echo "Container os-release not available"

EOF

RUN chmod +x /usr/local/bin/analyze-host-files.sh

# Set the default command
CMD ["/usr/local/bin/analyze-host-files.sh"]
