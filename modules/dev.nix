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
      port = 8070;
    };
    ollama = {
      enable = false;
      package = pkgs.ollama-cuda;
    };
  };

  environment.systemPackages = with pkgs; [
    glib
    net-tools
    mkcert
    php83
    php83Packages.composer
    nodejs
    pkg-config
    openssl
    openssl.dev
    lazygit
    lazydocker
    neovim
    jetbrains-toolbox
    gemini-cli
    claude-code
    opencode
    codex
    llmfit
    python3
    # zed-editor
    # jetbrains.jdk
    # code-cursor
    # vscode
  ];
}
