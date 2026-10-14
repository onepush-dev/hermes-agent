# Hermes Agent v0.22.0 (Nous Research) for Railway — pinned by digest (linux/amd64 + arm64 manifest)
# Official image keeps s6 /init ENTRYPOINT. Default upstream CMD is interactive `hermes`;
# we force gateway mode so the OpenAI-compatible API + /health stay up.
FROM nousresearch/hermes-agent:v0.22.0@sha256:c69536a39e885b8943329bda68cdf44492458b96aa74a212239bde9d2aeb406a

ENV PORT=8642 \
    API_SERVER_ENABLED=true \
    API_SERVER_HOST=0.0.0.0 \
    API_SERVER_PORT=8642 \
    API_SERVER_CORS_ORIGINS=*

EXPOSE 8642

# Keep default ENTRYPOINT (s6 /init / entrypoint-dispatch). Must be gateway run — not bare hermes.
CMD ["hermes", "gateway", "run"]
