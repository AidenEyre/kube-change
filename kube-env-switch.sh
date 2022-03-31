#!/bin/bash
#
# Tool to switch clusters and namespaces.
#
# Examples:
#   ./kube-env-switch.sh my-cluster
#   ./kube-env-switch.sh my-cluster my-namespace
#   ./kube-env-switch.sh -n my-namespace

CLR_DECOR=$(printf '\e[0m');
YLLW_TXT=$(printf '\e[1;33m');
ALL_CTX="$(kubectl config get-clusters | tail -n +2 | sed 's/^/  /' | column)"
curr_ns=""
all_ns=""
curr_ctx="$(kubectl config current-context)"

while getopts "n:" opt; do
  case $opt in
    n) namespace="${OPTARG}";;
    \?) echo "Invalid option: -${OPTARG}"; exit 1;;
  esac
done

update_ns() {
  curr_ns="$(kubectl config view --minify | grep namespace | cut -c16-100)"
  all_ns="$(kubectl get namespaces \
          -o=jsonpath='{range .items[*].metadata.name}{@}{"\n"}{end}' \
          | sed 's/^/  /' | column)"
}
set_context() {
  if [[ ! $(kubectl config use-context "${1}") ]]; then
    printf "\nAvailable Clusters:\n%s\n\n" "${ALL_CTX}"
    exit 1
  else
    curr_ctx="$(kubectl config current-context)"
    update_ns
    return
  fi
}
set_namespace() {
  if [[ "$(kubectl get namespace)" != *"${1}"* ]]; then
    printf "error: no namespace exists with the name: \"%s\"\n" "${1}"
    printf "\nAvailable Namespaces in %s:\n%s\n\n" "${curr_ctx}" "${all_ns}"
    exit 1
  else
    kubectl config set-context "${curr_ctx}" --namespace="${1}" 
    update_ns
  fi
}

update_ns # Set namespace variables before jumping into the if statement.
if [[ $# = 0 ]]; then # Print context/namespace info.
  printf "\nCurrent Context: %s%s%s" "${YLLW_TXT}" "${curr_ctx}" "${CLR_DECOR}"
  printf "\nCurrent Namespace: %s%s%s\n" "${YLLW_TXT}" "${curr_ns}" "${CLR_DECOR}"
  printf "\nAvailable Clusters:\n%s\n" "${ALL_CTX}"
  printf "\nAvailable Namespaces In %s:\n%s\n\n" "${curr_ctx}" "${all_ns}"
  exit 0
elif [[ $# = 1 ]]; then # Set the context if there is only one argument.
  set_context "${1}"
  printf "Now using context: %s%s%s " "${YLLW_TXT}" "${curr_ctx}" "${CLR_DECOR}"
  printf "in the namespace: %s%s%s\n" "${YLLW_TXT}" "${curr_ns}" "${CLR_DECOR}"
  exit 0
elif [[ "${namespace}" ]]; then # Set the context if '-n' was used.
  set_namespace "${namespace}"
  printf "Now using namespace: %s%s%s " "${YLLW_TXT}" "${curr_ns}" "${CLR_DECOR}"
  printf "in the context: %s%s%s\n" "${YLLW_TXT}" "${curr_ctx}" "${CLR_DECOR}"
  exit 0
elif [[ $# = 2 ]]; then # Set the context and namespace if there are two args.
  set_context "${1}"
  set_namespace "${2}"
  printf "Now using context: %s%s%s " "${YLLW_TXT}" "${curr_ctx}" "${CLR_DECOR}"
  printf "in the namespace: %s%s%s\n" "${YLLW_TXT}" "${curr_ns}" "${CLR_DECOR}"
  exit 0
fi
