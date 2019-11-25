#!/bin/bash

COMMAND=podman
TLS_VERIFY="--tls-verify=false"

INTERNAL_REGISTRY_ROUTE="default-route-openshift-image-registry.apps.rhopp-airgap2.qe.devcluster.openshift.com/openshift"
UBI8_MINIMAL_BASE="registry.redhat.io"
UBI8_MINIMAL_IMAGE="ubi8-minimal:8.0-213"
POSTGRES_BASE="registry.redhat.io/rhscl"
POSTGRES_IMAGE="postgresql-96-rhel7:1-47"


SSO_BASE="registry.redhat.io/redhat-sso-7"
SSO_IMAGE="sso73-openshift:1.0-15"


while read LINE; do
     echo "Pulling quay.io/$LINE"
     $COMMAND pull "quay.io/$LINE"
done <imagesList


while read LINE; do
    NEWTAG=$(sed 's/^crw\///g' <<< $LINE | sed 's/2.0.*/2.0/g')
    echo "Tagging  \"quay.io/$LINE\" by \"$INTERNAL_REGISTRY_ROUTE/$NEWTAG\""
    $COMMAND tag "quay.io/$LINE" "$INTERNAL_REGISTRY_ROUTE/$NEWTAG"
    echo "push $TLS_VERIFYing \"$INTERNAL_REGISTRY_ROUTE/$NEWTAG\""
    $COMMAND push $TLS_VERIFY  "$INTERNAL_REGISTRY_ROUTE/$NEWTAG"
done <imagesList


$COMMAND pull $UBI8_MINIMAL_BASE/$UBI8_MINIMAL_IMAGE
$COMMAND tag $UBI8_MINIMAL_BASE/$UBI8_MINIMAL_IMAGE $INTERNAL_REGISTRY_ROUTE/$UBI8_MINIMAL_IMAGE
$COMMAND push $TLS_VERIFY  $INTERNAL_REGISTRY_ROUTE/$UBI8_MINIMAL_IMAGE


$COMMAND pull $POSTGRES_BASE/$POSTGRES_IMAGE
$COMMAND tag $POSTGRES_BASE/$POSTGRES_IMAGE $INTERNAL_REGISTRY_ROUTE/$POSTGRES_IMAGE
$COMMAND push $TLS_VERIFY  $INTERNAL_REGISTRY_ROUTE/$POSTGRES_IMAGE

$COMMAND pull $SSO_BASE/$SSO_IMAGE
$COMMAND tag $SSO_BASE/$SSO_IMAGE $INTERNAL_REGISTRY_ROUTE/$SSO_IMAGE
$COMMAND push $TLS_VERIFY  $INTERNAL_REGISTRY_ROUTE/$SSO_IMAGE