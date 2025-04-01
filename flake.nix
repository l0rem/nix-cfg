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
      mongoConfigPath = "/etc/mongod.conf";
      mongoInitScript = "/etc/mongo-init.js";
      mongoDataDir = "/var/db/mongodb";
      redisDataDir = "/var/db/redis";
      redisConfigPath = "/etc/redis.conf";
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
            pkgs.mongosh
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

          environment.etc."mongod.conf".text = ''
            systemLog:
              destination: file
              path: /var/log/mongodb/mongod.log
              logAppend: true

            storage:
              dbPath: ${mongoDataDir}

            net:
              bindIp: 127.0.0.1
              port: 27017

            security:
              authorization: enabled
          '';

          environment.etc."mongo-init.js".text = ''
            db = db.getSiblingDB('admin');
            db.createUser({
              user: 'mongo',
              pwd: 'mongopass',
              roles: [ { role: 'root', db: 'admin' } ]
            });
          '';

          environment.etc."redis.conf".text = ''
            dir ${redisDataDir}
            save 900 1
            save 300 10
            save 60 10000
            dbfilename dump.rdb
            bind 127.0.0.1
            port 6379
          '';

          launchd.daemons.redis = {
            serviceConfig = {
              Label = "org.nixos.redis";
              ProgramArguments = [
                "${pkgs.redis}/bin/redis-server"
                "${redisConfigPath}"
              ];
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
                "--config"
                "${mongoConfigPath}"
              ];
              KeepAlive = true;
              RunAtLoad = true;
              StandardOutPath = "/tmp/mongodb.log";
              StandardErrorPath = "/tmp/mongodb-error.log";
            };
          };

          system.activationScripts.postActivation.text = ''
            echo "Setting up MongoDB..." >> /tmp/mongo-script.log

            mkdir -p /var/log/mongodb
            touch /var/log/mongodb/mongod.log
            chown "$(id -un)" /var/log/mongodb /var/log/mongodb/mongod.log

            mkdir -p ${mongoDataDir}
            chown "$(id -un)" ${mongoDataDir}

            mkdir -p ${redisDataDir}
            chown "$(id -un)" ${redisDataDir}

            if [ ! -f ${mongoDataDir}/.mongo-init-done ]; then
              echo "Initializing MongoDB admin user..." >> /tmp/mongo-script.log
              ${pkgs.mongodb-ce}/bin/mongod --config ${mongoConfigPath} > /tmp/mongod-init.log 2>&1 &
              sleep 3
              ${pkgs.mongosh}/bin/mongosh --port 27017 < ${mongoInitScript}
              touch ${mongoDataDir}/.mongo-init-done
              ${pkgs.mongosh}/bin/mongosh --eval "db.getSiblingDB('admin').shutdownServer()"
            fi
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
