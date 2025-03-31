My personal nix-darwin flake created in attempt of making MacOS setup not as painful as it currently is.


Download Nix installer from https://install.determinate.systems/determinate-pkg/stable/Universal or just run
```
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

```
nix run nix-darwin -- switch --flake .
```