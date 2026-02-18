{pkgs, ...} : {

	services.ollama = {
		enable = true;
		openFirewall = true;
		package = pkgs.ollama-cuda;
	};


	environment.systemPackages = [
		pkgs.ollama
	];


	# add web ui support
	services.open-webui.enable = true;
}
