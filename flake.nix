{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

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
  };

  outputs = { self, nixpkgs, ... } @ inputs: {
	nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
		system = "x86_64-linux";
		specialArgs = { inherit inputs; };
		modules = [
			./configuration.nix

		];
	};
  };
}
