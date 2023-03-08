# ISSUING

## generate a request

generate a PKCS#10 CSR

    openssl genrsa -out /tmp/key.pem 
    openssl req -new -key /tmp/key.pem -subj '/CN=test' -out /tmp/csr.pem

Retrieve a request template

    pki -d /root/.dogtag/nssdb -n caadmin ca-cert-request-profile-show caCACert --output template.xml

generate the request from the CSR and the template

    xsltproc --stringparam csr "$(cat /tmp/csr.pem)" template.xslt template.xml > request.xml

## submit the request

Submit the request as admin:

```
# pki -d /root/.dogtag/nssdb -n caadmin ca-cert-request-submit request.xml 
-----------------------------
Submitted certificate request
-----------------------------
  Request ID: 11
  Type: enrollment
  Request Status: pending
  Operation Result: success
```

Approve the request as admin:

```
# pki -d /root/.dogtag/nssdb -n caadmin ca-cert-request-approve 11
  Request ID: 11
  Profile: Manual Certificate Manager Signing Certificate Enrollment
  Type: enrollment
  Status: pending

  Certificate Request Input:
    cert_request_type: pkcs10
    cert_request: -----BEGIN CERTIFICATE REQUEST-----
MIICVDCCATwCAQAwDzENMAsGA1UEAwwEdGVzdDCCASIwDQYJKoZIhvcNAQEBBQAD
ggEPADCCAQoCggEBAL6fSzZIqDYaz+O4WamobixapcoALtNqz1sglijmTHd4CsAr
PpqKRyiar4+Q6DlfF1cMVLoenpVUCjuqu0oUet+D0ckoAbbzPpxA7UN2VQyP4wqG
4k2Hf0FJCmswiJvR2Dfvlx7wjNKBTpZrQSGl2MDXNzumnM8lACyhYiCkAwnBxg9m
GLBC0K2h0G/hovWnzGQbWXtviDK18DnQocINSS4NZK/oMB86nhGPavPwdYJ5wk6Y
hWUP0vUns5Z39hutASn8KNi0a06++bXsCqNiLwXf2/boseU9daqrxXXD/a3HV+Ii
XIs/ouLamp6LSf8gWZ6lyi7BnBUitFgnThjZG2MCAwEAAaAAMA0GCSqGSIb3DQEB
CwUAA4IBAQBumRmYdQ7heGzZ+w8fm5zzojNUY2gqVOeMpVPIL6VHdWPfTe/Fv22R
LSWFI/WwAM+eAE7JWywjEx3x/3ULmUAYqOJesv6lE0UXoYHwWgbkP+h8mPZJcu6f
MJatAX9OSoom7vfcBQI5YvJ9gyfTFxtYU6uB0I7iTtE/aeOgGrejVHiF/fO5jKA1
8SMMysbuWsFRTB2OMbr0qrriebcQPjW1pne32UqNf7x30K9WBZGi6h1vJFxZWCPA
DY7cqGtiLy/b5IsmbQX6nFnIDdC2hmani+yhVhdpgwINGcQ7p7LHrftdVeQ+0Itt
oeeQpjhubCvoWUlj/n5SsewPPphZX01g
-----END CERTIFICATE REQUEST-----

  Requestor Information:
    none

Are you sure (y/N)? y
-------------------------------
Approved certificate request 11
-------------------------------
  Request ID: 11
  Type: enrollment
  Request Status: complete
  Operation Result: success
  Certificate ID: 0x7
```

Retrieve the certificate:

```
# pki -d /root/.dogtag/nssdb -n caadmin ca-cert-find --name test
---------------
1 entries found
---------------
  Serial Number: 0x7
  Subject DN: CN=test
  Issuer DN: CN=CA Signing Certificate,OU=pki-tomcat,O=EXAMPLE
  Status: VALID
  Type: X.509 version 3
  Key Algorithm: PKCS #1 RSA with 2048-bit key
  Not Valid Before: Fri Feb 24 09:03:12 UTC 2023
  Not Valid After: Tue Feb 24 07:48:16 UTC 2043
  Issued On: Fri Feb 24 09:08:09 UTC 2023
  Issued By: caadmin
----------------------------
Number of entries returned 1
----------------------------
```

To view the contents of a certificate:

    pki -d /root/.dogtag/nssdb -n caadmin ca-cert-export 0x7 | openssl x509  -noout -text

