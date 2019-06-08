Usage() {
 echo ""
 echo "Usage: ./createPeerAdminCard.sh [-h host] [-n]"
 echo ""
 echo "Options:"
 echo -e "\t-h or --host:\t\t(Optional) name of the host to specify in the connection profile"
 echo -e "\t-n or --noimport:\t(Optional) don't import into card store"
 echo ""
 echo "Example: ./createPeerAdminCard.sh"
 echo ""
 exit 1
}

Parse_Arguments() {
 while [ $# -gt 0 ]; do
 case $1 in
 --help)
 HELPINFO=true
 ;;
 --host | -h)
 shift
 HOST="$1"
 ;;
 --noimport | -n)
 NOIMPORT=true
 ;;
 esac
 shift
 done
}

HOST=localhost
Parse_Arguments $@

if [ "${HELPINFO}" == "true" ]; then
 Usage
fi

# Grab the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [ -z "${HL_COMPOSER_CLI}" ]; then
 HL_COMPOSER_CLI=$(which composer)
fi

echo
# check that the composer command exists at a version >v0.16
COMPOSER_VERSION=$("${HL_COMPOSER_CLI}" --version 2>/dev/null)
COMPOSER_RC=$?

if [ $COMPOSER_RC -eq 0 ]; then
 AWKRET=$(echo $COMPOSER_VERSION | awk -F. '{if ($2<19) print "1"; else print "0";}')
 if [ $AWKRET -eq 1 ]; then
 echo Cannot use $COMPOSER_VERSION version of composer with fabric 1.1, v0.19 or higher is required
 exit 1
 else
 echo Using composer-cli at $COMPOSER_VERSION
 fi
else
 echo 'No version of composer-cli has been detected, you need to install composer-cli at v0.19 or higher'
 exit 1
fi

