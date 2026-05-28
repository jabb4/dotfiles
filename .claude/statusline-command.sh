#!/usr/bin/env bash
# Catppuccin Mocha palette
TEAL=$'\033[38;2;148;226;213m'
MAUVE=$'\033[38;2;203;166;247m'
SUBTEXT=$'\033[38;2;166;173;200m'
YELLOW=$'\033[38;2;249;226;175m'
RED=$'\033[38;2;243;139;168m'
RESET=$'\033[0m'

BAR_WIDTH=8
SEP=" ${SUBTEXT}|${RESET} "

pct_color() {
  local pct=$1
  if [ "$pct" -ge 90 ]; then echo "$RED"
  elif [ "$pct" -ge 75 ]; then echo "$YELLOW"
  else echo "$SUBTEXT"
  fi
}

make_bar() {
  local pct=$1
  local filled=$((pct * BAR_WIDTH / 100))
  [ "$filled" -gt "$BAR_WIDTH" ] && filled=$BAR_WIDTH
  [ "$filled" -lt 0 ] && filled=0
  local empty=$((BAR_WIDTH - filled))
  local i bar=""
  for ((i=0; i<filled; i++)); do bar+="#"; done
  for ((i=0; i<empty; i++)); do bar+="-"; done
  printf '[%s]' "$bar"
}

format_delta() {
  local target=$1 now delta d h m
  now=$(date +%s)
  delta=$((target - now))
  [ "$delta" -lt 0 ] && delta=0
  d=$((delta / 86400))
  h=$(((delta % 86400) / 3600))
  m=$(((delta % 3600) / 60))
  if [ "$d" -gt 0 ]; then printf '%dd %dh' "$d" "$h"
  elif [ "$h" -gt 0 ]; then printf '%dh %dm' "$h" "$m"
  else printf '%dm' "$m"
  fi
}

chip() {
  local label=$1 value=$2 resets_at=$3
  [ -z "$value" ] && return
  local pct color
  pct=$(printf '%.0f' "$value")
  color=$(pct_color "$pct")
  printf '%s%s %s %s%%%s' "$color" "$label" "$(make_bar "$pct")" "$pct" "$RESET"
  [ -n "$resets_at" ] && printf ' %sin %s%s' "$SUBTEXT" "$(format_delta "$resets_at")" "$RESET"
}

input=$(cat)
model=$(echo "$input" | jq -r '.model.display_name // ""')
effort=$(echo "$input" | jq -r '.effort.level // empty')
thinking=$(echo "$input" | jq -r '.thinking.enabled // false')
ctx=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
five_hour=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
five_hour_reset=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
weekly=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
weekly_reset=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

variant=""
if [ -n "$effort" ]; then variant="$effort"
elif [ "$thinking" = "true" ]; then variant="think"
fi

parts=()
if [ -n "$model" ]; then
  if [ -n "$variant" ]; then
    parts+=("$(printf '%s%s%s %s%s%s' "$TEAL" "$model" "$RESET" "$MAUVE" "$variant" "$RESET")")
  else
    parts+=("$(printf '%s%s%s' "$TEAL" "$model" "$RESET")")
  fi
fi
[ -n "$ctx" ] && parts+=("$(chip Context "$ctx" "")")
[ -n "$five_hour" ] && parts+=("$(chip 5h "$five_hour" "$five_hour_reset")")
[ -n "$weekly" ] && parts+=("$(chip Weekly "$weekly" "$weekly_reset")")

out=""
for i in "${!parts[@]}"; do
  [ "$i" -gt 0 ] && out+="$SEP"
  out+="${parts[$i]}"
done
printf '%s\n' "$out"
