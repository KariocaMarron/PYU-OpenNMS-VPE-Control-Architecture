#!/usr/bin/env bash
# Builds local config files from *.template, using the values in .env.
# Run once after cloning, and again whenever .env changes.
set -euo pipefail
cd "$(dirname "$0")"
[ -f .env ] || { echo "Missing .env: copy .env.example to .env first"; exit 1; }
set -a; . ./.env; set +a
vars=$(sed -n 's/^\([A-Z_][A-Z0-9_]*\)=.*/$\1/p' .env | tr '\n' ' ')
count=0
for t in $(git ls-files '*.template'); do
  envsubst "$vars" < "$t" > "${t%.template}"
  count=$((count+1))
done
echo "Rendered $count file(s) from templates."
