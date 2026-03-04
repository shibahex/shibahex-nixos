#!/bin/bash
SLOT=$1
ACTION=${2:-focus}
CURRENT=$(niri msg -j focused-output | jq -r '.name')

declare -A DP4=([9]=misc [8]=docs [7]=mail [6]=media [5]=chat [4]=files [3]=term [2]=dev [1]=web)
declare -A DP5=([9]=misc2 [8]=docs2 [7]=mail2 [6]=media2 [5]=chat2 [4]=files2 [3]=term2 [2]=dev2 [1]=web2)

if [ "$CURRENT" = "DP-4" ]; then
  WS="${DP4[$SLOT]}"
else
  WS="${DP5[$SLOT]}"
fi

if [ "$ACTION" = "move" ]; then
  niri msg action move-column-to-workspace "$WS"
else
  niri msg action focus-workspace "$WS"
fi
