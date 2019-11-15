#!/bin/bash

INTERNAL_REGISTRY_ROUTE="default-route-openshift-image-registry.apps.rhopp-airgap.qe.devcluster.openshift.com/openshift"
UBI8_MINIMAL_BASE="registry.redhat.io"
UBI8_MINIMAL_IMAGE="ubi8-minimal:8.0-213"
POSTGRES_BASE="registry.redhat.io/rhscl"
POSTGRES_IMAGE="postgresql-96-rhel7:1-47"

SSO_BASE="registry.redhat.io/redhat-sso-7"
SSO_IMAGE="sso73-openshift:1.0-15"


while read LINE; do
     echo "Pulling quay.io/$LINE"
     podman pull "quay.io/$LINE"
done <imagesList


while read LINE; do
    NEWTAG=$(sed 's/^crw\///g' <<< $LINE)
    echo "Tagging  \"quay.io/$LINE\" by \"$INTERNAL_REGISTRY_ROUTE/$NEWTAG\""
    podman tag "quay.io/$LINE" "$INTERNAL_REGISTRY_ROUTE/$NEWTAG"
    echo "Pushing \"$INTERNAL_REGISTRY_ROUTE/$NEWTAG\""
    podman push --tls-verify=false "$INTERNAL_REGISTRY_ROUTE/$NEWTAG"
done <imagesList


podman pull $UBI8_MINIMAL_BASE/$UBI8_MINIMAL_IMAGE
podman tag $UBI8_MINIMAL_BASE/$UBI8_MINIMAL_IMAGE $INTERNAL_REGISTRY_ROUTE/$UBI8_MINIMAL_IMAGE
podman push --tls-verify=false $INTERNAL_REGISTRY_ROUTE/$UBI8_MINIMAL_IMAGE


podman pull $POSTGRES_BASE/$POSTGRES_IMAGE
podman tag $POSTGRES_BASE/$POSTGRES_IMAGE $INTERNAL_REGISTRY_ROUTE/$POSTGRES_IMAGE
podman push --tls-verify=false $INTERNAL_REGISTRY_ROUTE/$POSTGRES_IMAGE

podman pull $SSO_BASE/$SSO_IMAGE
podman tag $SSO_BASE/$SSO_IMAGE $INTERNAL_REGISTRY_ROUTE/$SSO_IMAGE
podman push --tls-verify=false $INTERNAL_REGISTRY_ROUTE/$SSO_IMAGE