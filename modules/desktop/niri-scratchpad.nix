{
  pkgs,
  lib,
  variables,
  workspace-file,
}:
let
  ws = workspace-file.workspaces;
  mainMon = variables.mainMonitor;
  sideRight = variables.sideMonitorRight;
  sideLeft = variables.sideMonitorLeft;

  mkWorkspaces =
    names: output:
    lib.concatMapStrings (name: ''workspace "${name}" { open-on-output "${output}"; }'' + "\n") names;

  sideRightWs = if sideRight != null then map (n: n + "2") ws else [ ];
  sideLeftWs = if sideLeft != null then map (n: n + "3") ws else [ ];

  mkBashArray = names: "(" + lib.concatImapStrings (i: n: "[${toString i}]=${n} ") names + ")";

  workspacesKdl = pkgs.writeText "workspaces.kdl" ''
    workspace "scratch"

    // Main monitor
    ${mkWorkspaces ws mainMon}
    ${lib.optionalString (
      sideRight != null
    ) "// Side right monitor\n${mkWorkspaces sideRightWs sideRight}"}
    ${lib.optionalString (sideLeft != null) "// Side left monitor\n${mkWorkspaces sideLeftWs sideLeft}"}

    binds {
        Mod+9 { spawn "workspace-per-monitor" "9" "focus"; }
        Mod+8 { spawn "workspace-per-monitor" "8" "focus"; }
        Mod+7 { spawn "workspace-per-monitor" "7" "focus"; }
        Mod+6 { spawn "workspace-per-monitor" "6" "focus"; }
        Mod+5 { spawn "workspace-per-monitor" "5" "focus"; }
        Mod+4 { spawn "workspace-per-monitor" "4" "focus"; }
        Mod+3 { spawn "workspace-per-monitor" "3" "focus"; }
        Mod+2 { spawn "workspace-per-monitor" "2" "focus"; }
        Mod+1 { spawn "workspace-per-monitor" "1" "focus"; }
        Mod+Shift+9 { spawn "workspace-per-monitor" "9" "move"; }
        Mod+Shift+8 { spawn "workspace-per-monitor" "8" "move"; }
        Mod+Shift+7 { spawn "workspace-per-monitor" "7" "move"; }
        Mod+Shift+6 { spawn "workspace-per-monitor" "6" "move"; }
        Mod+Shift+5 { spawn "workspace-per-monitor" "5" "move"; }
        Mod+Shift+4 { spawn "workspace-per-monitor" "4" "move"; }
        Mod+Shift+3 { spawn "workspace-per-monitor" "3" "move"; }
        Mod+Shift+2 { spawn "workspace-per-monitor" "2" "move"; }
        Mod+Shift+1 { spawn "workspace-per-monitor" "1" "move"; }
    }
  '';

  script = pkgs.writeShellScriptBin "workspace-per-monitor" ''
    SLOT=$1
    ACTION=''${2:-focus}
    CURRENT=$(niri msg -j focused-output | grep -oP '"name":"\K[^"]*')
    declare -A MAIN=${mkBashArray ws}
    declare -A SIDE=${mkBashArray sideRightWs}
    declare -A SIDELEFT=${mkBashArray sideLeftWs}

    MAIN_MON="${mainMon}"
    SIDE_RIGHT="${if sideRight != null then sideRight else ""}"
    SIDE_LEFT="${if sideLeft != null then sideLeft else ""}"

    if [ "$CURRENT" = "$MAIN_MON" ]; then
      WS="''${MAIN[$SLOT]}"
    elif [ -n "$SIDE_RIGHT" ] && [ "$CURRENT" = "$SIDE_RIGHT" ]; then
      WS="''${SIDE[$SLOT]}"
    elif [ -n "$SIDE_LEFT" ] && [ "$CURRENT" = "$SIDE_LEFT" ]; then
      WS="''${SIDELEFT[$SLOT]}"
    else
      WS="''${MAIN[$SLOT]}"
    fi

    if [ "$ACTION" = "move" ]; then niri msg action move-column-to-workspace "$WS"
    else niri msg action focus-workspace "$WS"; fi
  '';
in
{
  inherit workspacesKdl script;
}
