#!/bin/bash

INPUT_FILE="filelist.txt"
TEMP_DIR="/tmp/gcs-transfer-temp"

mkdir -p "$TEMP_DIR"

while IFS=, read -r SRC DST; do
  if [[ -z "$SRC" || -z "$DST" ]]; then
    echo "Skipping invalid line: $SRC,$DST"
    continue
  fi

  FILENAME=$(basename "$SRC")
  LOCAL_PATH="$TEMP_DIR/$FILENAME"

  echo "Downloading $SRC..."
  gcloud storage cp "$SRC" "$LOCAL_PATH"
  if [[ $? -ne 0 ]]; then
    echo "Failed to download $SRC"
    continue
  fi

  echo "Uploading to $DST..."
  gcloud storage cp "$LOCAL_PATH" "$DST"
  if [[ $? -ne 0 ]]; then
    echo "Failed to upload $DST"
    rm -f "$LOCAL_PATH"
    continue
  fi

  echo "Uploaded: $DST"

  # Validation step
  echo "Validating upload for $DST"
  if gcloud storage ls "$DST" >/dev/null 2>&1; then
    echo "Validation passed: $DST exists in UAT bucket."
  else
    echo "Validation failed: $DST NOT found in UAT bucket!"
  fi

  rm -f "$LOCAL_PATH"
done < "$INPUT_FILE"

rmdir "$TEMP_DIR"
