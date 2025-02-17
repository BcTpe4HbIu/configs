#!/bin/bash

set -euo pipefail


TEMPDIR=$( mktemp -d )

trap "{ rm -rf $TEMPDIR ; exit 255; }" EXIT

if [ "$#" -ne 3 ] ; then
    echo usage $0 namespace secret output
    exit 1
fi

NAMESPACE=$1
SECRET=$2
OUTPUT=$3

# Pull the bearer token and cluster CA from the service account secret.
BEARER_TOKEN=$( kubectl get secrets -n $NAMESPACE $SECRET -o jsonpath='{.data.token}' | base64 -d )
kubectl get secrets -n $NAMESPACE $SECRET -o jsonpath='{.data.ca\.crt}' | base64 -d > $TEMPDIR/ca.crt

CLUSTER_URL=$( kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.server}' )


kubectl config --kubeconfig=$OUTPUT \
    set-cluster \
    $CLUSTER_URL \
    --server=$CLUSTER_URL \
    --certificate-authority=$TEMPDIR/ca.crt \
    --embed-certs=true

kubectl config --kubeconfig=$OUTPUT \
    set-credentials $NAMESPACE-$SECRET --token=$BEARER_TOKEN

kubectl config --kubeconfig=$OUTPUT \
    set-context $NAMESPACE-$SECRET \
    --cluster=$CLUSTER_URL \
    --user=$NAMESPACE-$SECRET

kubectl config --kubeconfig=$OUTPUT \
    use-context $NAMESPACE-$SECRET

echo "kubeconfig written to file \"$OUTPUT\""
