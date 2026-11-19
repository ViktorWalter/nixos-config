{ config, pkgs, lib, sup-flake, ... }:
# ---------------------------------------------------------------------------
# General offlineimap/msmtp/sup configuration (non account-specific).
#
# All personally identifying account data (addresses, hostnames, keyring
# service names, oauth tokens, ...) lives in ./accounts.nix, which is
# protected with git-crypt (see /etc/nixos/.gitattributes) and is imported
# below. The values here (mostly in the sup section, since sup has no
# home-manager module of its own) are the real ones, restored via the
# anonymization dictionary.
# ---------------------------------------------------------------------------
let
  supPackage = sup-flake.packages.${pkgs.system}.sup;

  sources = [
    "fix_xapian.sh"
    "signature_work"
    "signature_plain"
    "config.yaml"
    "sources.yaml"
    "colors.yaml"
    "labels.txt"
    "hooks/before-poll.rb"
    "hooks/goto.rb"
    "hooks/keybindings.rb"
    "hooks/mime-decode.rb"
    "hooks/mime-view.rb"
    "hooks/startup.rb"
  ];
in
{
  imports = [
    ./accounts.nix
  ];

  programs.offlineimap = {
    enable = true;

    # offlineimap runs with its own Python; `import keyring` needs that
    # package added to its propagatedBuildInputs, mirroring what
    # configuration.nix already does for the interactive system Python.
    package = pkgs.offlineimap.overridePythonAttrs (old: {
      dependencies = old.dependencies ++ [ pkgs.python3Packages.keyring ];
    });

    # Equivalent to the original ~/.offlineimap.py: all password/token
    # lookups are done with plain `keyring.get_password(...)` calls inlined
    # directly into each account's remotepasseval/oauth2_*_eval in
    # accounts.nix, so nothing else is needed here.
    pythonFile = ''
      import keyring
      # import subprocess

      # def get_token(email_address):
      #     return subprocess.run(["oama", "access", email_address], capture_output=True, text=True).stdout
    '';

    extraConfig.general = {
      ui = "ttyui";
    };
  };

  programs.msmtp = {
    enable = true;
    configContent = lib.mkBefore ''
      defaults
      tls on
      auth on
    '';
  };

  # ---------------------------------------------------------------------
  # sup - approximated, since sup has no home-manager module of its own.
  # We install it from https://github.com/ViktorWalter/sup-flake and
  # declaratively place its static config files. Files that sup rewrites
  # at runtime (contacts.txt, sync-back-ok, and any newly-created labels
  # appended to labels.txt) are intentionally left unmanaged here, since
  # home-manager would otherwise symlink them read-only into the Nix
  # store and break sup's writes.
  # ---------------------------------------------------------------------
  home.packages = [
    # Give offlineimap's `keyring` module access to the same backend as the
    # interactive system Python (see configuration.nix's pythonWithModules).
    pkgs.python3Packages.keyring

    supPackage
    pkgs.w3m # used by .sup/hooks/mime-decode.rb
    pkgs.perlPackages.FileMimeInfo # provides `mimeopen`, used by .sup/hooks/mime-view.rb
  ];

  home.file = lib.listToAttrs (map (f: {
    name = ".sup/${f}";
    value = {
      source = ./sup/${f};
      executable = lib.hasSuffix ".sh" f;
    };
  }) sources);
}
