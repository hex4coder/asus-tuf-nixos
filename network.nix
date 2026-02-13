{...} : {
	networking = {
	  # Disable DHCP on all interfaces
	  useDHCP = false;
	  
	  # Configure specific interface (e.g., eth0 or enp0s18)
	  interfaces.eno1 = {
	    ipv4.addresses = [ {
	      address = "190.170.1.2"; # Desired Static IP
	      prefixLength = 16;         # Subnet mask /24 = 255.255.255.0
	    } ];
	  };


	  firewall.allowPing = true;

	  # Set default gateway
	  #defaultGateway = "192.168.1.1";
	  
	  # Set DNS servers
	  #nameservers = [ "1.1.1.1" "8.8.8.8" ];
	};
}
