#!/bin/bash

set -eu

OWN="cloudron:cloudron"
GSU="/usr/local/bin/gosu $OWN"
ENV="/app/data/env"
HOME="/run/home"

if [[ ! -f $ENV  ]]; then
     $GSU cat > $ENV <<EOF
CS_DISABLE_GETTING_STARTED_OVERRIDE=false
FOLDER="/app/data/workspaces"
PS1=">"
EOF
fi

source $ENV

export XDG_CONFIG_HOME="/app/data/.local/share"
export XDG_DATA_HOME="/app/data/.local/share"
export XDG_STATE_HOME="/app/data/.local/state"

DIRS="$HOME $FOLDER $XDG_CONFIG_HOME $XDG_DATA_HOME $XDG_STATE_HOME"

mkdir -p $DIRS

if [[ ! -L ${XDG_CONFIG_HOME}/code-server/config.yaml  ]]; then
     mkdir -p ${XDG_CONFIG_HOME}/code-server
     ln -s /app/pkg/codeserver-config.yaml \
         ${XDG_CONFIG_HOME}/code-server/config.yaml
fi

echo "==> Ensure permissions"
chown -R $OWN $DIRS

if [[ ! -f /app/data/.initialized  ]]; then
     echo "Fresh installation, init"
     $GSU code-server --install-extension vscode.git-base ## init no-op
     touch /app/data/.initialized
fi

LOGS="$XDG_DATA_HOME/code-server/logs"
CODER_LOGS="$XDG_DATA_HOME/code-server/coder-logs"

if [[ -d $LOGS ]]; then
      mv $LOGS /run/
      ln -s /run/logs $LOGS
fi

if [[ -d $CODER_LOGS ]]; then
      mv $CODER_LOGS /run/
      ln -s /run/coder-logs $CODER_LOGS
fi

echo "==> Starting code-server"
exec $GSU code-server $FOLDER
