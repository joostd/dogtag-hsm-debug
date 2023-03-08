# Using DogTag PKI with YubiHSM2

WORK IN PROGRESS

This repository contains some tests deploying Dogtag PKI in a scenario where YubiHSM2 is used to protect cryptographic keys.

For comparison, there are also some deployments using no HSM and using SoftHSM.

## Simple checks

Some simple checks using these deployments.

### LDAP

Using the default setup of ds-389, test if entries can be read

    ldapsearch -LLL -w Secret.123 -D "cn=Directory Manager" -H ldap://localhost

Check is the Directory Server is running:

    systemctl status dirsrv.target

If needed, use `start` to start and `enable` to automatically start after a reboot.


### Tomcat

Idem for tomcat:

    systemctl status pki-tomcatd@pki-tomcat.service
    systemctl enable pki-tomcatd@pki-tomcat.service
    systemctl start pki-tomcatd@pki-tomcat.service

To view logs:

    journalctl -xeu pki-tomcatd@pki-tomcat.service

Check version etc:

    curl -k https://ubuntu-jammy:8443/ca/admin/ca/getStatus

### Certificates

#### Server database

The tomcat NSS database is installed in `/etc/pki/pki-tomcat/alias`

List certificates:

    certutil -d /etc/pki/pki-tomcat/alias -L

Show `sslserver` certificate:

    pki -d /etc/pki/pki-tomcat/alias nss-cert-show sslserver

#### Client database

List certificates:

    certutil -d /root/.dogtag/pki-tomcat/ca/alias -L

or

    certutil -d /root/.dogtag/nssdb/ -L

Bootstrap pki client:

    pki -c Secret.123 client-init

or alternatively,

    pki -c Secret.123 client-cert-import --pkcs12 ~/.dogtag/pki-tomcat/ca_admin_cert.p12 --pkcs12-password-file ~/.dogtag/pki-tomcat/ca/pkcs12_password.conf

or, directly import admin certificat into client database:

    pk12util -i /root/.dogtag/pki-tomcat/ca_admin_cert.p12 -d /root/.dogtag/nssdb -W Secret.123

Show admin certificate:

    pki -d /root/.dogtag/pki-tomcat/ca/alias nss-cert-show caadmin

or, using the default passphrase:

    pki -c Secret.123 -n caadmin ca-user-show caadmin

### Other

See https://github.com/dogtagpki/pki/blob/DOGTAG_10_6_BRANCH/docs/installation/Installing_CA.md

Check FQDN:

    python3 -c 'import socket; print(socket.getfqdn())'

## Profiles

List profiles:

    pki -U https://ubuntu-jammy:8443/ -d /root/.dogtag/nssdb -n caadmin ca-profile-find

Search for a profile

    pki -d /root/.dogtag/nssdb -n caadmin ca-profile-find

Search for certificates

    pki -d /root/.dogtag/nssdb -n caadmin ca-cert-find

Search for the CA certificate

    pki -d /root/.dogtag/nssdb -n caadmin ca-cert-find --name "CA Signing Certificate"

Search for the server certificate on system with FQDN `ubuntu-jammy`

    pki -d /root/.dogtag/nssdb -n caadmin ca-cert-find --name "ubuntu-jammy"

show profile for Manual Certificate Manager Signing Certificate Enrollment

    pki -d /root/.dogtag/nssdb -n caadmin ca-profile-show caCACert
