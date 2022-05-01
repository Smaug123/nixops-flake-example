{
  config,
  lib,
  acmeEmail,
  ip,
  domain,
  ...
}: {
  nixos-server = {
    pkgs,
    modulePaths,
    lib,
    ...
  }: {
    imports = [(modulePaths + "/virtualisation/digital-ocean-config.nix")];
    deployment.targetHost = ip;

    security.acme.acceptTerms = true;
    security.acme.certs = {
      ${domain} = {
        email = "patrick+acme@patrickstevens.co.uk";
      };
    };

    environment = {
      systemPackages = with pkgs; [
        docker
      ];
    };

    networking.firewall.allowedTCPPorts = [
      80 # required for the ACME challenge
      443
    ];

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      virtualHosts."${domain}" = {
        addSSL = true;
        enableACME = true;
        root = "/var/www/html";
      };
    };
  };
}
