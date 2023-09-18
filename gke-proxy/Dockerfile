# Start from gcloud CLI image
FROM google/cloud-sdk:alpine@sha256:c8b0159cdda5c9a64d6a84de24b5a29ca0657dc803a1cbd8a55c6f086f050bb8

# Install kubectl
RUN gcloud components install kubectl

# Entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
CMD [ "/entrypoint.sh" ]