cat << EOF > DevServer_connection.json
{
    "name": "hlfv1",
    "x-type": "hlfv1",
    "version": "1.0.0",
    "client": {
        "organization": "Org1",
        "connection": {
            "timeout": {
                "peer": {
                    "endorser": "300",
                    "eventHub": "300",
                    "eventReg": "300"
                },
                "orderer": "300"
            }
        }
    },
    "channels": {
        "mychannel": {
            "orderers": [
                "orderer.example.com"
            ],
            "peers": {
                "peer0.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer1.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                },
                "peer2.org1.example.com": {
                    "endorsingPeer": true,
                    "chaincodeQuery": true,
                    "eventSource": true
                }
            }
        }
    },
    "organizations": {
        "Org1": {
            "mspid": "Org1MSP",
            "peers": [
                "peer0.org1.example.com",
                "peer1.org1.example.com",
                "peer2.org1.example.com"
            ],
            "certificateAuthorities": [
                "ca.example.com"
            ]
        }
    },
    "orderers": {
        "orderer.example.com": {
            "url": "grpc://192.168.43.28:7050",
            "grpcOptions": {
                "ssl-target-name-override": "orderer.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICNjCCAdygAwIBAgIRAKhjprYTUvTN5F0oR8y4/6cwCgYIKoZIzj0EAwIwbDEL\nMAkGA1UEBhMCVVMxEzARBgNVBAgTCkNhbGlmb3JuaWExFjAUBgNVBAcTDVNhbiBG\ncmFuY2lzY28xFDASBgNVBAoTC2V4YW1wbGUuY29tMRowGAYDVQQDExF0bHNjYS5l\neGFtcGxlLmNvbTAeFw0xOTA1MDgwODM5MTdaFw0yOTA1MDUwODM5MTdaMGwxCzAJ\nBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQHEw1TYW4gRnJh\nbmNpc2NvMRQwEgYDVQQKEwtleGFtcGxlLmNvbTEaMBgGA1UEAxMRdGxzY2EuZXhh\nbXBsZS5jb20wWTATBgcqhkjOPQIBBggqhkjOPQMBBwNCAARVNem5aJpw4w66COKV\nQtyELBH3wai5k/gTev54RHog5jL/6q+YsNXAaxkLBX2bPyrFnXFzLUZ3r/6Eakgi\ntK5Fo18wXTAOBgNVHQ8BAf8EBAMCAaYwDwYDVR0lBAgwBgYEVR0lADAPBgNVHRMB\nAf8EBTADAQH/MCkGA1UdDgQiBCAC4Bu5i/DsqOCxSAnAyBwif6K9jQGjVBi9+IYA\nC2wW2TAKBggqhkjOPQQDAgNIADBFAiEAr1hYPMT0MPVnQlV39VRQLTbUd16OOvRp\nBpjlMI4fQUMCIAdLetIO2FA+FN9YGPgLlKmSFxmAyPVTNfKNAmDnBkKO\n-----END CERTIFICATE-----\n"
            }
        }
    },
    "peers": {
        "peer0.org1.example.com": {
            "url": "grpc://192.168.43.28:7051",
            "eventUrl": "grpc://192.168.43.28:7053",
            "grpcOptions": {
                "ssl-target-name-override": "peer0.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSTCCAe+gAwIBAgIQXwSCmlUWmoN4yhcZqb31yjAKBggqhkjOPQQDAjB2MQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEfMB0GA1UEAxMWdGxz\nY2Eub3JnMS5leGFtcGxlLmNvbTAeFw0xOTA1MDgwODM5MTdaFw0yOTA1MDUwODM5\nMTdaMHYxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH\nEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBvcmcxLmV4YW1wbGUuY29tMR8wHQYD\nVQQDExZ0bHNjYS5vcmcxLmV4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D\nAQcDQgAEJSwZK3Y5tsOj4QhyoQwrepWOuH/6oMWQCIS34pEDzpiAxYIhjoc6x/u9\nvsKRtX4IQrhhwiXhOdioOq++7ZClg6NfMF0wDgYDVR0PAQH/BAQDAgGmMA8GA1Ud\nJQQIMAYGBFUdJQAwDwYDVR0TAQH/BAUwAwEB/zApBgNVHQ4EIgQgt5SIpkh5mVKC\ny7kassJ3g+eyMX36vCCCtu7oqe1LcWcwCgYIKoZIzj0EAwIDSAAwRQIhAL3pCwdB\n2BNpPI2Mdt69kh7WarJAF0yioYVRRAp//E3UAiBtiFb52x4s20tvwtwlKxnFbdNu\nUCUReVn7J/+kKxyncA==\n-----END CERTIFICATE-----\n"
            }
        },
        "peer1.org1.example.com": {
            "url": "grpc://192.168.43.101:8051",
            "eventUrl": "grpc://192.168.43.101:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer1.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSTCCAe+gAwIBAgIQXwSCmlUWmoN4yhcZqb31yjAKBggqhkjOPQQDAjB2MQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEfMB0GA1UEAxMWdGxz\nY2Eub3JnMS5leGFtcGxlLmNvbTAeFw0xOTA1MDgwODM5MTdaFw0yOTA1MDUwODM5\nMTdaMHYxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH\nEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBvcmcxLmV4YW1wbGUuY29tMR8wHQYD\nVQQDExZ0bHNjYS5vcmcxLmV4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D\nAQcDQgAEJSwZK3Y5tsOj4QhyoQwrepWOuH/6oMWQCIS34pEDzpiAxYIhjoc6x/u9\nvsKRtX4IQrhhwiXhOdioOq++7ZClg6NfMF0wDgYDVR0PAQH/BAQDAgGmMA8GA1Ud\nJQQIMAYGBFUdJQAwDwYDVR0TAQH/BAUwAwEB/zApBgNVHQ4EIgQgt5SIpkh5mVKC\ny7kassJ3g+eyMX36vCCCtu7oqe1LcWcwCgYIKoZIzj0EAwIDSAAwRQIhAL3pCwdB\n2BNpPI2Mdt69kh7WarJAF0yioYVRRAp//E3UAiBtiFb52x4s20tvwtwlKxnFbdNu\nUCUReVn7J/+kKxyncA==\n-----END CERTIFICATE-----\n"
            }
        },
        "peer1.org1.example.com": {
            "url": "grpc://192.168.43.229:8051",
            "eventUrl": "grpc://192.168.43.229:8053",
            "grpcOptions": {
                "ssl-target-name-override": "peer2.org1.example.com"
            },
            "tlsCACerts": {
                "pem": "-----BEGIN CERTIFICATE-----\nMIICSTCCAe+gAwIBAgIQXwSCmlUWmoN4yhcZqb31yjAKBggqhkjOPQQDAjB2MQsw\nCQYDVQQGEwJVUzETMBEGA1UECBMKQ2FsaWZvcm5pYTEWMBQGA1UEBxMNU2FuIEZy\nYW5jaXNjbzEZMBcGA1UEChMQb3JnMS5leGFtcGxlLmNvbTEfMB0GA1UEAxMWdGxz\nY2Eub3JnMS5leGFtcGxlLmNvbTAeFw0xOTA1MDgwODM5MTdaFw0yOTA1MDUwODM5\nMTdaMHYxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpDYWxpZm9ybmlhMRYwFAYDVQQH\nEw1TYW4gRnJhbmNpc2NvMRkwFwYDVQQKExBvcmcxLmV4YW1wbGUuY29tMR8wHQYD\nVQQDExZ0bHNjYS5vcmcxLmV4YW1wbGUuY29tMFkwEwYHKoZIzj0CAQYIKoZIzj0D\nAQcDQgAEJSwZK3Y5tsOj4QhyoQwrepWOuH/6oMWQCIS34pEDzpiAxYIhjoc6x/u9\nvsKRtX4IQrhhwiXhOdioOq++7ZClg6NfMF0wDgYDVR0PAQH/BAQDAgGmMA8GA1Ud\nJQQIMAYGBFUdJQAwDwYDVR0TAQH/BAUwAwEB/zApBgNVHQ4EIgQgt5SIpkh5mVKC\ny7kassJ3g+eyMX36vCCCtu7oqe1LcWcwCgYIKoZIzj0EAwIDSAAwRQIhAL3pCwdB\n2BNpPI2Mdt69kh7WarJAF0yioYVRRAp//E3UAiBtiFb52x4s20tvwtwlKxnFbdNu\nUCUReVn7J/+kKxyncA==\n-----END CERTIFICATE-----\n"
            }
        }
    },
    "certificateAuthorities": {
        "ca.example.com": {
            "url": "http://192.168.43.28:7054",
            "caName": "ca.example.com",
            "httpOptions": {
                "verify": false
            }
        }
    }
}
EOF

