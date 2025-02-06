{
  username,
  pkgs,
  inputs,
  ...
}:
let
  nixFlakePath = "/home/${username}/Code/nixos/xsen";
in
{
  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;
      initExtra = ''
        eval "$(starship init zsh)"
      '';
      shellAliases = {
        cat = "bat";
        ls = "eza --icons=always";
        nx-clean = ''
          sudo nix-collect-garbage -d
          home-manager expire-generations "now"
        '';
        nx-rebuild = "sudo nixos-rebuild switch --flake ${nixFlakePath} && home-manager switch --flake ${nixFlakePath}";
        nx-flake = "sudo nixos-rebuild switch --flake ${nixFlakePath}";
        nx-home = "home-manager switch --flake ${nixFlakePath}";
        sail = "sh $([ -f sail ] && echo sail || echo vendor/bin/sail)";
      };
    };
    starship = {
      enable = true;
      settings = {
        format = "[](fg:surface0)[󱄅](bg:surface0 fg:blue)$username[ ](fg:surface0 bg:surface1)$directory[ ](fg:surface1 bg:surface2)$git_branch$git_status[ ](fg:surface2 bg:surface0)[$c$rust$golang$nodejs$php$java$kotlin$haskell$python$docker_context](bg:surface0)$time[](fg:surface0)$line_break$character";
        username = {
          show_always = true;
          style_user = "bg:surface0 fg:green";
          style_root = "bg:surface0 fg:reed";
          format = "[ $user ]($style)";
        };
        directory = {
          format = "[$path ]($style)";
          style = "bg:surface1 fg:blue";
          truncation_length = 3;
          truncation_symbol = "…/";
        };
        git_status = {
          style = "bg:surface2 fg:pink";
          format = "[($all_status$ahead_behind )]($style)";
        };
        git_branch = {
          style = "bg:surface2 fg:yellow";
          format = "[$symbol$branch(:$remote_branch) ]($style)";
        };
        nodejs = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        c = {
          symbol = " ";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        rust = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        golang = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        php = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        java = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        kotlin = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        haskell = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        python = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $version) ](fg:green bg:surface0)]($style)";
        };
        docker_context = {
          symbol = "";
          style = "bg:surface0";
          format = "[[ $symbol( $context) ](fg:green bg:surface0)]($style)";
        };

        time = {
          disabled = false;
          time_format = "%R";
          style = "bg:surface0";
          format = ''[[  $time ](fg:yellow bg:surface0)]($style)'';
        };
        line_break = {
          disabled = false;
        };
        character = {
          disabled = false;
          success_symbol = "[](bold fg:green)";
          error_symbol = "[](bold fg:red)";
          vimcmd_symbol = "[](bold fg:green)";
          vimcmd_replace_one_symbol = "[](bold fg:pink)";
          vimcmd_replace_symbol = "[](bold fg:pink)";
          vimcmd_visual_symbol = "[](bold fg:yellow)";
        };
      };
    };
  };
}
