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
      sharedModule = { ... }: {
        imports = [ treefmt-nix.flakeModule ];

        perSystem = { config, ... }: {
          treefmt = {
            projectRootFile = "flake.nix";

            settings.global.excludes = [
              "result/**"
              ".direnv/**"
              "node_modules/**"
              "target/**"
              "bin/**"
              "obj/**"
              ".vs/**"
              ".sbox/**"
              "*.vpk"
              "*_c"
            ];

            # Nix
            programs.nixfmt = {
              enable = true;
              strict = true;
              width = 80;
            };

            # Auto-fix Nix anti-patterns (statix)
            programs.statix.enable = true;

            # Auto-remove dead Nix code (deadnix)
            programs.deadnix.enable = true;

            # Shell
            programs.shfmt = {
              enable = true;
              indent_size = 2;
              simplify = true;
            };

            # Markdown, YAML, and JSON via Prettier
            programs.prettier = {
              enable = true;
              includes = [
                "*.md"
                "*.yaml"
                "*.yml"
                "*.json"
              ];
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

            # C#
            programs.csharpier.enable = true;

            # A fix to configure the tool since it doesnt expose flags or options
            settings.formatter.csharpier = {
              options = [
                "--config-path"
                "${./rules/.csharpierrc.json}"
              ];
            };

            # TOML
            programs.taplo.enable = true;
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
