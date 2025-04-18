# Use multi-platform build to avoid QEMU simulation issues
FROM alpine:latest

# Set non-interactive mode to prevent prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Define architecture-based variables
ARG TARGETARCH
ARG VERSION
ENV AGENT_URL=https://github.com/nezhahq/agent/releases/download/${VERSION}/nezha-agent_linux_${TARGETARCH}.zip

# Install necessary dependencies
RUN apk add --no-cache \
    curl \
    wget \
    unzip \
    ca-certificates \
    uuidgen

# Create the working directory for Nezha Agent
WORKDIR /usr/local/bin/nezha

# Download and extract the Nezha Agent binary with error checking
RUN echo "Downloading Nezha Agent from ${AGENT_URL}" && \
    wget -O nezha-agent.zip "${AGENT_URL}" || { echo "Download failed"; exit 1; } && \
    unzip nezha-agent.zip || { echo "Unzip failed"; exit 1; } && \
    chmod +x nezha-agent && \
    rm -f nezha-agent.zip && \
    ls -l /usr/local/bin/nezha/nezha-agent || { echo "Binary not found"; exit 1; }

# Copy the setup configuration script
COPY setup-config.sh /usr/local/bin/nezha/setup-config.sh
RUN chmod +x /usr/local/bin/nezha/setup-config.sh

# Set default command to execute the setup script and start the agent
CMD ["sh", "-c", "./setup-config.sh && ./nezha-agent -c config.yml"]
