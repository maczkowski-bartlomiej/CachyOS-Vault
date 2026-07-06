#!/usr/bin/env sh

CONFIG="$HOME/.config/polybar/config.ini"
PRIMARY_MONITOR="${PRIMARY_MONITOR:-DP-0}"

killall -q polybar

wait_count=0
while pgrep -u "$UID" -x polybar >/dev/null; do
  sleep 0.2
  wait_count=$((wait_count + 1))
  if [ "$wait_count" -ge 50 ]; then
    echo "[WARN] Timed out waiting for existing Polybar processes to exit" >&2
    break
  fi
done

if command -v xrandr >/dev/null 2>&1; then
  MONITORS=$(xrandr --query | awk '/ connected/ {print $1}')

  if ! printf '%s\n' "$MONITORS" | grep -qx "$PRIMARY_MONITOR"; then
    PRIMARY_MONITOR=$(printf '%s\n' "$MONITORS" | head -n1)
  fi

  for m in $MONITORS; do
    if [ "$m" = "$PRIMARY_MONITOR" ]; then
      MONITOR="$m" polybar -c "$CONFIG" --reload main &
    else
      MONITOR="$m" polybar -c "$CONFIG" --reload secondary &
    fi
  done
else
  polybar -c "$CONFIG" --reload main &
fi
