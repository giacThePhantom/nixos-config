# Email: Betterbird (a fine-tuned Thunderbird), the mail, calendar and feed
# client. Its profile lives in ~/.config/thunderbird and its cache in
# ~/.cache/thunderbird: Thunderbird 147 and later follow the XDG folders
# whenever there is no old ~/.thunderbird.
{
  flake.modules.homeManager.mail =
    { pkgs, ... }:
    {
      home.packages = [ (pkgs.callPackage ./_mail/betterbird.nix { }) ];

      # Email links and .eml files open in it
      xdg.mimeApps.defaultApplications = {
        "x-scheme-handler/mailto" = "betterbird.desktop";
        "message/rfc822" = "betterbird.desktop";
      };
    };
}
