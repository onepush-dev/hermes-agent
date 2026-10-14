# Hermes Agent v0.22.0 (Nous Research) for Railway — pinned by digest (linux/amd64 + arm64 manifest)
# Official image: keeps s6 /init ENTRYPOINT; default CMD is gateway run
FROM nousresearch/hermes-agent:v0.22.0@sha256:c69536a39e885b8943329bda68cdf44492458b96aa74a212239bde9d2aeb406a

# Persist all Hermes state at /opt/data (NOT /data — that path is wrong and wipes memory)
ENV PORT=8642 \
    API_SERVER_ENABLED=true \
    API_SERVER_HOST=0.0.0.0 \
    API_SERVER_PORT=8642 \
    API_SERVER_CORS_ORIGINS=*

EXPOSE 8642

# Keep default ENTRYPOINT (s6 /init); CMD gateway run
CMD ["gateway", "run"]
