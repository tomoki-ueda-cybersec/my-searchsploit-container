FROM debian:bookworm-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash \
        git \
        ca-certificates \
        coreutils \
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
    /opt/exploitdb

# searchsploit executable
RUN ln -s /opt/exploitdb/searchsploit /usr/local/bin/searchsploit

# Configure database location
RUN sed \
    's|path_array+=(.*)|path_array+=("/opt/exploitdb")|g' \
    /opt/exploitdb/.searchsploit_rc \
    > /etc/searchsploit_rc

ENV PAGER=less

ENTRYPOINT ["searchsploit"]
