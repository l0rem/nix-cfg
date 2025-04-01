{
  description = "lorem's nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nix-darwin,
      nixpkgs,
    }:
    let
      configuration =
        { pkgs, lib, ... }:
        {
          nix.enable = false;

          nixpkgs.config.allowUnfreePredicate =
            pkg:
            builtins.elem (lib.getName pkg) [
              "arc-browser"
              "google-chrome"
              "cursor"
              "postman"
              "discord"
              "teams"
              "vscode"
              "raycast"
              "soundsource"
              "bartender"
              "mongodb-ce"
            ];

          environment.systemPackages = [
            pkgs.arc-browser
            pkgs.docker
            pkgs.unnaturalscrollwheels
            pkgs.sqlitebrowser
            pkgs.google-chrome
            pkgs.code-cursor
            pkgs.postman
            pkgs.discord
            pkgs.ollama
            pkgs.jetbrains.pycharm-community-bin
            pkgs.pgadmin4
            pkgs.telegram-desktop
            pkgs.vscode
            pkgs.python313
            pkgs.postgresql_15
            pkgs.raycast
            pkgs.soundsource
            pkgs.zsh-autosuggestions
            pkgs.zsh-completions
            pkgs.git
            pkgs.docker-compose
            pkgs.bartender
            pkgs.redis
            pkgs.nixfmt-rfc-style
            pkgs.mongodb-ce
          ];

          homebrew = {
            enable = true;
            casks = [
              "keepingyouawake"
              "lm-studio"
              "handbrake"
              "vlc"
              "obs"
              "docker"
              "microsoft-teams"
              "ghostty"
              "cleanshot"
              "windscribe"
              "obsidian"
              "mongodb-compass"
            ];
          };

          launchd.daemons.redis = {
            serviceConfig = {
              Label = "org.nixos.redis";
              ProgramArguments = [ "${pkgs.redis}/bin/redis-server" ];
              KeepAlive = true;
              RunAtLoad = true;
              StandardOutPath = "/tmp/redis.log";
              StandardErrorPath = "/tmp/redis-error.log";
            };
          };

          launchd.daemons.mongodb = {
            serviceConfig = {
              Label = "org.nixos.mongodb";
              ProgramArguments = [
                "${pkgs.mongodb-ce}/bin/mongod"
                "--dbpath"
                "/var/db/mongodb"
              ];
              KeepAlive = true;
              RunAtLoad = true;
              StandardOutPath = "/tmp/mongodb.log";
              StandardErrorPath = "/tmp/mongodb-error.log";
            };
          };

          system.activationScripts.postActivation.text = ''
            echo "Running mongodbDataDir script" >> /tmp/mongo-script.log
            mkdir -p /var/db/mongodb
            chown "$(id -un)" /var/db/mongodb
          '';

          security.pam.services.sudo_local.touchIdAuth = true;

          nix.settings.experimental-features = "nix-command flakes";
          system.configurationRevision = self.rev or self.dirtyRev or null;
          system.stateVersion = 6;

          nixpkgs.hostPlatform = "aarch64-darwin";
        };
    in
    {
      darwinConfigurations."mbp" = nix-darwin.lib.darwinSystem {
        modules = [ configuration ];
      };
    };
}
