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
     # Without this, rqt plugins (e.g. rqt_image_view) fail with
     # "No module named 'PyQt5.QtCore'": python-qt-binding's
     # propagatedBuildInputs resolves to pyqt5's `dev` output instead of
     # its `out` output, so the real PyQt5 bindings never get merged into
     # the environment (only pyqt5-sip's small helper module does).
     # Adding pyqt5 explicitly here fills in the missing files.
     ros-pkgs.python3Packages.pyqt5
     ];
     })
  ];
}
