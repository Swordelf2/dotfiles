#!/bin/bash

# Get a list of all sinks except ones with "hdmi" in their name
SINKS=($(pactl list short sinks | awk '!/hdmi/ {print $2}'))

# Get the current default sink
CURRENT=$(pactl get-default-sink)

# Find index of current sink in list
INDEX=-1
for i in "${!SINKS[@]}"; do
  if [[ "${SINKS[$i]}" == "$CURRENT" ]]; then
    INDEX=$i
    break
  fi
done

# If not found, default to first sink
if [[ $INDEX -eq -1 ]]; then
  INDEX=0
fi

# Compute next sink in the list (cycle)
NEXT_INDEX=$(((INDEX + 1) % ${#SINKS[@]}))
NEXT_SINK=${SINKS[$NEXT_INDEX]}

# Switch default sink
pactl set-default-sink "$NEXT_SINK"

# Move all active streams to the new sink
for INPUT in $(pactl list short sink-inputs | awk '{print $1}'); do
  pactl move-sink-input "$INPUT" "$NEXT_SINK"
done

echo "Switched audio output to: $NEXT_SINK"
