#!/bin/bash

function usage() {

    log "Usage: sudo getPodInfo.sh POD_NAME|--all [--json|--wide|--details]"
    log ""
    log "Examples:"
    log ""
    log "Get the info for all pods:"
    log "$ sudo getPodInfo.sh --all"
    log ""
    log "Get the info for all pods in JSON format:"
    log "$ sudo getPodInfo.sh --all --json"
    log ""
    log "Get the info for a pod named foo:"
    log "$ sudo getPodInfo.sh foo"
    log ""
    log "Get the info for a pod named foo in JSON format:"
    log "$ sudo getPodInfo.sh foo --json"
    log ""
    log "Get detailed info for a pod named foo in JSON format:"
    log "$ sudo getPodInfo.sh foo --details"
    log ""
    log "Get detailed info for all pods:"
    log "$ sudo getPodInfo.sh --details"

}

function init() {

    # Source the prereqs
    scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    . "/etc/ictools.conf"
    . "${scriptDir}/utils.sh"

    # Make sure we're running as root
    checkForRoot

    # Make sure this is a Kubernetes node
    checkForK8s

    # Verify ictools.conf data is available
    if [[ -z "${icNamespace}" ]]; then
        log "The icNamespace variable must be set in /etc/ictools.conf"
        exit 1
    fi 

    # Get the pod name or the special '--all' (required)
    if [[ -z "${1}" ]]; then
        usage
        exit 1
    else
        pod="${1}"
    fi

    # Get the format (optional) 
    if [[ ! -z "${2}" ]]; then
        format="${2}" 
        if [[ "${format}" != "--json" && "${format}" != "--wide" && "${format}" != "--details" ]]; then
            log "Unrecognized format ${format}. Using wide format..."
            format="--wide"
        fi
        format=$(echo ${format} | tr -d "-")
    fi

}

init "${@}"

# Get the pod info
if [[ "${pod}" == "--all" && "${format}" != "details" ]]; then
    "${kubectl}" get pods --namespace "${icNamespace}" --output "${format}"
elif [[ "${pod}" != "--all" && "${format}" != "details" ]]; then
    "${kubectl}" get pod --namespace "${icNamespace}" --output "${format}" "${pod}"
elif [[ "${pod}" == "--all" && "${format}" == "details" ]]; then
    "${kubectl}" describe pods --namespace "${icNamespace}"
elif [[ "${pod}" != "--all" && "${format}" == "details" ]]; then
    "${kubectl}" describe pod --namespace "${icNamespace}" "${pod}"
fi
