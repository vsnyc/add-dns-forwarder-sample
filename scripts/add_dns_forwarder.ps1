# Get the VPCCIDR from the command line parameters
$cidr = $args[3]

# Generate the VPC DNS IP address
$cidr = $cidr.Split(".")
$newdns = $cidr[0] + "." + $cidr[1] + "." + $cidr[2] + "." + "2"

# Get the names of the domain controllers
$dc1 = Get-ADDomainController -Discover -Service PrimaryDC
$dc2 = Get-ADDomainController -Discover

# Get the domain name, admin user name and password from the command line arguments
$domain = $args[0]
$username = $args[1]
$password = $args[2]

# Generate the domain login credentials
$wmiDomain = Get-WmiObject Win32_NTDomain -Filter "DnsForestName = `"$domain`""
$credential = New-Object System.Management.Automation.PSCredential `
		-ArgumentList "$($wmiDomain.DomainName)\$username", (ConvertTo-SecureString "$password" -AsPlainText -Force);

# Update the DNS forwarders on both domain controllers
Start-Process powershell.exe -Credential $credential -ArgumentList ("-Command Add-DnsServerForwarder -IPAddress $newdns -PassThru -ComputerName $dc1")
Start-Process powershell.exe -Credential $credential -ArgumentList ("-Command Add-DnsServerForwarder -IPAddress $newdns -PassThru -ComputerName $dc2")