# shellcheck disable=SC2148,SC1091

source /includes/colors.sh

function check_for_default_credentials() {
    e "> Checking for existence of SERVER_STEAM_ACCOUNT_TOKEN"
    if [[ -z $SERVER_STEAM_ACCOUNT_TOKEN ]]; then
        ee ">>> Missing SERVER_STEAM_ACCOUNT_TOKEN detected: Please add a token. Aborting server start ..."
        exit 1
    fi
    es "> SERVER_STEAM_ACCOUNT_TOKEN found -> $SERVER_STEAM_ACCOUNT_TOKEN"

    e "> Checking for existence of default credentials"
    if [[ -n $ADMIN_PASSWORD ]] && [[ $ADMIN_PASSWORD == "adminPasswordHere" ]]; then
        ee ">>> Security threat detected: Please change the default admin password. Aborting server start ..."
        exit 1
    fi
    if [[ -n $SERVER_PASSWORD ]] && [[ $SERVER_PASSWORD == "serverPasswordHere" ]]; then
        ee ">>> Security threat detected: Please change the default server password. Aborting server start ..."
        exit 1
    fi
    es "> No default passwords found"
}
