{
  description = "Nix package for appmenu-gtk-module-wayland";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs systems;

      packageFor = system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        pkgs.callPackage ./package.nix {
          src = self;
        };
    in
    {
      packages = forAllSystems (system:
        let
          package = packageFor system;
        in
        {
          default = package;
          appmenu-gtk-module-wayland = package;
        });

      overlays.default = final: prev: {
        appmenu-gtk-module-wayland = final.callPackage ./package.nix {
          src = self;
        };
      };

      # Import this module from a NixOS flake to install the package and make
      # its Wayland-only profile hook available as /etc/profile.d/*.sh.
      nixosModules.default = { pkgs, ... }:
        let
          package = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        {
          environment.systemPackages = [ package ];
          systemd.packages = [ package ];
          environment.etc."profile.d/appmenu-gtk-module-wayland.sh".source =
            "${package}/etc/profile.d/appmenu-gtk-module-wayland.sh";
        };
    };
}
