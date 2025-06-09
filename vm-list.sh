#!/bin/bash

# Define constants
GCS_PATH="gs://northamerica/canada/internal/*/delete/**"
CUTOFF_DATE="2025-03-31"
OUTPUT_FILE="test"

# Convert cutoff date to epoch timestamp
cutoff_epoch=$(date -d "$CUTOFF_DATE" +%s)

# Start clean output file
> "$OUTPUT_FILE"

echo "Listing files modified on or before $CUTOFF_DATE, excluding .yml files..."
echo "Results will be written to: $OUTPUT_FILE"
echo

# Run gsutil ls -l and filter
gsutil ls -l $GCS_PATH | grep -v '^ *TOTAL:' | while read -r size timestamp filepath; do
    # Skip .yml files or malformed lines
    [[ -z "$timestamp" || -z "$filepath" || "$filepath" == *.yml ]] && continue

    # Convert timestamp to epoch
    file_epoch=$(date -d "$timestamp" +%s)

    # Compare with cutoff
    if [[ $file_epoch -le $cutoff_epoch ]]; then
        echo "$size  $timestamp  $filepath" | tee -a "$OUTPUT_FILE"
    fi
done
