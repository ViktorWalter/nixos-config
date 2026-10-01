{
  nixpkgs.overlays = [
    (final: prev: {
      sudo = prev.sudo.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ [
          (prev.fetchpatch {
            url = "https://github.com/sudo-project/sudo/commit/3e474c2f201484be83d994ae10a4e20e8c81bb69.patch";
            hash = "sha256-Kq3moF9rkRhOhknzZAyF02aW0h+GR0iQ8m2PqCKbPto=";
          })
        ];
      });
    })
  ];
}
