# Opt-in: Syncthing keeps folders in sync between your own computers (laptop
# and lab workstation, say), directly, without a cloud. Manage devices and
# folders in its web page, http://127.0.0.1:8384 (or install it as a web app
# from the launcher). Enable it in hosts/.
{
  flake.modules.homeManager.syncthing = {
    services.syncthing.enable = true;
  };
}
