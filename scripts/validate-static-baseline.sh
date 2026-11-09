#!/usr/bin/env sh
set -eu
for f in index.html styles.css app.js sw.js manifest.webmanifest README.md; do
  test -s "$f" || { echo "MISSING_OR_EMPTY: $f"; exit 1; }
done
grep -q "echectuto" app.js || { echo "Unexpected app.js"; exit 1; }
grep -q "v191" sw.js || { echo "Service worker cache is not v191"; exit 1; }
echo "EchecTuto v191 static baseline: OK"
