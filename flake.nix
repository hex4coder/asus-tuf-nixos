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
  };

  outputs = { self, nixpkgs, gns3-gui-src, gns3-server-src, ... } @ inputs: {
	nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = { inherit gns3-gui-src gns3-server-src inputs; };
		modules = [
			./configuration.nix
			inputs.nixos-hardware.nixosModules.asus-fa506ic
		];
	};
  };
}
