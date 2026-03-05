{ pkgs }:
{
  # Nix will generate a workspace.kdl with this file, to support scratchpad (NIRI DOESNT HAVE SCRATCHPAD SUPPORT YET)
  workspaces = [
    "dev"
    "learn"
    "docs"
    "media"
    "play"
    "focus"
    "vm"
    "docker"
    "background"
  ];
}
