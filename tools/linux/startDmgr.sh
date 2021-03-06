#!/bin/bash

function init() {

    # Source the prereqs
    scriptDir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    . "/etc/ictools.conf" 
    . "${scriptDir}/utils.sh"

    # Make sure we're running as root
    checkForRoot

    # Make sure this is a Deployment Manager node
    checkForDmgr

}

init "${@}"

# Build an array of WAS profiles
if [[ "$(directoryExists "${wasProfileRoot}")" == "true" && "$(directoryHasSubDirs "${wasProfileRoot}")" == "true" ]]; then
    cd "${wasProfileRoot}" && profiles=($(ls -d *))
else
    log "Error: wasProfileRoot must be set to a valid directory in ictools.conf"
fi

for profile in "${profiles[@]}"; do

    # Only need to continue if the profile type is DEPLOYMENT_MANAGER
    if [[ "$(isWASDmgrProfile "${profile}")" == "true" ]]; then
        # If there is no servers directory or there are no subdirectories, skip this profile 
        if [[ "$(directoryExists "${wasProfileRoot}/${profile}/servers")" == "false" ||
              "$(directoryHasSubDirs "${wasProfileRoot}/${profile}/servers")" == "false" ]]; then 
            continue
        else
            # Get an array of servers
            cd "${wasProfileRoot}/${profile}/servers" && servers=($(ls -d *)) 
            for server in "${servers[@]}"; do
                if [[ "$(isServerInWASCell "${server}" "${profile}")" == "true" ]]; then
                    # The server is part of the cell, so go ahead and start it
                    startWASServer "${server}" "${wasProfileRoot}/${profile}"
                fi
            done
        fi
    fi
done
