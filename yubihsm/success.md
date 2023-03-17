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


# Not working

Although certificates can be retrieved from the HSM as well as the internal store using the `pki` tool:

```
# pki -d /etc/pki/pki-tomcat/alias nss-cert-show YubiHSM:subsystem
Enter password for YubiHSM

  Serial Number: 4
  Subject DN: CN=Subsystem Certificate,OU=pki-tomcat,O=EXAMPLE
  Issuer DN: CN=CA Signing Certificate,OU=pki-tomcat,O=EXAMPLE
  Not Valid Before: Sat Feb 25 21:01:31 UTC 2023
  Not Valid After: Fri Feb 14 21:01:31 UTC 2025
  Trust Attributes: u,u,u
```

```
# pki -d /etc/pki/pki-tomcat/alias -c Secret.123 nss-cert-export YubiHSM:subsystem
Enter password for YubiHSM

-----BEGIN CERTIFICATE-----
MIIDkjCCAnqgAwIBAgIBBDANBgkqhkiG9w0BAQsFADBIMRAwDgYDVQQKDAdFWEFNUExFMRMwEQYD
VQQLDApwa2ktdG9tY2F0MR8wHQYDVQQDDBZDQSBTaWduaW5nIENlcnRpZmljYXRlMB4XDTIzMDIy
NTIxMDEzMVoXDTI1MDIxNDIxMDEzMVowRzEQMA4GA1UECgwHRVhBTVBMRTETMBEGA1UECwwKcGtp
LXRvbWNhdDEeMBwGA1UEAwwVU3Vic3lzdGVtIENlcnRpZmljYXRlMIIBIjANBgkqhkiG9w0BAQEF
AAOCAQ8AMIIBCgKCAQEA014xx9mPwBv8EsQzVKZ5h2ed6lU1KP62rq5SnId77xodvpUVSsJpSxn3
xlLo45TzIC74tS49djdLyR53OhUVIUB5dSJJly0MiaNU+Gej3MTVoRQQ0Gq/bIjfD/1fwMzy6ETT
Mr7zssfKh/0IQNe4bbzFhjg57cHOndYOOx8iVeyp7GY3USGjkmZhe4MVM1EL+veRdTIfF+oZauKy
GMVzDzgLpgz/3JZko6MJI2hQpotap7Lx0SS45fewTtRrUJwyv2XGNJsLTG1iyW5f0Le3bd4CNAWX
JibeMeon3uEg/lo8MhNxDBpzvfUrnyqb9VV7U+qY5Zeg+bebDfkChKtFtQIDAQABo4GHMIGEMB8G
A1UdIwQYMBaAFDvzP/QIvyqpT4LvQr4y+943nIWuMDwGCCsGAQUFBwEBBDAwLjAsBggrBgEFBQcw
AYYgaHR0cDovL3VidW50dS1qYW1teTo4MDgwL2NhL29jc3AwDgYDVR0PAQH/BAQDAgTwMBMGA1Ud
JQQMMAoGCCsGAQUFBwMCMA0GCSqGSIb3DQEBCwUAA4IBAQCcvpgLtU/YeVBAmblq/xYGUIRtAcj6
wIpvxfX5ddL/HG/gvCLpoVrNgihVu24rFLeWmiZ24REfAeKtpUoQ8fkuy9a/F3dDXg3NB6xiXUkq
dd9K63NT1NZeqvCofx08FqXW9VOkOqPiIEWGdraT2Udg/ORiFrx/LL3JIzV/kzdUBaNkwWq+zzNK
TImy0ijXd6ylRSxalGRzvNiOfqRZxa8byYTpMu+M+U2brRjG8+DO3RNlWOCtzLV5OZ/+2qMFCbnr
Zr7wPVnoKv6EV8pXCArCFDMyOJXroPIB9byYOtkqbkdd6WsEaqZnhCigMjNBi852iSUo0zbRMgC9
CthoeT7l
-----END CERTIFICATE-----
```

