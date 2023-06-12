FROM openjdk:11

# Install git
RUN apt-get update && \
    apt-get install -y --no-install-recommends git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Clone repository and install synthea
WORKDIR /opt
RUN git clone https://github.com/synthetichealth/synthea.git && \
    cd synthea && \
    ./gradlew build; exit 0

# Set the entrypoint to run synthea
WORKDIR /opt/synthea
ENTRYPOINT ["./run_synthea"]