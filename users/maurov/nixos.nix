{ pkgs, inputs, ... }:

{

  # Add ~/.local/bin to PATH
  environment.localBinInPath = true;

  programs.zsh.enable = true;
  systemd.services.NetworkManager-wait-online.enable = false;

  programs.ssh.startAgent = true;

  users.users.maurov = {
    isNormalUser = true;
    home = "/home/maurov";
    extraGroups = [ "docker" "wheel" ];
    shell = pkgs.zsh;
    # you can generate the password with mkpasswd
    hashedPassword = "$y$j9T$OrNpLHUrPbAEq6CZOZqw./$zsEhRmNvjJF0JXGtpFirjp6A4abn8AnDXna9GyjQRf.";
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOwtpJV18Jy3Cbwyc1r7IhVKXs3NVnwTBfXxFJlkqh6p maurov"
    ];
  };

  #nixpkgs.overlays = import ../../lib/overlays.nix ++ [
  #  (import ./vim.nix { inherit inputs; })
  #];
}

