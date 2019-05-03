# Creación del equilibrador de carga de Azure
# https://docs.microsoft.com/es-es/azure/virtual-machines/windows/tutorial-load-balancer

$1ResourceGroupName = "03-WebEmpresa"
$1Location = "EastUS"
$1vmName = "WebEmpresa"
$1ImageName = "MicrosoftWindowsServer:WindowsServer:2016-Datacenter-Server-Core:latest"
$1VirtualNetworkName = "WebVNET"
$1SubnetName = "WebSubVNET"
$1PublicIpAddressName = "WebPublicIP"
$1Size = "Standard_B1s"


New-AzResourceGroup `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location

# Crear una dirección IP pública
Write-Host "Creacion de IP Publica" -ForegroundColor DarkGreen -BackgroundColor Black

$1publicIP = New-AzPublicIpAddress `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location `
  -AllocationMethod "Static" `
  -Name "WebEmpresaIP"

# Creación de un grupo de direcciones IP de front-end
Write-Host "Pool de direccioes IP Front-End" -ForegroundColor DarkGreen -BackgroundColor Black

$1frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name "WebFrontEndPool" `
  -PublicIpAddress $1publicIP

# Creación de un grupo de direcciones de back-end
Write-Host "Pool de direcciones IP Back-End" -ForegroundColor DarkGreen -BackgroundColor Black

$1backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name "WebBackEndPool"

# Creación del balanceador de carga
Write-Host "Creacion balanceador de carga" -ForegroundColor DarkGreen -BackgroundColor Black

$1lb = New-AzLoadBalancer `
  -ResourceGroupName $1ResourceGroupName `
  -Name "WebEmpresaLB" `
  -Location $1Location `
  -FrontendIpConfiguration $1frontendIP `
  -BackendAddressPool $1backendPool

# Creación de un sondeo de estado
Write-Host "Creacion de sonda de estado" -ForegroundColor DarkGreen -BackgroundColor Black

Add-AzLoadBalancerProbeConfig `
  -Name "Hubble" `
  -LoadBalancer $1lb `
  -Protocol tcp `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 3

# Aplicamos el sondeo de estado

Set-AzLoadBalancer -LoadBalancer $1lb

# Creación de una regla de equilibrador de carga
Write-Host "Creacion regla de balanceo de carga" -ForegroundColor DarkGreen -BackgroundColor Black

$1probe = Get-AzLoadBalancerProbeConfig -LoadBalancer $1lb -Name "Hubble"

Add-AzLoadBalancerRuleConfig `
  -Name "WebEmpresaLB" `
  -LoadBalancer $1lb `
  -FrontendIpConfiguration $1lb.FrontendIpConfigurations[0] `
  -BackendAddressPool $1lb.BackendAddressPools[0] `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $1probe

# Actualizamos el equilibrador de carga

Set-AzLoadBalancer -LoadBalancer $1lb

# Creamos los recursos de red
Write-Host "Creacion de los recursos de red" -ForegroundColor DarkGreen -BackgroundColor Black

# Creamos la configuración de la subNet

$1subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name $1SubnetName `
  -AddressPrefix 192.168.1.0/24

# Creamos la Red Virtual

$1vnet = New-AzVirtualNetwork `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location `
  -Name $1VirtualNetworkName `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $1subnetConfig

# Creación de NIC virtuales

for ($i=1; $i -le 2; $i++)
{
   New-AzNetworkInterface `
     -ResourceGroupName $1ResourceGroupName `
     -Name "$1vmName$i" `
     -Location $1Location `
     -Subnet $1vnet.Subnets[0] `
     -LoadBalancerBackendAddressPool $1lb.BackendAddressPools[0]
}

# Creación de AzAvailabilitySet
Write-Host "Creacion de AzAvailabilitySet" -ForegroundColor DarkGreen -BackgroundColor Black

$1availabilitySet = New-AzAvailabilitySet `
  -ResourceGroupName $1ResourceGroupName `
  -Name "WebEmpresaAS" `
  -Location $1Location `
  -Sku aligned `
  -PlatformFaultDomainCount 2 `
  -PlatformUpdateDomainCount 2

# Introducimos credenciales

$1cred = Get-Credential

for ($i=1; $i -le 2; $i++)
  {
    # Crea la máquina virtual

    Write-Host "Instalacion VM iniciandose" -ForegroundColor DarkGreen -BackgroundColor Black

    $2vmName = $1vmName + $i
    $2VirtualNetworkName = $1VirtualNetworkName + $i
    $2SubnetName = $1SubnetName + $i
    $2PublicIpAddressName = $1PublicIpAddressName + $i

    New-AzVM `
      -ResourceGroupName $1ResourceGroupName `
      -Name $2vmName `
      -Location $1location `
      -ImageName $1ImageName `
      -VirtualNetworkName $2VirtualNetworkName `
      -SubnetName $2SubnetName `
      -AvailabilitySetName "WebEmpresaAS" `
      -Credential $1cred `
      -Size $1Size `
      -OpenPorts 80

    Write-Host "Instalacion VM finalizada" -ForegroundColor DarkGreen -BackgroundColor Black

    # Instalación IIS

    Write-Host "Instalacion Servidor IIS iniciandose" -ForegroundColor DarkGreen -BackgroundColor Black

    $1PublicSettings = '{"ModulesURL":"https://github.com/lilwhite/Proyecto-MAT/raw/master/Ejercicio-2/WebEmpresa.ps1.zip", "configurationFunction": "WebEmpresa.ps1\\WebEmpresa", "Properties": {"MachineName": '+'"'+$2vmName+'"'+'} }'

    Set-AzVMExtension `
      -ExtensionName "DSC" `
      -ResourceGroupName $1ResourceGroupName `
      -VMName $2vmName `
      -Publisher "Microsoft.Powershell" `
      -ExtensionType "DSC" `
      -TypeHandlerVersion 2.7 `
      -SettingString $1PublicSettings `
      -Location $1Location

    Write-Host "Instalacion Servidor IIS completada" -ForegroundColor DarkGreen -BackgroundColor Black
  }
