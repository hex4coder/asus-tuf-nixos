{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    nixos-hardware = {
	url = "github:NixOS/nixos-hardware/master";
    };

    dms = {
	url = "github:AvengeMedia/DankMaterialShell/stable";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    niri = {
	url = "github:sodiboo/niri-flake";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    dgop = {
	url = "github:AvengeMedia/dgop";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    dms-plugin-registry = {
	url = "github:AvengeMedia/dms-plugin-registry";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    gns3-server-src = {
	url = "github:GNS3/gns3-server/master"; 
	flake = false;
    };
    gns3-gui-src = {
	url = "github:GNS3/gns3-gui/master"; 
	flake = false;
    };

    home-manager = {
	url = "github:nix-community/home-manager";
	inputs.nixpkgs.follows = "nixpkgs";
    };

    browseros = {
	url = "github:Hill-Brandon-M/browseros-ai";
	inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, gns3-gui-src, gns3-server-src, ... } @ inputs: {
	nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = { inherit gns3-gui-src gns3-server-src inputs; };
		modules = [
			./configuration.nix
			home-manager.nixosModules.home-manager
			{
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.backupFileExtension = "backup";
				home-manager.users.kaco = import ./home.nix;
				home-manager.extraSpecialArgs = { inherit inputs; };
			}
		];
	};
  };
}
