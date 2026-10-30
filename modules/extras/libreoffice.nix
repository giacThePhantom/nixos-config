# Opt-in alternative to `office`: LibreOffice, for writing with Zotero's
# official word-processor plugin (live citations and bibliography). Weaker
# than OnlyOffice at keeping Word documents' layout. Enable one of the two in
# hosts/.
{
  flake.modules.homeManager.libreoffice =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.libreoffice-fresh ];
      xdg.mimeApps.defaultApplications = {
        "application/vnd.openxmlformats-officedocument.wordprocessingml.document" = "writer.desktop";
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet" = "calc.desktop";
        "application/vnd.openxmlformats-officedocument.presentationml.presentation" = "impress.desktop";
        "application/msword" = "writer.desktop";
        "application/vnd.ms-excel" = "calc.desktop";
        "application/vnd.ms-powerpoint" = "impress.desktop";
        "application/vnd.oasis.opendocument.text" = "writer.desktop";
        "application/vnd.oasis.opendocument.spreadsheet" = "calc.desktop";
        "application/vnd.oasis.opendocument.presentation" = "impress.desktop";
        "text/csv" = "calc.desktop";
      };
    };
}
