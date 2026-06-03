{ pkgs
, inputs
, username
, host
, profile
, stateVersion
, self
, ...
}:
let
  variables = import "${self}/hosts/${host}/variables.nix" { pkgs = pkgs; };
  defaultShell = variables.defaultShell or "zsh";
  shellPackage = if defaultShell == "nushell" then pkgs.nushell else pkgs.zsh;
in
{
  imports = [ inputs.home-manager.nixosModules.home-manager ];

  # Enable fish and Zsh system-wide for vendor completions
  programs.zsh.enable = true;
  programs.fish.enable = true;

  home-manager = {
    useUserPackages = true;
    useGlobalPkgs = false;
    backupFileExtension = "backup";
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
        username = "${username}";
        homeDirectory = "/home/${username}";
        stateVersion = "${stateVersion}";
      };
    };
  };
  users.mutableUsers = true;
  users.users.${username} = {
    isNormalUser = true;
    description = "${username}";
    extraGroups = [
      "docker"
      "libvirtd" # For VirtManager
      "networkmanager"
      "kvm" # for gpu passthrough
      "wheel" # sudo access
      "input"
    ];
    # Use configured shell based on defaultShell variable
    shell = shellPackage;
    ignoreShellProgramCheck = true;
  };
  nix.settings.allowed-users = [ "${username}" ];
}