```
# pki -d /etc/pki/pki-tomcat/alias -c Secret.123 nss-cert-export sslserver
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBADANBgkqhkiG9w0BAQsFADA1MRwwGgYDVQQKExMyMDIzLTAyLTI1IDIx
OjAwOjI1MRUwEwYDVQQDEwx1YnVudHUtamFtbXkwHhcNMjMwMjI1MjEwMDI3WhcNMjQwMjI1MjEw
MDI3WjA1MRwwGgYDVQQKExMyMDIzLTAyLTI1IDIxOjAwOjI1MRUwEwYDVQQDEwx1YnVudHUtamFt
bXkwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDGVwm5fKSv9/6SNH/l5CnGgFGrP7fi
rEn2H8uPwWDGfEwnk2GV2lM1OLQwFDxIejlkX2Jsb7aPYn/bNDUpv4P3WtryaTAdsjgokuo+G+3G
xABrj8/FwdStePitM03WBqEBhWYaKp0pItIQg2oW5QVGmRVr4Z3R1B4OudtOD1iJjkM1N0NsxURO
vbdDOoyH2cuNkemtcLGzp7n1lt/73Nu4NPg799fS70QoI7ln/M+rNZrL+WhQT2Ul45zPlHUz9wxW
KpluFtce7WIXPEH0R8b7AW9wMdcx2mOzEgPptU8Hp3o8ijIQgdOwV3YlCTpeEZENWw15se0nBUJn
M66OY7DzAgMBAAEwDQYJKoZIhvcNAQELBQADggEBAEyTV0s+JbUBZ3FKOJTpMAmcfYP/vUutCjZj
hxWTjCdd8dF3pHTd9RUlfE5AAxHUe07Ph4MH20vwcndOMFwm2mqPCX9iYobd7n26/dM5meSJQYEm
YiC3MeppuG7dzidT5ii84G8vDXcSH8bDjE5INUd3qsFzQGLSZ3lJa/8MHW0JMuKUx93qlJzgYXNi
THDzh0dw8GANhHifE6Aa0wAZYTKsm5f2cvaOMvifD+oa6aAuvy6pjLa8m+5bKAJdYQC7KGpOc+XK
ARK3/+QPHIfV73y2FyylkK3QHv8UU2hz/0FDDMyrd/VV1hSKlNdIg0xDaTmmkzKzLYDltxt6K9ts
9EM=
-----END CERTIFICATE-----
```

This doesn't seem to work for the NSS `certutil` tool.

Internal certificates can be retrieved:

```
# certutil -L -d /etc/pki/pki-tomcat/alias  -n sslserver -a
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBADANBgkqhkiG9w0BAQsFADA1MRwwGgYDVQQKExMyMDIz
LTAyLTI1IDIxOjAwOjI1MRUwEwYDVQQDEwx1YnVudHUtamFtbXkwHhcNMjMwMjI1
MjEwMDI3WhcNMjQwMjI1MjEwMDI3WjA1MRwwGgYDVQQKExMyMDIzLTAyLTI1IDIx
OjAwOjI1MRUwEwYDVQQDEwx1YnVudHUtamFtbXkwggEiMA0GCSqGSIb3DQEBAQUA
A4IBDwAwggEKAoIBAQDGVwm5fKSv9/6SNH/l5CnGgFGrP7firEn2H8uPwWDGfEwn
k2GV2lM1OLQwFDxIejlkX2Jsb7aPYn/bNDUpv4P3WtryaTAdsjgokuo+G+3GxABr
j8/FwdStePitM03WBqEBhWYaKp0pItIQg2oW5QVGmRVr4Z3R1B4OudtOD1iJjkM1
N0NsxUROvbdDOoyH2cuNkemtcLGzp7n1lt/73Nu4NPg799fS70QoI7ln/M+rNZrL
+WhQT2Ul45zPlHUz9wxWKpluFtce7WIXPEH0R8b7AW9wMdcx2mOzEgPptU8Hp3o8
ijIQgdOwV3YlCTpeEZENWw15se0nBUJnM66OY7DzAgMBAAEwDQYJKoZIhvcNAQEL
BQADggEBAEyTV0s+JbUBZ3FKOJTpMAmcfYP/vUutCjZjhxWTjCdd8dF3pHTd9RUl
fE5AAxHUe07Ph4MH20vwcndOMFwm2mqPCX9iYobd7n26/dM5meSJQYEmYiC3Mepp
uG7dzidT5ii84G8vDXcSH8bDjE5INUd3qsFzQGLSZ3lJa/8MHW0JMuKUx93qlJzg
YXNiTHDzh0dw8GANhHifE6Aa0wAZYTKsm5f2cvaOMvifD+oa6aAuvy6pjLa8m+5b
KAJdYQC7KGpOc+XKARK3/+QPHIfV73y2FyylkK3QHv8UU2hz/0FDDMyrd/VV1hSK
lNdIg0xDaTmmkzKzLYDltxt6K9ts9EM=
-----END CERTIFICATE-----
```

But certificates stored in the HSM cannot:

```
# certutil -L -d /etc/pki/pki-tomcat/alias -h YubiHSM -f ./password -n YubiHSM:subsystem -a
CA Audit Signing Certificate - EXAMPLE                       ,,P  
Subsystem Certificate - EXAMPLE                              c,c,c
CA OCSP Signing Certificate - EXAMPLE                        c,c,c
CA Signing Certificate - EXAMPLE                             CT,C,C
sslserver                                                    CTu,Cu,Cu
```

