#!/bin/zsh

allconf=""
for f in .kubeconfig-* ; do
    allconf=${allconf}:$f
done
KUBECONFIG=$allconf kubectl config view --flatten > .kubeconfig
