#!/bin/bash

set -euo pipefail


TEMPDIR=$( mktemp -d )

trap "{ rm -rf $TEMPDIR ;  }" EXIT

if [ "$#" -ne 2 ] ; then
    echo usage $0 namespace secret
    exit 1
fi

NAMESPACE=$1
SECRET=$2

# Pull the bearer token and cluster CA from the service account secret.
BEARER_TOKEN=$( kubectl get secrets -n $NAMESPACE $SECRET -o jsonpath='{.data.token}' | base64 -d )
CA_DATA=$( kubectl get secrets -n $NAMESPACE $SECRET -o jsonpath='{.data.ca\.crt}' )
CLUSTER_URL=$( kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.server}' )
CLUSTER_NAME=$( kubectl config view --minify --flatten -o jsonpath='{.clusters[0].name}' )

CONFIG=$( echo '{}' | jq --arg token "$BEARER_TOKEN" --arg ca "$CA_DATA" '{"bearerToken": $ARGS.named["token"], "tlsClientConfig": {"insecure": false, "caData": $ARGS.named["ca"]}}' )

echo '{}' | jq --arg config "$CONFIG" --arg server "$CLUSTER_URL" --arg name "$CLUSTER_NAME" '{"config": $ARGS.named["config"], "name":  $ARGS.named["name"], "server":  $ARGS.named["server"] }'
