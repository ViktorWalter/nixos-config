#!/bin/bash
gmail_password=$(pass Email/gmail | head -n1)
python3 -c "import keyring; keyring.set_password('gmail', 'personal', '${gmail_password}')"
gmail_ci=$(pass Email/gmail_o | head -n1)
python3 -c "import keyring; keyring.set_password('gmail_client_id', 'personal', '${gmail_ci}')"
gmail_cs=$(pass Email/gmail_o | head -n2 | tail -n1)
python3 -c "import keyring; keyring.set_password('gmail_client_secret', 'personal', '${gmail_cs}')"
gmail_rt=$(pass Email/gmail_o_rt)
#echo $gmail_rt
python3 -c "import keyring; keyring.set_password('gmail_refresh_token', 'personal', '${gmail_rt}')"

outlook_password=$(pass Email/outlook | head -n1)
python3 -c "import keyring; keyring.set_password('outlook', 'personal', '${outlook_password}')"
outlook_rt=$(pass Email/outlook_rt)
#echo $gmail_rt
python3 -c "import keyring; keyring.set_password('outlook_refresh_token', 'personal', '${outlook_rt}')"

fel_password=$(pass Email/fel | head -n1)
python3 -c "import keyring; keyring.set_password('work', 'personal', '${fel_password}')"

fel_password=$(pass Work/CVUT | head -n1)
python3 -c "import keyring; keyring.set_password('work_alt', 'personal', '${fel_password}')"

#thunderbird_id="9e5f94bc-e8a4-4e73-b8be-63364c29d753"
#thunderbird_secret="TxRBilcHdC6WGBee]fs?QR:SJ8nI[g82"
o365_rt=$(pass Email/Office365_RT)
python3 -c "import keyring; keyring.set_password('o365_rt', 'personal', '${o365_rt}')"

disroot_password=$(pass Email/disroot | head -n1)
python3 -c "import keyring; keyring.set_password('personal', 'personal', '${disroot_password}')"

andrew_password=$(pass Work/CMU_Andrew | head -n1)
python3 -c "import keyring; keyring.set_password('cmu', 'personal', '${andrew_password}')"
