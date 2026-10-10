#!/bin/zsh
set -u
ROOT="${HF2_BRIDGE_ROOT:-${HOME}/Projects/hf2-bridge}"
ENV_DIR="$HOME/.config/hf2-bridge"
ENV_FILE="$ENV_DIR/env"
DEFAULT_MODEL="z-ai-glm-5-3-flash"
mkdir -p "$ENV_DIR"
umask 077
print -r -- "This writes only to $ENV_FILE. The key is not echoed and is not sent to GitHub."
read -rs "VENICE_KEY?Venice API key: "
if [[ -z "$VENICE_KEY" ]]; then print -u2 -- "No key entered; nothing changed."; exit 64; fi
read -r "MODEL?Model [$DEFAULT_MODEL]: "
MODEL="${MODEL:-$DEFAULT_MODEL}"
tmp=$(mktemp "$ENV_DIR/.env.XXXXXX")
trap 'rm -f "$tmp"' EXIT INT TERM
print -r -- "GOOSE_PROVIDER=venice" > "$tmp"
print -r -- "GOOSE_MODEL=$MODEL" >> "$tmp"
print -r -- "VENICE_API_KEY=$VENICE_KEY" >> "$tmp"
chmod 600 "$tmp"
mv "$tmp" "$ENV_FILE"
trap - EXIT INT TERM
unset VENICE_KEY
print -r -- "Saved $ENV_FILE with mode 600 and model $MODEL."
print -r -- "Next: run $ROOT/scripts/hf2 doctor, then install-launchd.sh when ready."

