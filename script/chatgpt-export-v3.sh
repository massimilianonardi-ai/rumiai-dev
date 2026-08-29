#!/bin/sh
#
# chatgpt-export.sh
#
# POSIX-sh launcher for chatgpt-export-v3.py on macOS.
#
# Flow:
#   1. Check whether ChatGPT is running.
#   2. If it is running, verify that its renderer is reachable through
#      Chrome DevTools Protocol on localhost:9222.
#   3. If ChatGPT is running without remote debugging, offer:
#        1) quit and relaunch with remote debugging
#        2) exit
#   4. If ChatGPT is not running, launch it directly with remote debugging.
#   5. Wait until the ChatGPT CDP renderer is ready.
#   6. Run chatgpt-export-v3.py from the same directory.
#
# Optional environment variables:
#   CHATGPT_DEBUG_PORT   CDP port (default: 9222)
#   CHATGPT_EXPORTER     absolute/path to chatgpt-export-v3.py
#
# Any command-line arguments are passed unchanged to chatgpt-export-v3.py.
#

set -u

PORT=${CHATGPT_DEBUG_PORT:-9222}

# Resolve this script's directory without relying on readlink -f.
case $0 in
    */*)
        SELF=$0
        ;;
    *)
        SELF=$(command -v "$0" 2>/dev/null || printf '%s\n' "$0")
        ;;
esac

SCRIPT_DIR=$(CDPATH= cd -P "$(dirname "$SELF")" 2>/dev/null && pwd)
if [ -z "${SCRIPT_DIR:-}" ]; then
    printf '%s\n' "Errore: impossibile determinare la cartella dello script." >&2
    exit 1
fi

EXPORTER=${CHATGPT_EXPORTER:-"$SCRIPT_DIR/chatgpt-export-v3.py"}

have_command()
{
    command -v "$1" >/dev/null 2>&1
}

chatgpt_running()
{
    ps -e -o command= 2>/dev/null |
        grep -F '/Applications/ChatGPT.app/Contents/MacOS/ChatGPT' |
        grep -v 'grep' >/dev/null 2>&1
}

#
# Return success only if the CDP endpoint belongs to a ChatGPT renderer,
# not merely if some unrelated process happens to listen on the port.
#
remote_debugging_ready()
{
    python3 - "$PORT" >/dev/null 2>&1 <<'PY'
import json
import sys
import urllib.request

port = int(sys.argv[1])

try:
    with urllib.request.urlopen(
        f"http://127.0.0.1:{port}/json/list",
        timeout=1.0
    ) as response:
        targets = json.load(response)
except Exception:
    raise SystemExit(1)

for target in targets:
    if target.get("type") != "page":
        continue

    url = str(target.get("url", ""))

    if (
        url == "app://-/index.html"
        or (
            url.startswith("app://-/index.html")
            and "avatar-overlay" not in url
        )
    ):
        raise SystemExit(0)

raise SystemExit(1)
PY
}

port_in_use()
{
    python3 - "$PORT" >/dev/null 2>&1 <<'PY'
import socket
import sys

port = int(sys.argv[1])
s = socket.socket()

try:
    s.settimeout(0.5)
    result = s.connect_ex(("127.0.0.1", port))
finally:
    s.close()

raise SystemExit(0 if result == 0 else 1)
PY
}

quit_chatgpt()
{
    printf '%s\n' "Chiudo ChatGPT..."

    osascript -e 'tell application "ChatGPT" to quit' >/dev/null 2>&1 || return 1

    # Wait until the main process has actually terminated.
    n=0
    while chatgpt_running; do
        n=$((n + 1))
        if [ "$n" -ge 30 ]; then
            printf '%s\n' \
                "Errore: ChatGPT non si è chiuso correttamente." >&2
            return 1
        fi
        sleep 1
    done

    return 0
}

launch_chatgpt()
{
    if port_in_use && ! remote_debugging_ready; then
        printf '%s\n' \
            "Errore: la porta 127.0.0.1:$PORT è già occupata da un altro processo." >&2
        return 1
    fi

    printf '%s\n' "Avvio ChatGPT con remote debugging sulla porta $PORT..."

    open -na "/Applications/ChatGPT.app" --args \
        "--remote-debugging-port=$PORT" >/dev/null 2>&1 || return 1

    return 0
}

wait_for_remote_debugging()
{
    n=0

    while ! remote_debugging_ready; do
        n=$((n + 1))

        if [ "$n" -ge 30 ]; then
            printf '%s\n' \
                "Errore: il renderer ChatGPT non è comparso su 127.0.0.1:$PORT." >&2
            return 1
        fi

        if ! chatgpt_running; then
            printf '%s\n' \
                "Errore: ChatGPT non risulta più in esecuzione." >&2
            return 1
        fi

        sleep 1
    done

    return 0
}

# ---------------------------------------------------------------------------
# Preconditions
# ---------------------------------------------------------------------------

if ! have_command python3; then
    printf '%s\n' "Errore: python3 non è disponibile." >&2
    exit 1
fi

if ! have_command open; then
    printf '%s\n' "Errore: comando 'open' non disponibile; questo launcher richiede macOS." >&2
    exit 1
fi

if ! have_command osascript; then
    printf '%s\n' "Errore: comando 'osascript' non disponibile; questo launcher richiede macOS." >&2
    exit 1
fi

if [ ! -f "$EXPORTER" ]; then
    printf '%s\n' "Errore: exporter Python non trovato:" >&2
    printf '  %s\n' "$EXPORTER" >&2
    printf '%s\n' \
        "Metti chatgpt-export-v3.py nella stessa cartella di questo script oppure imposta CHATGPT_EXPORTER." >&2
    exit 1
fi

# ---------------------------------------------------------------------------
# ChatGPT lifecycle / CDP state
# ---------------------------------------------------------------------------

if chatgpt_running; then
    printf '%s\n' "ChatGPT è in esecuzione."

    if remote_debugging_ready; then
        printf '%s\n' "Remote debugging già attivo sulla porta $PORT."
    else
        printf '%s\n' "Remote debugging non risulta attivo per ChatGPT."
        printf '\n'
        printf '%s\n' "1) Chiudi ChatGPT e riaprilo con remote debugging"
        printf '%s\n' "2) Esci"
        printf '\n'

        while :; do
            printf '%s' "Scelta [1/2]: "

            if ! IFS= read -r choice; then
                printf '\n%s\n' "Input terminato. Esco."
                exit 0
            fi

            case $choice in
                1)
                    if ! quit_chatgpt; then
                        exit 1
                    fi

                    if ! launch_chatgpt; then
                        printf '%s\n' "Errore durante l'avvio di ChatGPT." >&2
                        exit 1
                    fi
                    break
                    ;;
                2)
                    printf '%s\n' "Esco senza modificare ChatGPT."
                    exit 0
                    ;;
                *)
                    printf '%s\n' "Scelta non valida."
                    ;;
            esac
        done
    fi
else
    printf '%s\n' "ChatGPT non è in esecuzione."

    if ! launch_chatgpt; then
        printf '%s\n' "Errore durante l'avvio di ChatGPT." >&2
        exit 1
    fi
fi

if ! wait_for_remote_debugging; then
    exit 1
fi

printf '%s\n' "Renderer ChatGPT pronto."
printf '\n'

# ---------------------------------------------------------------------------
# Export destination
# ---------------------------------------------------------------------------

printf '%s\n' "Cartella di destinazione degli export."
printf '%s\n' "Lascia vuoto e premi Invio per usare la cartella di chatgpt-export-v3.py."
printf '%s' "Destinazione: "

if ! IFS= read -r DESTINATION; then
    printf '\n%s\n' "Input terminato. Esco." >&2
    exit 1
fi

printf '\n'
printf '%s\n' "Avvio l'exporter..."
printf '\n'

if [ -n "$DESTINATION" ]; then
    python3 "$EXPORTER" "$DESTINATION" --port "$PORT" "$@"
else
    python3 "$EXPORTER" --port "$PORT" "$@"
fi

EXPORT_STATUS=$?

# ---------------------------------------------------------------------------
# Ask whether to close ChatGPT after the exporter has terminated
# ---------------------------------------------------------------------------

printf '\n'

while :; do
    printf '%s' "Vuoi chiudere ChatGPT? [s/N]: "

    if ! IFS= read -r CLOSE_CHOICE; then
        printf '\n'
        break
    fi

    case $CLOSE_CHOICE in
        s|S|si|SI|Si|sI|y|Y|yes|YES|Yes)
            if chatgpt_running; then
                if quit_chatgpt; then
                    printf '%s\n' "ChatGPT chiuso."
                else
                    printf '%s\n' "Errore durante la chiusura di ChatGPT." >&2
                fi
            else
                printf '%s\n' "ChatGPT non è più in esecuzione."
            fi
            break
            ;;
        ""|n|N|no|NO|No)
            printf '%s\n' "ChatGPT resta aperto."
            break
            ;;
        *)
            printf '%s\n' "Rispondi s oppure n."
            ;;
    esac
done

exit "$EXPORT_STATUS"
