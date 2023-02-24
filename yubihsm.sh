apt update
apt upgrade -y
# hsm
apt install -y libpcsclite1
apt install -y opensc
wget https://developers.yubico.com/YubiHSM2/Releases/yubihsm2-sdk-2023-01-ubuntu2204-amd64.tar.gz
tar xf yubihsm2-sdk-2023-01-ubuntu2204-amd64.tar.gz
dpkg -i yubihsm2-sdk/libyubihsm-usb1_2.4.0_amd64.deb
dpkg -i yubihsm2-sdk/libyubihsm-http1_2.4.0_amd64.deb
dpkg -i yubihsm2-sdk/libyubihsm1_2.4.0_amd64.deb
dpkg -i yubihsm2-sdk/libykhsmauth1_2.4.0_amd64.deb
dpkg -i yubihsm2-sdk/yubihsm-shell_2.4.0_amd64.deb
dpkg -i yubihsm2-sdk/yubihsm-pkcs11_2.4.0_amd64.deb
# ds
apt install -y 389-ds-base
dscreate from-file /vagrant/ds.inf
ldapadd -H ldap://ubuntu-jammy  -x -D "cn=Directory Manager" -w Secret.123 -f /vagrant/example.ldif
# ca
apt install -y dogtag-pki
#pkispawn -f /vagrant/nohsm-ca.cfg -s CA

cp /vagrant/patches/configuration.py /usr/lib/python3/dist-packages/pki/server/deployment/scriptlets/
cp /vagrant/_patches/_init__.py /usr/lib/python3/dist-packages/pki/server/deployment/

#pkispawn -f /vagrant/yubihsm-ca.cfg -s CA --debug --log-file ./log
#pkidestroy -s CA --force
