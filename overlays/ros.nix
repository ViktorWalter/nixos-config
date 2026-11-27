{ pkgs, ros-overlay, ros-pkgs, ... }:
{
  # Binary cache. Without it, ROS packages compile locally for hours.
  nix.settings = {
    substituters = [ "https://ros.cachix.org" ];
    trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
    extra-substituters = [ "https://attic.iid.ciirc.cvut.cz/ros" ];
    extra-trusted-public-keys = [ "ros:JR95vUYsShSqfA1VTYoFt1Nz6uXasm5QrcOsGry9f6Q=" ];
  };

  environment.systemPackages = with ros-pkgs.rosPackages.jazzy; [
    (buildEnv {
     paths = [
     ros-core
     rviz2
     rqt-common-plugins
     tf2-tools
     ];
     })
  ];
}
