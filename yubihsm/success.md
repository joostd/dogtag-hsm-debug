Version info:

```
$ curl http://localhost:12345/connector/status
status=OK
serial=*
version=3.0.3
pid=88712
address=localhost
port=12345
```

Certificates are successfully generated on the HSM (as seen through PKCS#11):

```
$ pkcs11-tool --module $YUBIHSM_PKCS11_MODULE --login --pin 0001password --list-objects --type cert
Using slot 0 with a present token (0x0)
Certificate Object; type = X.509 cert
  label:      ca_signing
  ID:         1c421f2ba517b405faf87de670d98d52eae992dc
Certificate Object; type = X.509 cert
  label:      ca_ocsp_signing
  ID:         950d7d347d73b2337f45ff422e44f01e9151f5fa
Certificate Object; type = X.509 cert
  label:      subsystem
  ID:         23dbac1c73b54e19eeb929726ae664e444f5220f
Certificate Object; type = X.509 cert
  label:      ca_audit_signing
  ID:         09f50c099ae0c8eab78241b107b13794318f3844
```

Certificates in the NSS db (both YubiHSM and internal):

```
# certutil -d /etc/pki/pki-tomcat/alias -L

Certificate Nickname                                         Trust Attributes
                                                             SSL,S/MIME,JAR/XPI

sslserver                                                    CTu,Cu,Cu
CA Signing Certificate - EXAMPLE                             CT,C,C
CA OCSP Signing Certificate - EXAMPLE                        c,c,c
Subsystem Certificate - EXAMPLE                              c,c,c
CA Audit Signing Certificate - EXAMPLE                       ,,P  
```

Details of the `sslserver` certificate (internal):

```
# pki -d /etc/pki/pki-tomcat/alias nss-cert-show sslserver
  Serial Number: 0
  Subject DN: CN=ubuntu-jammy,O=2023-02-25 21:00:25
  Issuer DN: CN=ubuntu-jammy,O=2023-02-25 21:00:25
  Not Valid Before: Sat Feb 25 21:00:27 UTC 2023
  Not Valid After: Sun Feb 25 21:00:27 UTC 2024
  Trust Attributes: CTu,Cu,Cu

```

Details of the `ca_signing` certificate (YubiHSM):

```
# pki -d /etc/pki/pki-tomcat/alias nss-cert-show YubiHSM:ca_signing
Enter password for YubiHSM

  Serial Number: 1
  Subject DN: CN=CA Signing Certificate,OU=pki-tomcat,O=EXAMPLE
  Issuer DN: CN=CA Signing Certificate,OU=pki-tomcat,O=EXAMPLE
  Not Valid Before: Sat Feb 25 21:01:00 UTC 2023
  Not Valid After: Wed Feb 25 21:01:00 UTC 2043
  Trust Attributes: u,u,u

```

Details of the `caadmin` client certificate (stored in the client database):

```
# pki -d /root/.dogtag/pki-tomcat/ca/alias nss-cert-show caadmin
  Serial Number: 6
  Subject DN: CN=PKI Administrator,E=caadmin@example.com,OU=pki-tomcat,O=EXAMPLE
  Issuer DN: CN=CA Signing Certificate,OU=pki-tomcat,O=EXAMPLE
  Not Valid Before: Sat Feb 25 21:01:47 UTC 2023
  Not Valid After: Fri Feb 14 21:01:47 UTC 2025
  Trust Attributes: u,u,u
```
