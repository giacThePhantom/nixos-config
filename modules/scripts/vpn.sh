# vpn | vpn off: connect to the university's GlobalProtect VPN (vpnPortal in
# settings.nix), or disconnect from another terminal; Super+Shift+V opens a
# terminal running it. It stays in the foreground while connected, and
# Ctrl+C disconnects. The login (with MFA) is the university's own page, in
# a window. --fix-openssl: the portal needs OpenSSL's legacy options.
# --hip: send the host integrity report (gpclient's bundled hipreport.sh);
# it goes after the portal, as it takes an optional script path and would
# take the portal for one.
# gpclient is used from the Nix store, not installed on PATH; it needs root
# for the tunnel, and sudo -E keeps the session so the login window opens.
if [ "${1:-}" = off ]; then
  exec sudo "$GPCLIENT" disconnect
fi
exec sudo -E "$GPCLIENT" --fix-openssl connect "$VPN_PORTAL" --hip
