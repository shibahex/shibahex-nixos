{
  pkgs,
  lib,
  inputs,
  username,
  host,
  profile,
  stateVersion,
  self,
  ...
}:
let
  variables = import "${self}/hosts/${host}/variables.nix" { pkgs = pkgs; };
  defaultShell = variables.defaultShell or "zsh";
  shellPackage = if defaultShell == "nushell" then pkgs.nushell else pkgs.zsh;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # System-wide so their vendor completions get installed
  programs.zsh.enable = lib.mkDefault true;
  programs.fish.enable = lib.mkDefault true;

  home-manager = {
    useUserPackages = lib.mkDefault true;
    useGlobalPkgs = lib.mkDefault false;
    backupFileExtension = lib.mkDefault "backup";
    extraSpecialArgs = {
      inherit
        inputs
        username
        host
        profile
        self
        ;
    };
    users.${username} = {
      imports = [
        "${self}/modules/home-apps"
      ]
      ++ (
        let
          path = "${self}/hosts/${host}/home.nix";
        in
        if builtins.pathExists path then [ path ] else [ ]
      );

      home = {
        inherit username stateVersion;
        homeDirectory = "/home/${username}";
      };
    };
  };
  users.mutableUsers = lib.mkDefault true;
  users.users.${username} = {
    isNormalUser = true;
    description = lib.mkDefault username;
    extraGroups = [
      "docker"
      "libvirtd"
      "networkmanager"
      "kvm"
      "wheel"
      "input"
      "tty"
    ];
    shell = shellPackage;
    ignoreShellProgramCheck = true;
  };
  nix.settings.allowed-users = [ username ];
}
