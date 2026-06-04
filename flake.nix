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

                # Markdown
                programs.prettier = {
                  enable = true;
                  includes = [ "*.md" ];
                  settings = {
                    proseWrap = "preserve";
                    printWidth = 80;
                  };
                };

                # fish
                programs.fish_indent.enable = true;

                # Lua
                programs.stylua = {
                  enable = true;
                  includes = [ "*.lua" ];
                  settings = {
                    indent_type = "Spaces";
                    indent_width = 2;
                    quote_style = "ForceSingle";
                    collapse_simple_statement = "Always";
                    column_width = 80;
                  };
                };
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
