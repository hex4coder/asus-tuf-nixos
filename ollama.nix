{pkgs, ...} : {

	services.ollama = {
		enable = true;
		host = "0.0.0.0";
		port = 11434;
		openFirewall = true;
		package = pkgs.ollama-cuda;
	};


	environment.systemPackages = [
		pkgs.ollama
	];


	# add web ui support
	services.open-webui.enable = true;
}
