cat > Dockerfile <<'EOF'
FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        ca-certificates \
        coreutils \
        file \
        git \
        grep \
        sed \
        gawk \
        less \
        ncurses-bin \
        libxml2-utils \
        jq \
    && rm -rf /var/lib/apt/lists/*

# Official Exploit-DB repository
RUN git clone --depth 1 \
        https://gitlab.com/exploit-database/exploitdb.git \
        /opt/exploitdb \
    && ln -sf /opt/exploitdb/searchsploit \
        /usr/local/bin/searchsploit \
    && cp /opt/exploitdb/.searchsploit_rc \
        /etc/searchsploit_rc

ENV PAGER=less

ENTRYPOINT ["/usr/local/bin/searchsploit"]
EOF
