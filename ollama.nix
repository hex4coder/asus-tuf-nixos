{pkgs, ...} : {

	services.ollama = {
		enable = true;
		openFirewall = true;
		package = pkgs.ollama-cuda;
	};


	environment.systemPackages = [
		pkgs.ollama
	];
}
