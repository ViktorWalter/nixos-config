{ pkgs, ros-overlay, ... }:
{
  nixpkgs.overlays = [ ros-overlay.overlays.default ];

  # Binary cache. Without it, ROS packages compile locally for hours.
  nix.settings = {
    substituters = [ "https://ros.cachix.org" ];
    trusted-public-keys = [ "ros.cachix.org-1:dSyZxI8geDCJrwgvCOHDoAfOm5sV1wCPjBkKL+38Rvo=" ];
  };

  environment.systemPackages = with pkgs.rosPackages.jazzy; [
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
