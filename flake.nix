{
  description = "Reusable standard tooling";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, treefmt-nix, ... }:
    let
      sharedModule =
        { ... }:
        {
          imports = [ treefmt-nix.flakeModule ];

          perSystem =
            { config, ... }:
            {
              treefmt = {
                projectRootFile = "flake.nix";

                # Nix
                programs.nixfmt.enable = true;
                programs.nixfmt.strict = true;
                programs.nixfmt.width = 80;

                # Shell
                programs.shfmt.enable = true;
                programs.shfmt.indent_size = 2;
                programs.shfmt.simplify = true;
              };

              formatter = config.treefmt.build.wrapper;
            };
        };
    in
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" ];

      imports = [ sharedModule ];
      flake.flakeModules.default = sharedModule;
    };
}
