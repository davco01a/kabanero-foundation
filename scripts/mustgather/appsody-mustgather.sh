#!/bin/bash
#
# Run this script to collect debug information

set -Euox pipefail

COMPONENT="appsody.dev"
BIN=oc
LOGS_DIR="${LOGS_DIR:-kabanero-debug}"

# Describe and Get all api resources of component across cluster

APIRESOURCES=$(${BIN} get crds -o jsonpath="{.items[*].metadata.name}" | tr ' ' '\n' | grep ${COMPONENT})

for APIRESOURCE in ${APIRESOURCES[@]}
do
	NAMESPACES=$(${BIN} get ${APIRESOURCE} --all-namespaces=true -o jsonpath='{range .items[*]}{@.metadata.namespace}{"\n"}{end}' | uniq)
	for NAMESPACE in ${NAMESPACES[@]}
	do
		mkdir -p ${LOGS_DIR}/${NAMESPACE}/${APIRESOURCE}
		${BIN} describe ${APIRESOURCE} -n ${NAMESPACE} > ${LOGS_DIR}/${NAMESPACE}/${APIRESOURCE}/describe.log
		${BIN} get ${APIRESOURCE} -n ${NAMESPACE} -o=yaml > ${LOGS_DIR}/${NAMESPACE}/${APIRESOURCE}/get.yaml
	done
done
