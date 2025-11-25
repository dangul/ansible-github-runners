#!/bin/bash

################################################################################
# Script: GitHub Runner Setup
# Author: Daniel Gullin
# Date: 2025-10-13
################################################################################

set -e  # Exit immediately if any command fails
set -u  # Exit if undefined variables are used
set -o pipefail  # Exit if any command in a pipe fails

readonly NODEJS_VERSION=20
readonly ANSIBLE_PLAYBOOK=/usr/bin/ansible-playbook
readonly ANSIBLE_USER=ubuntu
readonly ANSIBLE_KEY=/home/ansible/.ssh/itops_id_rsa.key
readonly PLAYBOOK_DIR=/home/ansible/playbooks

RUNNER_GROUP=""
RUNNER_LABEL=""
INSTANCE_ID=""
SKIP_BOOTSTRAP=false

###
usage() {
    cat << EOF

Usage: ${0##*/} [--update] RUNNER_GROUP RUNNER_LABEL INSTANCE_ID

Arguments:
    RUNNER_GROUP    Runner group
    RUNNER_LABEL    Label for the runner
    INSTANCE_ID     Instance identifier

Options:
    --update        Skip bootstrap 

EOF
    exit 3
}

log() {
    printf "\n  - %s\n" "$1"
}

run_playbook() {
    local playbook=$1
    shift
    $ANSIBLE_PLAYBOOK "$playbook" "$@" || {
        printf "\nError: Playbook '%s' failed. Aborting.\n" "$playbook"
        exit 1
    }
}

###
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --update)
                SKIP_BOOTSTRAP=true
                shift
                ;;
            *)
                if [[ -z "$RUNNER_GROUP" ]]; then
                    RUNNER_GROUP=$1
                elif [[ -z "$RUNNER_LABEL" ]]; then
                    RUNNER_LABEL=$1
                elif [[ -z "$INSTANCE_ID" ]]; then
                    INSTANCE_ID=$1
                else
                    printf "\nError: Too many arguments\n"
                    usage
                fi
                shift
                ;;
        esac
    done
}

# Let´s go!
main() {
    parse_arguments "$@"

    # 
    if [[ -z "$RUNNER_GROUP" || -z "$RUNNER_LABEL" || -z "$INSTANCE_ID" ]]; then
        usage
    fi

    printf "\nCreating new GitHub runner...\n"

    if [[ "$SKIP_BOOTSTRAP" == false ]]; then
        log "Running Ansible bootstrap"
        run_playbook "${PLAYBOOK_DIR}/bootstrap.yml" \
            --limit "${INSTANCE_ID}*" \
            -u "$ANSIBLE_USER" \
            --private-key "$ANSIBLE_KEY"
    else
        log "Skipping Ansible bootstrap (--update flag set)"
    fi

    log "Running GHE Runner playbook"
    run_playbook "${PLAYBOOK_DIR}/install-github-runner.yml" \
        --limit "${INSTANCE_ID}*" \
        --extra-vars "NODEJS_VERSION=$NODEJS_VERSION RUNNER_LABEL=$RUNNER_LABEL RUNNER_GROUP=$RUNNER_GROUP"

    printf "\nRunner created successfully!\n"
}

main "$@"
