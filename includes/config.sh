# shellcheck disable=SC2148,SC1091

source /includes/colors.sh

current_setting=1
settings_amount=4

function e_with_counter() {
    local padded_number
    padded_number=$(printf "%02d" $current_setting)
    # shellcheck disable=SC2145
    e "> ($padded_number/$settings_amount) Setting $@"
    current_setting=$((current_setting + 1))
}

function setup_server_cfg() {
    ei ">>> Setting up server.cfg ..."
    if [ ! -d "${GAME_CONFIG_PATH}" ]; then
        mkdir -p "${GAME_CONFIG_PATH}/"
    fi
    # Copy default-config, which comes with SteamCMD to gameserver save location
    ew "> Copying server.cfg.template to ${GAME_SETTINGS_FILE}"
    cp --no-preserve=ownership "${THEFOREST_TEMPLATE_FILE}" "${GAME_SETTINGS_FILE}"

    if [[ -n ${ADMIN_PASSWORD+x} ]]; then
        e_with_counter "serverPasswordAdmin to '$ADMIN_PASSWORD'"
        sed -E -i "s/^serverPasswordAdmin.*$/serverPasswordAdmin $ADMIN_PASSWORD/" "$GAME_SETTINGS_FILE"
    fi
    if [[ -n ${SERVER_PASSWORD+x} ]]; then
        e_with_counter "serverPassword to '$SERVER_PASSWORD'"
        sed -E -i "s/^serverPassword.*$/serverPassword $SERVER_PASSWORD/" "$GAME_SETTINGS_FILE"
    fi
    if [[ -n ${SERVER_STEAM_ACCOUNT_TOKEN+x} ]]; then
        e_with_counter "serverSteamAccount to '$SERVER_STEAM_ACCOUNT_TOKEN'"
        sed -E -i "s/^serverSteamAccount.*$/serverSteamAccount $SERVER_STEAM_ACCOUNT_TOKEN/" "$GAME_SETTINGS_FILE"
    fi
    if [[ -n ${SERVER_NAME+x} ]]; then
        e_with_counter "server name to '$SERVER_NAME'"
        sed -E -i "s/^serverName.*$/serverName $SERVER_NAME/" "$GAME_SETTINGS_FILE"
        if [[ "$SERVER_NAME" == *"###RANDOM###"* ]]; then
            RAND_VALUE=$RANDOM
            e "> Found standard template, using random numbers in server name"
            sed -E -i -e "s/###RANDOM###/$RAND_VALUE/g" "$GAME_SETTINGS_FILE"
            e "> Server name is now 'jammsen-docker-generated-$RAND_VALUE'"
        fi
    fi
    es ">>> Finished setting up server.cfg"
    cat "${GAME_SETTINGS_FILE}"
}

function setup_configs() {
    if [[ -n ${SERVER_SETTINGS_MODE} ]] && [[ ${SERVER_SETTINGS_MODE} == "auto" ]]; then
        ew ">>> SERVER_SETTINGS_MODE is set to '${SERVER_SETTINGS_MODE}', using environment variables to configure the server"
        setup_server_cfg
    else
        ew ">>> SERVER_SETTINGS_MODE is set to '${SERVER_SETTINGS_MODE}', NOT using environment variables to configure the server!"
        ew ">>> ALL SETTINGS have to be done manually by the user!"
    fi
}
