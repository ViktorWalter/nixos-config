{ config, pkgs, lib, ... }:

let
  maildirBase = "${config.home.homeDirectory}/mail";

  account_info = {
    personal = import ./accounts/personal.nix;
    gmail = import ./accounts/gmail.nix;
    outlook = import ./accounts/outlook.nix;
    work = import ./accounts/work.nix;
    work_alt = import ./accounts/work_alt.nix;
  };

  personal = import ./personal/personal.nix;

  pythonWithKeyring = pkgs.python3.withPackages (ps: [
    ps.keyring
  ]);

  keyringPassword = pkgs.writeShellApplication {
    name = "mail-keyring-password";
    runtimeInputs = [ pythonWithKeyring ];
    text = ''
      service="$1"
      username="$2"

      ${pythonWithKeyring}/bin/python3 - "$service" "$username" <<'PY'
      import keyring
      import sys

      service = sys.argv[1]
      username = sys.argv[2]

      value = keyring.get_password(service, username)
      if value is None:
        sys.exit(f"Missing keyring entry: {service}/{username}")

      print(value)
      PY
      '';
  };

  oauthToken = pkgs.writeShellApplication {
    name = "mail-oauth-token";

    runtimeInputs = [ pythonWithKeyring ];

    text = ''
      set -euo pipefail

      if [ "$#" -ne 1 ]; then
        echo "Usage: mail-oauth-token <outlook|work_alt|gmail>" >&2
        exit 2
      fi

      account="$1"

      ${pythonWithKeyring}/bin/python3 - "$account" <<'PY'
      import json
      import sys
      import urllib.parse
      import urllib.request
      import keyring


      account = sys.argv[1]


      def keyring_get(service):
          value = keyring.get_password(service, "personal")

          if value is None:
              raise SystemExit(
                  f"Missing keyring entry: {service}/personal"
              )

          return value


      # ----------------------------------------------------------------------
      # Microsoft / Outlook
      #
      # Both work_alt and outlook use the same Thunderbird OAuth client.
      # Their refresh tokens are kept separately in the keyring.
      # ----------------------------------------------------------------------

      
      #From Thunderbird (https://hg-edge.mozilla.org/comm-central/file/tip/mailnews/base/src/OAuth2Providers.sys.mjs)
      microsoft_client_id = (
          "9e5f94bc-e8a4-4e73-b8be-63364c29d753"
      )
      microsoft_client_secret = (
          "TxRBilcHdC6WGBee]fs?QR:SJ8nI[g82"
      )

      microsoft_token_url = (
          "https://login.microsoftonline.com/"
          "common/oauth2/v2.0/token"
      )


      if account == "work_alt":
          client_id = microsoft_client_id
          client_secret = microsoft_client_secret
          token_url = microsoft_token_url
          refresh_token = keyring_get("o365_rt")

      elif account == "outlook":
          client_id = microsoft_client_id
          client_secret = microsoft_client_secret
          token_url = microsoft_token_url
          refresh_token = keyring_get("outlook_refresh_token")


      # ----------------------------------------------------------------------
      # Gmail
      #
      # Gmail's OAuth client credentials are kept in the keyring rather than
      # being embedded in the Nix configuration.
      # ----------------------------------------------------------------------

      elif account == "gmail":
          client_id = keyring_get("gmail_client_id")
          client_secret = keyring_get("gmail_client_secret")
          token_url = "https://oauth2.googleapis.com/token"
          refresh_token = keyring_get("gmail_refresh_token")

      else:
          raise SystemExit(
              f"Unknown account: {account}. "
              "Expected outlook, work_alt, or gmail."
          )


      # ----------------------------------------------------------------------
      # Refresh the access token.
      # ----------------------------------------------------------------------

      data = urllib.parse.urlencode({
          "client_id": client_id,
          "client_secret": client_secret,
          "refresh_token": refresh_token,
          "grant_type": "refresh_token",
      }).encode()


      request = urllib.request.Request(
          token_url,
          data=data,
          headers={
              "Content-Type":
                  "application/x-www-form-urlencoded",
          },
          method="POST",
      )


      try:
          with urllib.request.urlopen(request) as response:
              result = json.load(response)

      except Exception as exc:
          print(
              f"OAuth2 token request failed for {account}: {exc}",
              file=sys.stderr,
          )
          raise SystemExit(1)


      access_token = result.get("access_token")

      if not access_token:
          print(
              "OAuth2 token response did not contain an access_token.",
              file=sys.stderr,
          )
          print(
              json.dumps(result, indent=2),
              file=sys.stderr,
          )
          raise SystemExit(1)


      # mbsync/msmtp expect the access token on stdout.
      print(access_token)
      PY
    '';
  };

  outlookToken = 
  "${oauthToken}/bin/mail-oauth-token outlook";
  workaltToken = 
  "${oauthToken}/bin/mail-oauth-token work_alt";
  gmailToken = 
  "${oauthToken}/bin/mail-oauth-token gmail";

  cyrusSaslWithXoauth2 = pkgs.cyrus_sasl.overrideAttrs (oldAttrs: {
    buildInputs = (oldAttrs.buildInputs or []) ++ [
      pkgs.cyrus-sasl-xoauth2
    ];

    postInstall = (oldAttrs.postInstall or "") + ''
      cp ${pkgs.cyrus-sasl-xoauth2}/lib/sasl2/* $out/lib/sasl2/
    '';
  });

  mbsyncWithXoauth2 = pkgs.isync.override {
    cyrus_sasl = cyrusSaslWithXoauth2;
  };
in
{

  accounts.email = {
    maildirBasePath = maildirBase;

    accounts = {


      ######################################################################
      # PERSONAL
      ######################################################################

      personal = {
        address = "${account_info.personal.address}";
        userName = "${account_info.personal.username}";
        realName = "${personal.name}";
        primary = true;

        maildir.path = "personal";

        folders = {
          inbox = "inbox";
          sent = null;
          drafts = null;
          trash = null;
        };

        passwordCommand = "${keyringPassword}/bin/mail-keyring-password personal personal";

        imap = {
          host = "${account_info.personal.host}";
          port = 993;
          tls.enable = true;
        };

        smtp = {
          host = "${account_info.personal.host}";
          port = 587;
          tls.enable = true;
          tls.useStartTls = true;
        };

        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "none";

          groups.personal.channels = {
            inbox = {
              farPattern = "INBOX";
              nearPattern = "inbox";

              extraConfig = {
                Sync = "Pull";
                Expunge = "None";
                Remove = "None";
              };
            };

            junk = {
              farPattern = "Junk";
              nearPattern = "junk";

              extraConfig = {
                Sync = "Pull";
                Expunge = "None";
                Remove = "None";
              };
            };
          };
        };

        msmtp = {
          enable = true;
          extraConfig = {
            auth = "on";
            tls = "on";
            tls_starttls = "on";
            port = "587";
          };
        };

        notmuch.enable = true;
        alot.sendMailCommand = "${pkgs.msmtp}/bin/msmtp --read-envelope-from --read-recipients --account=personal";
      };

      ######################################################################
      # WORK
      ######################################################################

      work = {
        address = "${account_info.work.address}";
        userName = "${account_info.work.username}";
        realName = "${personal.name}";

        maildir.path = "work";

        passwordCommand = "${keyringPassword}/bin/mail-keyring-password work personal";

        folders = {
          inbox = "inbox";
          sent = null;
          drafts = null;
          trash = null;
        };

        imap = {
          host = "${account_info.work.host}";
          port = 993;
          authentication = "plain";

          tls = {
            enable = true;
            useStartTls = false;
          };
        };

        smtp = {
          host = "${account_info.work.host}";
          port = 465;
          tls.enable = true;
          tls.useStartTls = false;
        };

        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "none";

          groups.work.channels.inbox = {
            farPattern = "INBOX";
            nearPattern = "inbox";

            extraConfig = {
              Sync = "Pull";
              Expunge = "None";
              Remove = "None";
            };
          };

        };

        msmtp = {
          enable = true;
          extraConfig = {
            auth = "on";
            tls = "on";
            tls_starttls = "off";
            port = "465";
          };
        };

        notmuch.enable = true;

        alot.sendMailCommand = "${pkgs.msmtp}/bin/msmtp --read-envelope-from --read-recipients --account=work";
      };


      ######################################################################
      # WORK ALT / OFFICE365
      ######################################################################

      work_alt = {
        address = "${account_info.work_alt.address}";
        userName = "${account_info.work_alt.username}";
        realName = "${personal.name}";

        maildir.path = "work_alt";

        # OAuth2 is used by the original OfflineIMAP configuration.
        passwordCommand = workaltToken;

        folders = {
          inbox = "inbox";
          sent = null;
          drafts = null;
          trash = null;
        };

        imap = {
          host = "outlook.office365.com";
          port = 993;
          authentication = "xoauth2";

          tls = {
            enable = true;
            useStartTls = false;
          };
        };

        smtp = {
          host = "smtp.office365.com";
          port = 587;
          authentication = "xoauth2";

          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "none";

          groups.work_alt.channels.inbox = {
            farPattern = "INBOX";
            nearPattern = "inbox";

            extraConfig = {
              Sync = "Pull";
              Expunge = "None";
              Remove = "None";
            };
          };

          extraConfig.account = {
            AuthMechs = "XOAUTH2";
          };
        };

        msmtp = {
          enable = true;
          extraConfig = {
            auth = "xoauth2";
            tls = "on";
            tls_starttls = "on";
            port = "587";
          };
        };

        notmuch.enable = true;

        alot.sendMailCommand = "${pkgs.msmtp}/bin/msmtp --read-envelope-from --read-recipients --account=work_alt";
      };


      ######################################################################
      # OUTLOOK PERSONAL
      ######################################################################

      outlook = {
        address = "${account_info.outlook.address}";
        userName = "${account_info.outlook.username}";
        realName = "${personal.name}";

        maildir.path = "outlook";

        passwordCommand = outlookToken;

        folders = {
          inbox = "inbox";
          sent = null;
          drafts = null;
          trash = null;
        };

        imap = {
          host = "outlook.office365.com";
          port = 993;
          tls.enable = true;
          authentication = "xoauth2";
        };

        smtp = {
          host = "smtp-mail.outlook.com";
          port = 587;
          tls.enable = true;
          tls.useStartTls = true;
          authentication = "xoauth2";
        };

        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "none";

          extraConfig.account = {
            AuthMechs = "XOAUTH2";
          };

          groups.outlook.channels = {
            inbox = {
              farPattern = "Inbox";
              nearPattern = "inbox";

              extraConfig = {
                Sync = "Pull";
                Expunge = "None";
                Remove = "None";
              };
            };

            junk = {
              farPattern = "Junk";
              nearPattern = "inbox_oj";

              extraConfig = {
                Sync = "Pull";
                Expunge = "None";
                Remove = "None";
              };
            };
          };
        };

        msmtp = {
          enable = true;
          extraConfig = {
            auth = "xoauth2";
            tls = "on";
            tls_starttls = "on";
            port = "587";
          };
        };

        notmuch.enable = true;
        alot.sendMailCommand = "${pkgs.msmtp}/bin/msmtp --read-envelope-from --read-recipients --account=outlook";
      };


      ######################################################################
      # GMAIL
      ######################################################################

      gmail = {
        address = "${account_info.gmail.address}";
        userName = "${account_info.gmail.username}";
        realName = "${personal.fake_name}";

        maildir.path = "gmail";

        # Gmail IMAP uses XOAUTH2.
        passwordCommand = gmailToken;

        folders = {
          inbox = "inbox";
          sent = null;
          drafts = null;
          trash = null;
        };


        imap = {
          host = "imap.gmail.com";
          port = 993;
          authentication = "xoauth2";

          tls = {
            enable = true;
            useStartTls = false;
          };
        };

        smtp = {
          host = "smtp.gmail.com";
          port = 587;
          authentication = "xoauth2";

          tls = {
            enable = true;
            useStartTls = true;
          };
        };

        mbsync = {
          enable = true;
          create = "maildir";
          expunge = "none";

          groups.gmail.channels.inbox = {
            farPattern = "INBOX";
            nearPattern = "inbox";
            
            extraConfig = {
              Sync = "Pull";
              Expunge = "None";
              Remove = "None";
            };
          };


          extraConfig.account = {
            AuthMechs = "XOAUTH2";
          };
        };

        msmtp = {
          enable = true;

          extraConfig = {
            tls = "on";
            tls_starttls = "on";
            port = "587";
            auth = "xoauth2";
            passwordeval = "${oauthToken} gmail";
          };
        };

        notmuch.enable = true;

        alot.sendMailCommand = "${pkgs.msmtp}/bin/msmtp --read-envelope-from --read-recipients --account=gmail";
      };
    };
  };


##########################################################################
# NOTMUCH
##########################################################################

  programs.notmuch = {
    enable = true;

    new = {
      tags = [
        "unread"
          "inbox"
      ];

      ignore = [
        ".notmuch"
        ".mbsyncstate"
        ".mbsyncstate.*"
      ];
    };

    maildir.synchronizeFlags = true;

    search.excludeTags = [
      "deleted"
        "spam"
    ];

    hooks.postNew = ''
      set -eu

      # Account/source tags corresponding to the old Sup labels.

      ${pkgs.notmuch}/bin/notmuch tag +F -- path:work/inbox/**
      ${pkgs.notmuch}/bin/notmuch tag +Fx -- path:work_alt/inbox/**
      ${pkgs.notmuch}/bin/notmuch tag +O -- path:outlook/inbox/**
      ${pkgs.notmuch}/bin/notmuch tag +Oj -- path:outlook/inbox_oj/**
      ${pkgs.notmuch}/bin/notmuch tag +G -- path:gmail/inbox/**
      ${pkgs.notmuch}/bin/notmuch tag +D -- path:personal/inbox/**
      ${pkgs.notmuch}/bin/notmuch tag +Dj -- path:personal/junk/**

      # Shared local Sent repository.

      notmuch tag +sent -inbox -- path:sent/**

      # Junk isn't part of the normal inbox.

      notmuch tag -inbox -- tag:Oj
      notmuch tag -inbox -- tag:Dj

      # Sent messages aren't inbox messages.

      notmuch tag -inbox -- tag:sent
    '';
};


##########################################################################
# AERC
##########################################################################
xdg.configFile."aerc/notmuch-query-map".text = ''
  Inbox=tag:inbox
  Personal=tag:inbox and tag:D
  Work=tag:inbox and tag:F
  Outlook=tag:inbox and tag:O
  Gmail=tag:inbox and tag:G
  Sent=tag:sent
'';
programs.aerc = {
  enable = true;

  extraBinds = {
    default = builtins.readFile ./aerc_default_bindings.conf;

    messages = {
      q = ":quit<Enter>";
      x = ":close";
      "?" = ":prompt 'Search all mail: ' query -n Search<Enter>";
      A = ":modify-labels -inbox<Enter>";
    };

    view = {
      V = ":pipe -m less<Enter>";
      A = ":modify-labels -inbox<Enter>";
    };
  };

  extraConfig = {
    general = {
      unsafe-accounts-conf = true;
    };

    ui = {
      threading-enabled = true;
      force-client-threads = true;
      threading-by-subject = true;

    # Newest messages/threads first.
    sort = "-r date";
    # Apply the same date ordering to messages within threads.
    sort-thread-siblings = true;
    # Keep the thread root at the top, replies below it.
    reverse-thread-order = false;

    index-columns = "source:1,flags:4,name<20%,subject,date>=";
    column-source = "{{switch (.Labels | join \" \") (case `(^| )x( |$)` \"X\") (case `(^| )G( |$)` \"G\") (case `(^| )D( |$)` \"D\") (case `(^| )O( |$)` \"O\") (case `(^| )F( |$)` \"F\")}}";
    # column-flags = "{{.Flags | join \"\"}}";
    # column-name = "{{index (.From | names) 0}}";
    # column-subject = "{{.ThreadPrefix}}{{.Subject}}";
    # column-date = "{{.DateAutoFormat .Date.Local}}";

  };

  compose = {
    editor = "nvim";
  };

  filters = {
    "text/plain" = "colorize";
    "text/html" = "html | colorize";
  };
  };

extraAccounts = {
  personal = {
    source = "notmuch://~/mail";
    default = "Inbox";
    enable-maildir = true;
    from = "${personal.name} <${account_info.personal.address}>";
    query-map = "${config.xdg.configHome}/aerc/notmuch-query-map";
    folders-sort = "Inbox,Search,Personal,Work,Outlook.Gmail";
  };
};


  };

programs.mbsync = {
  enable = true;
  package = mbsyncWithXoauth2;
};
services.mbsync = {
  enable = true;
  package = mbsyncWithXoauth2;

  frequency = "*:0/5";

  postExec = ''
    ${pkgs.notmuch}/bin/notmuch new
    '';
};

# ---------------------------------------------------------------------------
# msmtp
# ---------------------------------------------------------------------------

programs.msmtp = {
  enable = true;

# Home Manager normally generates msmtp account sections from
# accounts.email.accounts.*.msmtp.
#
# We deliberately override Alot's send command above because Home Manager
# otherwise defaults to msmtpq.
};

home.activation.createMaildirs =
lib.hm.dag.entryAfter [ "writeBoundary" ] ''
mkdir -p \
        "${maildirBase}/personal/inbox/cur" \
        "${maildirBase}/personal/inbox/new" \
        "${maildirBase}/personal/inbox/tmp" \
        "${maildirBase}/personal/junk/cur" \
        "${maildirBase}/personal/junk/new" \
        "${maildirBase}/personal/junk/tmp" \
        "${maildirBase}/work/inbox/cur" \
        "${maildirBase}/work/inbox/new" \
        "${maildirBase}/work/inbox/tmp" \
        "${maildirBase}/work_alt/inbox/cur" \
        "${maildirBase}/work_alt/inbox/new" \
        "${maildirBase}/work_alt/inbox/tmp" \
        "${maildirBase}/outlook/inbox/cur" \
        "${maildirBase}/outlook/inbox/new" \
        "${maildirBase}/outlook/inbox/tmp" \
        "${maildirBase}/outlook/inbox_oj/cur" \
        "${maildirBase}/outlook/inbox_oj/new" \
        "${maildirBase}/outlook/inbox_oj/tmp" \
        "${maildirBase}/gmail/inbox/cur" \
        "${maildirBase}/gmail/inbox/new" \
        "${maildirBase}/gmail/inbox/tmp" \
        "${maildirBase}/sent/cur" \
        "${maildirBase}/sent/new" \
        "${maildirBase}/sent/tmp"
        '';

        home.packages = with pkgs; [
          (pkgs.writeShellApplication { #add script to load passwords from password-store to python keyring
           name = "set_mail_passwords";
           runtimeInputs = [ pkgs.coreutils ];
           text = builtins.readFile ./set_mail_passwords.sh;
           })

        ];


        }
