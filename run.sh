#!/usr/bin/env bash
set -euo pipefail

ENV_FILE="$(dirname "$0")/.env"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "ERROR: .env file not found at $ENV_FILE"
  exit 1
fi

# Load values from .env (ignores comment lines and blank lines)
OWM_API_KEY="$(grep -E '^OWM_API_KEY=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '[:space:]')"
CLOUDINARY_CLOUD_NAME="$(grep -E '^CLOUDINARY_CLOUD_NAME=' "$ENV_FILE" | cut -d'=' -f2- | tr -d '[:space:]')"

if [[ -z "$OWM_API_KEY" ]]; then
  echo "ERROR: OWM_API_KEY not found in .env"
  exit 1
fi

if [[ -z "$CLOUDINARY_CLOUD_NAME" ]]; then
  echo "ERROR: CLOUDINARY_CLOUD_NAME not found in .env"
  exit 1
fi

echo "Running with live OpenWeatherMap data and Cloudinary videos..."
flutter run \
  --dart-define=OWM_API_KEY="$OWM_API_KEY" \
  --dart-define=CLOUDINARY_CLOUD_NAME="$CLOUDINARY_CLOUD_NAME" \
  "$@"
