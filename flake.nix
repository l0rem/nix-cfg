{
  description = "lorem's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
    let
      configuration = { pkgs, lib, ... }: {
        nix.enable = false;

         nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) 
         [
          "arc-browser"
          # "docker"
          "google-chrome"
          "cursor"
          "postman"
          "discord"
          "teams"
          # "lmstudio"
          "vscode"
          "raycast"
          "soundsource"
          # "Xcode.app"
          "bartender"
         ];
        # System packages via Nix
        environment.systemPackages = [
          pkgs.arc-browser
          pkgs.docker
          # pkgs.ghostty
          pkgs.unnaturalscrollwheels
          pkgs.sqlitebrowser
          pkgs.google-chrome
          pkgs.code-cursor
          pkgs.postman
          pkgs.discord
          # pkgs.teams
          # pkgs.lmstudio
          # pkgs.obs-studio
          pkgs.ollama
          pkgs.jetbrains.pycharm-community-bin
          pkgs.pgadmin4
          pkgs.telegram-desktop
          pkgs.vscode
          # pkgs.vlc
          # pkgs.handbrake
          pkgs.python313
          pkgs.postgresql_15
          pkgs.raycast
          pkgs.soundsource
          # pkgs.darwin.xcode
          pkgs.zsh-autosuggestions
          pkgs.zsh-completions
          pkgs.git
          pkgs.docker-compose
          pkgs.bartender
        ];

        # Homebrew support
        homebrew = {
          enable = true;
          casks = [
            "keepingyouawake"
            "lm-studio"
          ];
          # Optional:
          # onActivation.cleanup = "uninstall"; # cleans up unlisted brews/casks
        };

        # Touch ID for sudo
        security.pam.services.sudo_local.touchIdAuth = true;

        # Nix config
        nix.settings.experimental-features = "nix-command flakes";
        system.configurationRevision = self.rev or self.dirtyRev or null;
        system.stateVersion = 6;

        # Platform
        nixpkgs.hostPlatform = "aarch64-darwin";
      };
    in
    {
      darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
