{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs }:
  let
    configuration = { pkgs, ... }: {
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wget
      #TODO: pulltube, cleanshotX, windscribe
      environment.systemPackages =
        [
          pkgs.arc-browser
          pkgs.docker
          pkgs.ghostty
          pkgs.unnaturalscrollwheels
          pkgs.sqlitebrowser
          pkgs.visual-studio-code
          pkgs.google-chrome
          pkgs.code-cursor
          pkgs.postman
          pkgs.discord
          pkgs.teams
          pkgs.lmstudio
          pkgs.obs-studio
          pkgs.ollama
          pkgs.jetbrains.pycharm-community-bin
          pkgs.pgadmin4
          pkgs.telegram-desktop
          pkgs.vscode
          pkgs.vlc
          pkgs.handbrake
          pkgs.python313
          pkgs.postgresql_15
          pkgs.raycast
          pkgs.soundsource
          pkgs.darwin.xcode
          pkgs.zsh-autosuggestions
          pkgs.git
          pkgs.docker-compose
        ];

      programs.homebrew = {
        enable = true;
        casks = [
          "keepingyouawake"
    ];
  };
      nix.settings.experimental-features = "nix-command flakes";
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."simple" = nix-darwin.lib.darwinSystem {
      modules = [ configuration ];
    };
  };
}
