#!/bin/bash
# Boots an iPhone simulator, launches the game in demo mode on each screen and
# saves screenshots to ./screenshots. Usage: screenshots.sh path/to/KittyEscape.app
set -euo pipefail
APP="$1"
BUNDLE=com.example.kittyescape
OUT=screenshots
mkdir -p "$OUT"

UDID=$(xcrun simctl list devices available -j | python3 -c '
import json, sys
devices = json.load(sys.stdin)["devices"]
phones = [d for runtime, ds in devices.items() if "iOS" in runtime for d in ds if d["name"].startswith("iPhone")]
pro = [d for d in phones if "Pro Max" in d["name"]] or [d for d in phones if "Pro" in d["name"]] or phones
print(pro[-1]["udid"])')
echo "Using simulator $UDID"
xcrun simctl boot "$UDID" || true
xcrun simctl bootstatus "$UDID" -b
xcrun simctl install "$UDID" "$APP"

shoot() {
  local name=$1 wait=$2
  shift 2
  xcrun simctl terminate "$UDID" "$BUNDLE" 2>/dev/null || true
  xcrun simctl launch "$UDID" "$BUNDLE" "$@" >/dev/null
  sleep "$wait"
  xcrun simctl io "$UDID" screenshot "$OUT/$name.png" >/dev/null
  echo "Saved $name"
}

# Warm-up launch so the first real shot isn't slowed by first-launch work.
shoot warmup 8 -demo.screen home
rm -f "$OUT/warmup.png"

shoot 01-home 4 -demo.screen home -progress.level 12 -progress.coins 340 -collection.favorite 5
shoot 02-tutorial 3 -demo.screen game -progress.level 1
shoot 03-board 3 -demo.screen game -progress.level 12
shoot 04-combo 2.5 -demo.screen game -progress.level 12 -demo.autoTaps 7
shoot 05-sleepy 3 -demo.screen game -progress.level 6
shoot 06-hard 3 -demo.screen game -progress.level 20
shoot 07-won 9 -demo.screen game -progress.level 4 -demo.autoTaps 40
shoot 08-collection 3 -demo.screen collection -progress.level 25
shoot 09-daily 3 -demo.screen daily
shoot 10-settings 3 -demo.screen settings
