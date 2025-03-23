#!/bin/bash
TOR_PATH="/usr/bin/tor"
TORRC_PATH="/etc/tor/torrc"

start_tor() {
    if pgrep -x "tor" > /dev/null; then
        zenity --info --text="Tor уже запущен."
    else
        $TOR_PATH &
        zenity --info --text="Tor запущен."
    fi
}

stop_tor() {
    if pgrep -x "tor" > /dev/null; then
        killall tor
        zenity --info --text="Tor остановлен."
    else
        zenity --info --text="Tor не запущен."
    fi
}

change_ip() {
    if pgrep -x "tor" > /dev/null; then
        echo "SIGNAL NEWNYM" | nc localhost 9051
        zenity --info --text="IP адрес Tor был изменен."
    else
        zenity --info --text="Tor не запущен."
    fi
}

add_bridge() {
    bridge_type=$(zenity --list --title="Выбор типа моста" --text="Выберите тип моста:" --radiolist --column="Выбор" --column="Тип" TRUE "Обычный" FALSE "Meek" FALSE "Snowflake")

    if [ "$bridge_type" = "Обычный" ]; then
        bridge=$(zenity --entry --title="Добавить обычный мост" --text="Введите обычный мост (вводите только 1 мост за раз, поддерживаемые мосты: obfs4, webtunnel):")
        
        if [ -n "$bridge" ]; then
            echo "UseBridges 1" >> "$TORRC_PATH"
            echo "Bridge $bridge" >> "$TORRC_PATH"
            zenity --info --text="Обычный мост добавлен."
        else
            zenity --error --text="Вы не ввели мост."
        fi

    elif [ "$bridge_type" = "Meek" ]; then
        meek_bridge=$(zenity --list --title="Выбор meek моста" --text="Выберите meek мост:" --column="Мосты" --width=600 --height=400 "meek 0.0.2.0:2 B9E7141C594AF25699E0079C1F0146F409495296 url=https://d2cly7j4zqgua7.cloudfront.net/ front=a0.awsstatic.com" "meek 0.0.2.0:3 97700DFE9F483596DDA6264C4D7DF7641E1E39CE url=https://meek.azureedge.net/ front=ajax.aspnetcdn.com" "meek.anotherexample.com:443")
        
        if [ -n "$meek_bridge" ]; then
            echo "UseBridges 1" >> "$TORRC_PATH"
            echo "Bridge $meek_bridge" >> "$TORRC_PATH"
            zenity --info --text="Meek мост добавлен."
        else
            zenity --error --text="Вы не выбрали meek мост."
        fi

    elif [ "$bridge_type" = "Snowflake" ]; then
        snowflake_bridge=$(zenity --list --title="Выбор snowflake моста" --text="Выберите snowflake мост:" --column="Мосты" --width=600 --height=400 "Snoflake | ClientTransportPlugin snowflake exec /usr/bin/snowflake-client -url https://snowflake-broker.torproject.net/ -ampcache https://cdn.ampproject.org/ -front www.google.com -ice stun:stun.l.google.com:19302,stun:stun.antisip.com:3478,stun:stun.bluesip.net:3478,stun:stun.dus.net:3478,stun:stun.epygi.com:3478,stun:stun.sonetel.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.voys.nl:3478 utls-imitate=hellorandomizedalpn -log /var/log/tor/snowflake-client.log")
    
        if [ -n "$snowflake_bridge" ]; then
            bridge_value=$(echo "$snowflake_bridge" | awk -F'|' '{print $2}' | xargs)
    
            echo "UseBridges 1" >> $TORRC_PATH
            echo "$bridge_value" >> $TORRC_PATH
            echo "Bridge snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72" >> $TORRC_PATH
            zenity --info --text="Snowflake мост добавлен."
        else
            zenity --error --text="Вы не выбрали snowflake мост."
        fi
    
    else
        zenity --error --text="Не выбран тип моста."
    fi
}

remove_all_bridges() {
    if grep -q "Bridge" "$TORRC_PATH" || grep -q "UseBridges 1" "$TORRC_PATH"; then
        sed -i '/^Bridge/d; /^UseBridges 1/d' "$TORRC_PATH"
        zenity --info --text="Все мосты и настройка UseBridges удалены из torrc."
    else
        zenity --info --text="В torrc нет подключенных мостов."
    fi
}
# Главное меню
while true; do
    action=$(zenity --list --title="Менеджер Tor" --column="Действие" "Запустить Tor" "Запустить DNSCrypt over Tor(запускать после запуска Tor)"  "Остановить Tor" "Добавить мост" "Удалить все мосты" "Выход")
	# "Сменить IP"
    if [ $? -ne 0 ]; then
        break
    fi

    case $action in
        "Запустить Tor") start_tor ;;
        "Остановить Tor") stop_tor ;;
        "Запустить DNSCrypt over Tor(запускать после запуска Tor)") sudo rc-service dnscrypt-proxy start ;;
        "Сменить IP") change_ip ;;
        "Добавить мост") add_bridge ;;
        "Удалить все мосты") remove_all_bridges ;;
        "Выход") break ;;
        *) zenity --error --text=":3" ;;
    esac
done
