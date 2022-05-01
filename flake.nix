{
  description = "Web server flake";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }: let
    domain = "staging.patrickstevens.co.uk";
  in let
    acmeEmail = "patrick+acme@patrickstevens.co.uk";
  in
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
      in {
        inherit nixpkgs;
        defaultPackage = pkgs.hello;
        nixopsConfigurations.default = {
          inherit nixpkgs;
          network.description = domain;
          defaults._module.args = {
            inherit domain;
            inherit acmeEmail;
          };
          webserver = import ./configuration.nix;
        };
        devShell = pkgs.mkShell {
          buildInputs = [
            pkgs.pulumi-bin
            pkgs.nixops
            pkgs.dotnet-sdk_6
          ];
          shellHook = ''
            export PULUMI_SKIP_UPDATE_CHECK=1
          '';
        };
      }
    );
}
