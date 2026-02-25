#!/bin/bash

CARD=$(cat /proc/asound/cards | grep sof-hda-dsp | head -n1 | awk '{print $1}')

if [ -z "$CARD" ]; then
  echo "Sound card not found"
  exit 1
fi

handle_event() {
  if amixer -c"$CARD" get Headphone | grep -q "off"; then
    # Speaker
    hda-verb /dev/snd/hwC0D0 0x16 0x701 0x0001
    hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0002
  else
    # Headphone
    hda-verb /dev/snd/hwC0D0 0x16 0x701 0x0000
    hda-verb /dev/snd/hwC0D0 0x17 0x70C 0x0000
  fi
}

udevadm monitor --subsystem-match=sound | while read line; do
  handle_event
done
