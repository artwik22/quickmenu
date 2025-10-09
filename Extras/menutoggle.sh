#!/bin/bash

PIDFILE="$HOME/.cache/quickshell.pid"
CONFIG_PATH="$HOME/.config/quickshell/shell.qml"

# Sprawdź, czy plik PID istnieje i czy proces nadal działa
if [ -f "$PIDFILE" ]; then
    PID=$(cat "$PIDFILE")
    if kill -0 "$PID" 2>/dev/null; then
        # Proces działa – zabij go
        kill "$PID"
        rm -f "$PIDFILE"
        exit 0
    else
        # Proces już nie działa – wyczyść śmieci
        rm -f "$PIDFILE"
    fi
fi

# Uruchom quickshell z odpowiednią zmienną środowiskową i zapisz PID
QML_XHR_ALLOW_FILE_READ=1 quickshell --path "$CONFIG_PATH" &
echo $! > "$PIDFILE"
