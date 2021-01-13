#!/usr/bin/env bash
set -euo pipefail

############################################################
## Configurations ##########################################
############################################################
main_server_address="https://api.restfulness.app/"
main_server_username=""
main_server_password=""

page_size=10
bookmark_link=""

############################################################
## Functions ###############################################
############################################################
usage() {

  cat <<-EOS
usage: $(basename "$0") [options] [link url]

Comand line interface for the Restfulness social bookmarking service.

If no server URL is provided demo server will be used.

options:
  -h|--help         Show this help and exit.
  -p|--profile <profile>
                    Restfulness profile to use.
  -v
                    Verbose about current configuration.
EOS

}


login() {

    login_procedure_result=0
    login_procedure=$(curl -s -f -X POST "$main_server_address/user/login" -H  "accept: application/json" -H  "Content-Type: application/json" -d "{  \"username\": \"$main_server_username\",  \"password\": \"$main_server_password\"}") || login_procedure_result=$?
  if [ $login_procedure_result -eq 0 ]; then
    TOKEN=$(echo $login_procedure|jq .access_token|tr \" " ")
    # echo $TOKEN
 else
    echo "There was some problem in login procedure, check you configuration" 1>&2
    exit $login_procedure_result
  fi

}


parse_args() {
  while [ "$#" -ge 1 ]; do
    case "$1" in
      -h|--help|help)
        usage; exit ;;
      -p|--profile)
        region="$2"; shift ;;
      -v|--verbos)
        profile="$2"; shift ;;
      *)

        if [[ $1 != http* ]]; then
          echo "error: not a valid URL: $1" 1>&2
          exit 1
        fi

        bookmark_link="$1"
        register_bookmark  ;;
    esac
    shift
  done
}


register_bookmark() {

  if [ -n "$bookmark_link" ]; then
    curl -s -f -X POST "$main_server_address/links" -H  "accept: application/json" -H  "Authorization: Bearer $TOKEN" -H  "Content-Type: application/json" -d "{  \"url\": \"$bookmark_link\"}"
  fi

}


main() {

  page=0 
  RES=0
  
  while [ $RES -eq 0 ]
  do
        page=$(($page+1))
        curl -s -f -X GET "$main_server_address/links?page=$page&page_size=$page_size" -H  "accept: application/json" -H  "Authorization: Bearer $TOKEN" > restfulness.tmp
        RES=$?
        cat restfulness.tmp | jq .[].url
  done
}

login
parse_args "$@"
main
