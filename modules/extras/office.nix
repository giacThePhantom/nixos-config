# Opt-in: OnlyOffice, the office suite closest to Word for .docx, .xlsx and
# .pptx (same layout model, tracked changes and comments round-trip well).
# Its Zotero plugin works through zotero.org's web library; for Zotero's
# official word-processor plugin use `libreoffice` instead. Enable it in
# hosts/; the fonts that stand in for Word's are always installed
# (theme/gtk.nix).
{
  flake.modules.homeManager.office =
    { pkgs, ... }:
    let
      app = "onlyoffice-desktopeditors.desktop";
    in
    {
      home.packages = [ pkgs.onlyoffice-desktopeditors ];
      xdg.mimeApps.defaultApplications = {
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = app;
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = app;
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = app;
        "application/msword" = app;
        "application/vnd.ms-excel" = app;
        "application/vnd.ms-powerpoint" = app;
        "application/vnd.oasis.opendocument.text" = app;
        "application/vnd.oasis.opendocument.spreadsheet" = app;
        "application/vnd.oasis.opendocument.presentation" = app;
        "text/csv" = app;
      };
    };
}
