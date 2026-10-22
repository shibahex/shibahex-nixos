{ ... }:
{
  # Stylix regenerates ~/.gtkrc-2.0 on every rebuild; without force, home-manager
  # refuses to overwrite it once a stale backup already exists, aborting activation.
  gtk.gtk2.force = true;
}