PRIVATE_KEY="${DIR}"/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/keystore/0f6f2b8f0a82561760036ade2115be95aa3f75039301ba39ed4cdc81cebbb950_sk
CERT="${DIR}"/crypto-config/peerOrganizations/org1.example.com/users/Admin@org1.example.com/msp/signcerts/Admin@org1.example.com-cert.pem

if [ "${NOIMPORT}" != "true" ]; then
 CARDOUTPUT=/tmp/PeerAdmin@hlfv1.card
else
 CARDOUTPUT=PeerAdmin@hlfv1.card
fi

"${HL_COMPOSER_CLI}" card create -p DevServer_connection.json -u PeerAdmin -c "${CERT}" -k "${PRIVATE_KEY}" -r PeerAdmin -r ChannelAdmin --file $CARDOUTPUT

if [ "${NOIMPORT}" != "true" ]; then
 if "${HL_COMPOSER_CLI}" card list -c PeerAdmin@hlfv1 > /dev/null; then
 "${HL_COMPOSER_CLI}" card delete -c PeerAdmin@hlfv1
 fi

"${HL_COMPOSER_CLI}" card import --file /tmp/PeerAdmin@hlfv1.card 
 "${HL_COMPOSER_CLI}" card list
 echo "Hyperledger Composer PeerAdmin card has been imported, host of fabric specified as '${HOST}'"
 rm /tmp/PeerAdmin@hlfv1.card
else
 echo "Hyperledger Composer PeerAdmin card has been created, host of fabric specified as '${HOST}'"
fi

