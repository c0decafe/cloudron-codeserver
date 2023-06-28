FROM cloudron/base:4.0.0@sha256:31b195ed0662bdb06a6e8a5ddbedb6f191ce92e8bee04c03fb02dd4e9d0286df

ARG VERSION=4.14.0
ARG DEB=code-server_${VERSION}_amd64.deb
ARG URL=https://github.com/coder/code-server/releases/download/v${VERSION}/${DEB}
ARG USER=cloudron
ARG HOME=/run/home

COPY config.yaml /app/pkg/codeserver-config.yaml
COPY start.sh /app/pkg/start.sh

RUN usermod -d ${HOME} ${USER}
RUN apt update && apt install -y tmux
RUN curl -L -O ${URL} && apt install ./${DEB} && rm ${DEB}

CMD [ "/app/pkg/start.sh" ]
