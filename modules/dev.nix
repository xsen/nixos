{ username, pkgs, ... }:
let
  vHosts = import ./dev-hosts.nix;
in
{
  users.users."${username}".extraGroups = [
    "docker"
  ];

  virtualisation = {
    docker = {
      enable = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
      };
    };
  };

  networking.hosts = vHosts.hosts;

  services = {
    nginx = {
      enable = true;
      virtualHosts = vHosts.virtualHosts;
    };
    open-webui = {
      enable = false;
    };
    ollama = {
      enable = false;
      acceleration = "cuda";
      environmentVariables = {
        OLLAMA_LLM_LIBRARY = "cuda";
        LD_LIBRARY_PATH = "run/opengl-driver/lib";
      };
    };
  };

  environment.systemPackages = with pkgs; [
    glib
    mkcert
    php83
    php83Packages.composer
    nodejs
    pkg-config
    openssl
    openssl.dev
    #    (alpaca.override {
    #      ollama = ollama-cuda;
    #    })
    neovim
    jetbrains-toolbox
    jetbrains.jdk
    code-cursor
    vscode
  ];
}
