{ pkgs }:
{
  # Nix will generate a workspace.kdl with this file, to support scratchpad (NIRI DOESNT HAVE SCRATCHPAD SUPPORT YET)
  workspaces = [
    "dev"
    "docs"
    "learn"
    "media"
    "play"
    "misc"
    "focus"
    "vm"
    "docker"
    "background"
  ];
}
