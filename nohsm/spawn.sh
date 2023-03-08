# multipass launch lts -n ubuntu-jammy
# multipass shell ubuntu-jammy
# multipass mount .. ubuntu-jammy:/vagrant

sudo -s
apt update
apt upgrade -y

apt install -y 389-ds-base
dscreate from-file /vagrant/ds.inf 
systemctl enable dirsrv.target
systemctl start dirsrv.target
ldapadd -H ldap://ubuntu-jammy -x -D "cn=Directory Manager" -w Secret.123 -f /vagrant/example.ldif 

apt install -y dogtag-pki
pkispawn -f /vagrant/nohsm/ca.cfg -s CA --log-file ./spawn.log --debug
curl -k https://ubuntu-jammy:8443/ca/admin/ca/getStatus

openssl genrsa -out key.pem
openssl req -new -key key.pem -subj '/CN=test' -out csr.pem
pki -u caadmin ca-cert-request-profile-show caCACert -output template.xml
apt install xsltproc
cp /vagrant/template.xslt .
xsltproc --stringparam csr "$(cat csr.pem)" template.xslt template.xml > request.xml
pki -u caadmin -w Secret.123 ca-cert-request-submit request.xml 
pki -u caadmin -w Secret.123 ca-cert-request-approve 7
pki -u caadmin -w Secret.123 ca-cert-find --name test
pki -u caadmin -w Secret.123 ca-cert-export 7 | openssl x509 -noout -text

# OR

mkdir -p /root/.dogtag/nssdb
pk12util -i /root/.dogtag/pki-tomcat/ca_admin_cert.p12 -d /root/.dogtag/nssdb
pki -d /root/.dogtag/nssdb -n caadmin ca-cert-export 7
