{
  hosts = {
    "192.168.0.101" = [ "homesrv.local" ];
    "127.0.0.1" = [ "project.local" ];
  };

  virtualHosts."project.local" = {
    locations."/" = {
      proxyPass = "http://localhost:8081";
    };
  };
}
