{ config, pkgs, ... }:
{
  networking.firewall.allowedTCPPorts = [ 443 ];

  #nextcloud config
  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud33;
    hostName = import ./nextcloud-hostname.nix;
    datadir = "/var/lib/nextcloud/data";
    #home = "/var/lib/nextcloud";
    config = {
      dbtype = "sqlite";
      adminpassFile = null; #these will be overriden by imported configs
      adminuser = null;
    };
    settings = {
      apps_paths = [
        {
          path = "${config.services.nextcloud.package}/apps";
          url = "/apps";
          writable = false;
        }
        {
          path = "/var/lib/nextcloud/store-apps";
          url = "/store-apps";
          writable = true;
        }
      ];

      trusted_proxies = [ "127.0.0.1" ];

      overwritehost = config.services.nextcloud.hostName;
      overwritewebroot = "/nextcloud";
      overwriteprotocol = "https";
      overwrite.cli.url = "https://${config.services.nextcloud.hostName}/nextcloud/";
      
      htaccess.RewriteBase = "/nextcloud";
    };

    secretFile = "/etc/nextcloud-secrets.json";
  };

  services.nginx = {
    enable = true;

    virtualHosts = {
      "${config.services.nextcloud.hostName}" = {
        listen = [
          {
            addr = "127.0.0.1";
            port = 8080;
          }
        ];
      };

      "nextcloud-public" = {
        listen = [
          {
            addr = "0.0.0.0";
            port = 443;
            ssl = true;
          }
        ];

        extraConfig = ''
          ssl_certificate /etc/nextcloud/tls/cert.crt;
          ssl_certificate_key /etc/nextcloud/tls/cert.key;
        '';

        serverName = config.services.nextcloud.hostName;

        locations."/nextcloud/" = {
          proxyPass = "http://127.0.0.1:8080/";

          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header Host $host;

          '';
        };
      };
    };
  };

}
