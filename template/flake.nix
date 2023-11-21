{
  description = "Attempts to install tools versioned in .tool-versions";
  
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    let
      pkgNameReplacements = {
        postgres = "postgresql";
        rabbitmq = "rabbitmq-server";
      };
      defaultPackages = {
        python = "python310";
        poetry = "poetry";
      };
    in flake-utils.lib.eachDefaultSystem (system:
      let
        lib = nixpkgs.lib;
        pkgs = nixpkgs.legacyPackages.${system};
        toolVersions = lib.readFile ./.tool-versions;
        versionLines = lib.lists.remove "" (lib.splitString "\n" toolVersions);
        tools = builtins.listToAttrs (lib.lists.forEach versionLines (versionLine: 
          let
            pkgAndVersion = lib.splitString " " versionLine;
            pkgName0 = builtins.head pkgAndVersion;
            pkgName = if (builtins.hasAttr pkgName0 pkgNameReplacements) then pkgNameReplacements.${pkgName0} else pkgName0;
            pkgVersionSplit = builtins.splitVersion (builtins.elemAt pkgAndVersion 1);
            potentialPkgNames = (builtins.foldl' ({acc, nameA, nameB}: x: 
              let
                newNameA = nameA + "_" + x;
                newNameB = nameB + x;
              in {
                acc = [newNameA newNameB] ++ acc;
                nameA = newNameA;
                nameB = newNameB;
              }
            ) {acc = [pkgName]; nameA = pkgName; nameB = pkgName;} pkgVersionSplit).acc;
            pkgNames = builtins.filter (x: builtins.hasAttr x pkgs) potentialPkgNames ;
            nixpkgName = builtins.head pkgNames; 
          in {
            name = pkgName0;
            value = pkgs.${nixpkgName};
          }
        ));
        toolsWithDefaults = (builtins.mapAttrs (key: val: pkgs.${val}) defaultPackages) // tools;
      in {
        packages.default = pkgs.hello;
        devShells.default = pkgs.mkShell {
          buildInputs = builtins.attrValues toolsWithDefaults;
          shellHook = ''
            export POETRY_VIRTUALENVS_PREFER_ACTIVE_PYTHON=true;
            export POETRY_VIRTUALENVS_IN_PROJECT=true;
          '';
        };
      }
    );
}
