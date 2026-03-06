#!/bin/bash
set -e

# ─── Configuration ────────────────────────────────────────────────────────────
GDRIVE_FILE_ID="1UuFgZ-kwRryPC-vK7w64xX0VO4iOAeGt"
DOWNLOAD_PATH="/tmp/nnResults.zip"
UNZIP_DIR="/tmp/nnResults_unzipped"
DEST_DIR="/workspace/TIPs/nnResults"
MIN_FILE_SIZE=100000   # bytes

# ─── Step 1: Install gdown if not already available ───────────────────────────
echo "[1/4] Installing gdown..."
pip install --quiet gdown

# ─── Step 2: Download model archive from Google Drive ─────────────────────────
echo "[2/4] Downloading model archive..."
gdown "${GDRIVE_FILE_ID}" -O "${DOWNLOAD_PATH}"

# Verify file size
ACTUAL_SIZE=$(stat -c%s "${DOWNLOAD_PATH}" 2>/dev/null || stat -f%z "${DOWNLOAD_PATH}")
if [ "${ACTUAL_SIZE}" -le "${MIN_FILE_SIZE}" ]; then
    echo "ERROR: Download failed or file too small (${ACTUAL_SIZE} bytes)."
    rm -f "${DOWNLOAD_PATH}"
    exit 1
fi
echo "    Downloaded ${ACTUAL_SIZE} bytes — OK."

# ─── Step 3: Extract archive ──────────────────────────────────────────────────
echo "[3/4] Extracting archive..."
mkdir -p "${UNZIP_DIR}"
unzip -q "${DOWNLOAD_PATH}" -d "${UNZIP_DIR}"
rm -f "${DOWNLOAD_PATH}"

# ─── Step 4: Install model into destination ───────────────────────────────────
echo "[4/4] Installing model to ${DEST_DIR}..."
mkdir -p "${DEST_DIR}"
cp -r "${UNZIP_DIR}"/. "${DEST_DIR}/"
rm -rf "${UNZIP_DIR}"

echo "Done. Model files are ready at ${DEST_DIR}."

# Hand off to the command passed as arguments (e.g. CMD ["bash"])
exec "$@"