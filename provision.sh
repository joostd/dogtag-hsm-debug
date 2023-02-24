apt update
apt upgrade -y
# hsm
apt install -y softhsm
softhsm2-util --init-token --label "Dogtag" --so-pin Secret.123 --pin Secret.123 --free
# patch: /usr/lib/python3/dist-packages/pki/server/deployment/scriptlets/configuration.py
# check already patched: /usr/lib/python3/dist-packages/pki/server/deployment/pkiparser.py 
# ds
apt install -y 389-ds-base
dscreate from-file /vagrant/ds.inf
ldapadd -H ldap://ubuntu-jammy  -x -D "cn=Directory Manager" -w Secret.123 -f /vagrant/example.ldif
# ca
apt install -y dogtag-pki
pkispawn -f /vagrant/softhsm-ca.cfg -s CA
