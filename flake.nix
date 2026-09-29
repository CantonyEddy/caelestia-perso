{
  # caelestia-perso — intégration Home Manager (OPTIONNELLE).
  # Sans Nix, rien ne change : ./install.sh reste la méthode standard.
  # Avec Nix : Home Manager fournit caelestia-shell + CLI (flake upstream) et pose
  # les symlinks de l'override ; ./install.sh ne fait alors plus que la partie
  # système (/etc : keyd, SDDM) + dépendances pacman/AUR.
  #
  #   home-manager switch --flake ~/.local/share/caelestia-perso#<user>@<host>
  description = "caelestia-perso — overrides Caelestia via Home Manager (Arch + Nix)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    caelestia-shell = {
      url = "github:caelestia-dots/shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, caelestia-shell, ... }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Une config par machine : module commun + module hôte (écrans, etc.)
      mkHome = { user ? "ryu", host }: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit caelestia-shell user; };
        modules = [ ./nix/home.nix (./nix/hosts + "/${host}.nix") ];
      };
    in {
      homeConfigurations = {
        # "<utilisateur>@<machine>" : l'utilisateur Linux diffère selon la machine
        "jin@fixe"      = mkHome { user = "jin"; host = "fixe"; };
        "ryu@framework" = mkHome { user = "ryu"; host = "framework"; };
      };
    };
}
