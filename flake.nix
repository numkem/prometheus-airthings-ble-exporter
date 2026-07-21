{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: {
    packages.x86_64-linux =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      rec {
        default = prometheus-airthings-ble-exporter;

        prometheus-airthings-ble-exporter = pkgs.buildGoModule {
          name = "prometheus-airthings-ble-exporter";
          version = "0.1";

          src = ./.;

          submodules = [ "exporter" ];

          vendorHash = "sha256-pa6rnKR5yg7zRmyoRNTTHy4SUfHe8TNIXaEc9IFKeUI=";

          postInstall = ''
            mv $out/bin/exporter $out/bin/prometheus-airthings-ble-exporter
          '';
        };
      };

    overlays.default = (
      final: prev: {
        inherit (self.packages.${final.system}) prometheus-airthings-ble-exporter;
      }
    );

    nixosModules.default = import ./nix/modules/default.nix;

    devShells.x86_64-linux.default =
      let
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      in
      pkgs.mkShell {
        buildInputs = with pkgs; [
          go
          gopls
        ];
      };
  };
}
