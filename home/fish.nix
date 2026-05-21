{
  pkgs,
  config,
  inputs,
  lib,
  ...
}:
{
  programs = {
    fish = {
      enable = true;
      interactiveShellInit = ''
        if not set -q COLORTERM
          set -gx COLORTERM truecolor
        end

        fish_vi_key_bindings
        set -g fish_greeting ""

        function b
          bash -c "$argv"
        end

        function done
          $argv
          set -l status_code $status
          set -l full_cmd (string join " " $argv)

          if test $status_code -eq 0
            notify-send "Выполнено успешно" "$full_cmd" -i terminal -t 3000
          else
            notify-send "Ошибка ($status_code)" "$full_cmd" -u critical -i error
          end
        end

        if status is-interactive
          if set -q TERMINAL_EMULATOR; or set -q JEDITERM_SOURCE_PURGE
              fish_config theme choose "catppuccin-mocha" --color-theme=dark 2>/dev/null
          else
              fish_config theme choose "catppuccin-mocha" 2>/dev/null
          end
        end
      '';

      shellAliases = {
        ls = "eza --icons=always";
        nh-clean = "nh clean all";
        nh-all = "nh os switch && nh home switch";
        nh-os = "nh os switch";
        nh-home = "nh home switch";
      };

      functions = {
        sail = {
          body = ''
            if test -f sail
                sh sail $argv
            else
                sh vendor/bin/sail $argv
            end
          '';
        };
      };
    };

    starship = {
      enable = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
      settings = {
        add_newline = false;
        format = lib.concatStrings [
          "[](fg:surface0)"
          "[󱄅](bg:surface0 fg:blue)$username"
          "[ ](fg:surface0 bg:surface1)"
          "$directory"
          "[ ](fg:surface1 bg:surface2)$git_branch$git_status"
          "[ ](fg:surface2 bg:surface0)"
          "[$c$rust$golang$nodejs$php$java$kotlin$haskell$python$docker_context](bg:surface0)"
          "$time"
          "[](fg:surface0)$line_break$character"
        ];
        username = {
          show_always = true;
          style_user = "bg:surface0 fg:green";
          style_root = "bg:surface0 fg:red";
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
          format = "[[  $time ](fg:yellow bg:surface0)]($style)";
        };
        line_break = {
          disabled = false;
        };
        character = {
          disabled = false;
          success_symbol = "[](bold fg:green)";
          error_symbol = "[](bold fg:red)";
          vimcmd_symbol = "[](bold fg:green)";
          vimcmd_replace_one_symbol = "[](bold fg:pink)";
        };
      };
    };
  };
}
