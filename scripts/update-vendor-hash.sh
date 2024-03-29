#!/usr/bin/env nix-shell
#!nix-shell -i bash -p nix -p coreutils -p gnused -p gawk

set -exuo pipefail
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
failedbuild=$(nix build --impure --expr "((builtins.getFlake \"$SCRIPT_DIR/..#\").packages.\${builtins.currentSystem}.matrix-hook.override { vendorHash = \"\"; })" 2>&1 || true)
echo "$failedbuild"
checksum=$(echo "$failedbuild" | awk '/got:.*sha256/ { print $2 }')
sed -i -e "s|vendorHash ? \".*\"|vendorHash ? \"$checksum\"|" "$SCRIPT_DIR/../pkgs/matrix-hook.nix"

