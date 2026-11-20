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

  # Source of https://github.com/UvA-FNWI/M365-IMAP, pinned to a commit.
  # Provides get_token.py (initial OAuth2 login) and refresh_token.py
  # (used from the offlineimap pythonFile below as get_m365_token()).
  m365ImapSrc = pkgs.fetchFromGitHub {
    owner = "UvA-FNWI";
    repo = "M365-IMAP";
    rev = "74094a25a15884b1e713eb9009eaaf841005e6eb";
    sha256 = "0qx5q7dhvwfbdxpy57w2dw0y83md2lxr0bhyacrzzzgadfzyiari";
  };

  # Shared interpreter for both get_token.py and refresh_token.py (called
  # from the offlineimap pythonFile below) - both import `msal`, which a
  # plain `python3` found on $PATH at runtime is not guaranteed to have.
  m365ImapPython = pkgs.python3.withPackages (ps: [ ps.msal ]);

  # get_token.py imports `config` (shipped alongside it in the repo) and
  # `msal`, and writes its token files (named in config.py) relative to the
  # current working directory - so this wrapper cds into the same directory
  # that get_m365_token() reads refresh_token.py's output from, before
  # running the script from the Nix store.
  m365ImapGetToken = pkgs.writeShellApplication {
    name = "get_token.py";
    runtimeInputs = [ m365ImapPython ];
    text = ''
      mkdir -p "$HOME/.local/share/m365-imap"
      cd "$HOME/.local/share/m365-imap"
      exec python3 ${m365ImapSrc}/get_token.py
    '';
  };

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
      import subprocess

      def get_m365_token():
        return subprocess.run(
            ["${m365ImapPython}/bin/python3", "refresh_token.py"],
            cwd="/home/viktor/.local/share/m365-imap",
            capture_output=True, text=True, check=True,
            ).stdout.split()[0]
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

    # `get_token.py` from M365-IMAP, for the one-off interactive OAuth2
    # login needed before get_m365_token() (above) can refresh tokens.
    m365ImapGetToken

    supPackage
    pkgs.w3m # used by .sup/hooks/mime-decode.rb
    pkgs.perlPackages.FileMimeInfo # provides `mimeopen`, used by .sup/hooks/mime-view.rb

    (pkgs.writeShellApplication { #add script to load passwords from password-store to python keyring
     name = "set_mail_passwords";
     runtimeInputs = [ pkgs.coreutils ];
     text = builtins.readFile ./set_mail_passwords.sh;
     })
  ];

  home.file = lib.listToAttrs (map (f: {
    name = ".sup/${f}";
    value = {
      source = ./sup/${f};
      executable = lib.hasSuffix ".sh" f;
    };
  }) sources) // {
    # Static M365-IMAP support files that refresh_token.py / get_m365_token()
    # expect to find by relative name in ~/.local/share/m365-imap (alongside
    # the token files that get_token.py/refresh_token.py write there at
    # runtime, which are intentionally left unmanaged here - home-manager
    # would otherwise symlink them read-only into the Nix store).
    ".local/share/m365-imap/refresh_token.py".source = "${m365ImapSrc}/refresh_token.py";
    ".local/share/m365-imap/config.py".source = "${m365ImapSrc}/config.py";
  };

}
