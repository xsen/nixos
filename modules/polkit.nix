{ pkgs, username, ... }:
{
  security.polkit = {
    enable = true;
    extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.policykit.exec" && subject.isInGroup("users")) {
          if (action.lookup("program") == '/run/current-system/sw/bin/pkill') {
              return polkit.Result.YES;
          }
          if (action.lookup("command_line") == "/run/current-system/sw/bin/bash /home/${username}/.config/nekoray/config/vpn-run-root.sh") {
            return polkit.Result.YES;
          }
        }
      });
    '';
  };

  environment.systemPackages = with pkgs; [
    polkit
    lxqt.lxqt-policykit
  ];
}
