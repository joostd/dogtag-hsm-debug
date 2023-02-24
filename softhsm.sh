apt update
apt upgrade -y
# hsm
apt install -y softhsm
apt install -y opensc
softhsm2-util --init-token --label "Dogtag" --so-pin Secret.123 --pin Secret.123 --free
# patch: /usr/lib/python3/dist-packages/pki/server/deployment/scriptlets/configuration.py
# check already patched: /usr/lib/python3/dist-packages/pki/server/deployment/pkiparser.py 
# ds
apt install -y 389-ds-base
dscreate from-file /vagrant/ds.inf
ldapadd -H ldap://ubuntu-jammy  -x -D "cn=Directory Manager" -w Secret.123 -f /vagrant/example.ldif
# ca
apt install -y dogtag-pki

addgroup pkiuser softhsm
chmod 755 /var/lib/softhsm
chmod 1777 /var/lib/softhsm/tokens
chmod 777 /var/lib/softhsm -Rv

cp /vagrant/patches/configuration.py /usr/lib/python3/dist-packages/pki/server/deployment/scriptlets/
cp /vagrant/patches/__init__.py /usr/lib/python3/dist-packages/pki/server/deployment/

#pkispawn -f /vagrant/softhsm-ca.cfg -s CA --debug --log-file ./log
# INFO: Waiting for PKI server to start (3s)
# Installation failed: Server did not start after 60s


#pkidestroy -s CA --force
