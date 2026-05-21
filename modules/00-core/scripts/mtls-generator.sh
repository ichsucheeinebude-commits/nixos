#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════════
# mtls-generator.sh — Automated mTLS Client Certificate Generation
#
# Usage: bash mtls-generator.sh [client_name]
# Output: client.p12 (including CA chain)
#
# Pattern: Creates a self-signed CA on first run, then issues
#          client certificates signed by that CA.
#          Exported as PKCS#12 for easy browser/mobile import.
# ═══════════════════════════════════════════════════════════════════

set -euo pipefail

CLIENT_NAME="${1:-new-device}"
CERT_DIR="/etc/nixos/secrets/mtls"
CA_KEY="$CERT_DIR/ca.key"
CA_CRT="$CERT_DIR/ca.crt"
OUTPUT_DIR="/var/www/landing-zone/certs"

mkdir -p "$CERT_DIR" "$OUTPUT_DIR"

# 1. Generate CA if not present
if [ ! -f "$CA_CRT" ]; then
    echo "🛡️  Generating new mTLS Master CA..."
    openssl genrsa -out "$CA_KEY" 4096
    openssl req -x509 -new -nodes -key "$CA_KEY" -sha256 -days 3650 \
        -out "$CA_CRT" -subj "/CN=NixOS-mTLS-CA"
    chmod 600 "$CA_KEY"
fi

# 2. Generate client certificate
echo "🔑 Generating certificate for: $CLIENT_NAME..."
CLIENT_KEY="$CERT_DIR/$CLIENT_NAME.key"
CLIENT_CSR="$CERT_DIR/$CLIENT_NAME.csr"
CLIENT_CRT="$CERT_DIR/$CLIENT_NAME.crt"
CLIENT_P12="$OUTPUT_DIR/$CLIENT_NAME.p12"

openssl genrsa -out "$CLIENT_KEY" 2048
openssl req -new -key "$CLIENT_KEY" -out "$CLIENT_CSR" \
    -subj "/CN=$CLIENT_NAME"
openssl x509 -req -in "$CLIENT_CSR" -CA "$CA_CRT" -CAkey "$CA_KEY" \
    -CAcreateserial -out "$CLIENT_CRT" -days 365 -sha256

# 3. Export as .p12 (for browser/mobile import)
openssl pkcs12 -export -out "$CLIENT_P12" \
    -inkey "$CLIENT_KEY" -in "$CLIENT_CRT" -certfile "$CA_CRT" \
    -passout pass:

# 4. Cleanup & Permissions
rm -f "$CLIENT_CSR"
chmod 644 "$CLIENT_P12"
chown caddy:caddy "$CLIENT_P12"

echo "✅ Success! Certificate created: $CLIENT_P12"
echo "------------------------------------------------------"
echo "📥 Download from landing zone certs directory"
echo "------------------------------------------------------"
echo "(Note: Import certificate in browser, password is empty)"
