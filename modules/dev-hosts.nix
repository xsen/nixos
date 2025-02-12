{
  hosts = {
    "192.168.0.101" = [ "homesrv.local" ];
    "127.0.0.1" = [ "project1.local" ];
  };

  virtualHosts."project1.local" = {
    forceSSL = true;
    #sslCertificate = "/etc/ssl/mycerts/project1.local.pem";
    #sslCertificateKey = "/etc/ssl/mycerts/project1.local-key.pem";

    locations."/" = {
      proxyPass = "http://localhost:8081";
      #recommendedProxySettings = true;
    };
  };
}
