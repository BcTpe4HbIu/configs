#!/bin/bash -e

# Usage ./k8s-service-account-kubeconfig.sh ( namespace ) ( service account name )

TEMPDIR=$( mktemp -d )

trap "{ rm -rf $TEMPDIR ; exit 255; }" EXIT

SA_SECRET=$( kubectl get sa -n $1 $2 -o jsonpath='{.secrets[0].name}' )

# Pull the bearer token and cluster CA from the service account secret.
BEARER_TOKEN=$( kubectl get secrets -n $1 $SA_SECRET -o jsonpath='{.data.token}' | base64 -d )
kubectl get secrets -n $1 $SA_SECRET -o jsonpath='{.data.ca\.crt}' | base64 -d > $TEMPDIR/ca.crt

CLUSTER_URL=$( kubectl config view --minify --flatten -o jsonpath='{.clusters[0].cluster.server}' )


KUBECONFIG=kubeconfig

kubectl config --kubeconfig=$KUBECONFIG \
    set-cluster \
    $CLUSTER_URL \
    --server=$CLUSTER_URL \
    --certificate-authority=$TEMPDIR/ca.crt \
    --embed-certs=true

kubectl config --kubeconfig=$KUBECONFIG \
    set-credentials $1-$2 --token=$BEARER_TOKEN

kubectl config --kubeconfig=$KUBECONFIG \
    set-context $1-$2 \
    --cluster=$CLUSTER_URL \
    --user=$1-$2

kubectl config --kubeconfig=$KUBECONFIG \
    use-context $1-$2

echo "kubeconfig written to file \"$KUBECONFIG\""
