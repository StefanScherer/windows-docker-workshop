# Specify the provider and access details
provider "aws" {
  region = "${var.aws_region}"
}

# Our default security group to access
resource "aws_security_group" "default" {
  name = "windows"

  # WinRM access from anywhere
  ingress {
    from_port = 5985
    to_port = 5985
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Docker TLS access from anywhere
  ingress {
    from_port = 2376
    to_port = 2376
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP access from anywhere
  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # RDP access from anywhere
  ingress {
    from_port = 3389
    to_port = 3389
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # outbound internet access
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "windows" {
  # The connection block tells our provisioner how to
  # communicate with the resource (instance)
  connection {
    type = "winrm"
    user = "Administrator"
    password = "${var.admin_password}"
  }

  instance_type = "t2.micro"

  # Lookup the correct AMI based on the region
  # we specified
  ami = "${lookup(var.aws_amis, var.aws_region)}"

  # The name of our SSH keypair you've created and downloaded
  # from the AWS console.
  #
  # https://console.aws.amazon.com/ec2/v2/home?region=us-west-2#KeyPairs:
  #
  key_name = "${var.key_name}"

  # Our Security group to allow WinRM access
  security_groups = ["${aws_security_group.default.name}"]

  user_data = <<EOF
<script>
  winrm quickconfig -q & winrm set winrm/config/winrs @{MaxMemoryPerShellMB="300"} & winrm set winrm/config @{MaxTimeoutms="1800000"} & winrm set winrm/config/service @{AllowUnencrypted="true"} & winrm set winrm/config/service/auth @{Basic="true"}
</script>
<powershell>
Start-Transcript -Path C:\provision.log

$ProgressPreference = 'SilentlyContinue'

Write-Host Set Password
netsh advfirewall firewall add rule name="WinRM in" protocol=TCP dir=in profile=any localport=5985 remoteip=any localip=any action=allow
$admin = [adsi]("WinNT://./administrator, user")
$admin.psbase.invoke("SetPassword", "${var.admin_password}")

Write-Host Enable Remote Desktop
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -name "fDenyTSConnections" -Value 0
Enable-NetFirewallRule -DisplayGroup "Remote Desktop"
set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -name "UserAuthentication" -Value 0

Write-Host Disable Windows Defender
Set-MpPreference -DisableRealtimeMonitoring $true

$PublicIPAddress = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/public-ipv4
$HostName = invoke-restmethod -uri http://169.254.169.254/latest/meta-data/public-hostname

Write-Host "HostName = $($HostName)"
Write-Host "PublicIPAddress = $($PublicIPAddress)"
Write-Host "USERPROFILE = $($env:USERPROFILE)"
Write-Host "pwd = $($pwd)"

Write-Host Windows Updates to manual
Cscript $env:WinDir\System32\SCregEdit.wsf /AU 1
Net stop wuauserv
Net start wuauserv

Write-Host Install Docker EE 17-03-0-ee
Stop-Service docker
wget -outfile $env:TEMP\docker-17-03-0-ee.zip "https://dockermsft.blob.core.windows.net/dockercontainer/docker-17-03-0-ee.zip"
Expand-Archive -Path $env:TEMP\docker-17-03-0-ee.zip -DestinationPath $env:ProgramFiles -Force
Remove-Item $env:TEMP\docker-17-03-0-ee.zip

Write-Host Activate experimental features
$daemonJson = "$env:ProgramData\docker\config\daemon.json"
$config = @{}
if (Test-Path $daemonJson) {
  $config = (Get-Content $daemonJson) -join "`n" | ConvertFrom-Json
}
$config = $config | Add-Member(@{ experimental = $true }) -Force -PassThru
$config | ConvertTo-Json | Set-Content $daemonJson -Encoding Ascii
Start-Service docker

$ips = ((Get-NetIPAddress -AddressFamily IPv4).IPAddress) -Join ','
Write-Host "Creating certs for $ips,$PublicIPAddress"
if (!(Test-Path $env:USERPROFILE\.docker)) {
  mkdir $env:USERPROFILE\.docker
}
docker run --rm `
  -e SERVER_NAME=$(hostname) `
  -e IP_ADDRESSES=$ips,$PublicIPAddress `
  -v "C:\ProgramData\docker:C:\ProgramData\docker" `
  -v "$env:USERPROFILE\.docker:C:\Users\ContainerAdministrator\.docker" `
  stefanscherer/dockertls-windows
restart-service docker

</powershell>
EOF
}
