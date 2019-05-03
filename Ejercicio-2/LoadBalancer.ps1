# Creación del equilibrador de carga de Azure
# https://docs.microsoft.com/es-es/azure/virtual-machines/windows/tutorial-load-balancer

New-AzResourceGroup `
  -ResourceGroupName "myResourceGroupLoadBalancer" `
  -Location "EastUS"

# Crear una dirección IP pública

$publicIP = New-AzPublicIpAddress `
  -ResourceGroupName "myResourceGroupLoadBalancer" `
  -Location "EastUS" `
  -AllocationMethod "Static" `
  -Name "myPublicIP"

# Creación de un grupo de direcciones IP de front-end

$frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name "myFrontEndPool" `
  -PublicIpAddress $publicIP

# Creación de un grupo de direcciones de back-end

$backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name "myBackEndPool"

# Creación del equilibrador de carga

$lb = New-AzLoadBalancer `
  -ResourceGroupName "myResourceGroupLoadBalancer" `
  -Name "myLoadBalancer" `
  -Location "EastUS" `
  -FrontendIpConfiguration $frontendIP `
  -BackendAddressPool $backendPool

# Creación de un sondeo de estado

Add-AzLoadBalancerProbeConfig `
  -Name "myHealthProbe" `
  -LoadBalancer $lb `
  -Protocol tcp `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 2

# Aplicamos el sondeo de estado

Set-AzLoadBalancer -LoadBalancer $lb

# Creación de una regla de equilibrador de carga

$probe = Get-AzLoadBalancerProbeConfig -LoadBalancer $lb -Name "myHealthProbe"

Add-AzLoadBalancerRuleConfig `
  -Name "myLoadBalancerRule" `
  -LoadBalancer $lb `
  -FrontendIpConfiguration $lb.FrontendIpConfigurations[0] `
  -BackendAddressPool $lb.BackendAddressPools[0] `
  -Protocol Tcp `
  -FrontendPort 80 `
  -BackendPort 80 `
  -Probe $probe

# Actualizamos el equilibrador de carga

Set-AzLoadBalancer -LoadBalancer $lb

# Creamos los recursos de red

# Creamos la configuración de la subNet

$subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name "mySubnet" `
  -AddressPrefix 192.168.1.0/24

# Creamos la Red Virtual

$vnet = New-AzVirtualNetwork `
  -ResourceGroupName "myResourceGroupLoadBalancer" `
  -Location "EastUS" `
  -Name "myVnet" `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $subnetConfig

# Creación de NIC virtuales

for ($i=1; $i -le 2; $i++)
{
   New-AzNetworkInterface `
     -ResourceGroupName "myResourceGroupLoadBalancer" `
     -Name myVM$i `
     -Location "EastUS" `
     -Subnet $vnet.Subnets[0] `
     -LoadBalancerBackendAddressPool $lb.BackendAddressPools[0]
}

# Introducimos credenciales

$cred = Get-Credential

for ($i=1; $i -le 2; $i++)
{
    New-AzVm `
        -ResourceGroupName "myResourceGroupLoadBalancer" `
        -Name "myVM$i" `
        -Location "East US" `
        -VirtualNetworkName "myVnet" `
        -SubnetName "mySubnet" `
        -SecurityGroupName "myNetworkSecurityGroup" `
        -OpenPorts 80 `
        -Credential $cred `
        -AsJob
}

for ($i=1; $i -le 2; $i++)
{
  $1PublicSettings = '{"ModulesURL":"https://github.com/lilwhite/Proyecto-MAT/raw/master/Ejercicio-2/WebEmpresa.ps1.zip", "configurationFunction": "WebEmpresa.ps1\\WebEmpresa", "Properties": {"MachineName": '+'"'+"myVM$i"+'"'+'} }'

  Set-AzVMExtension `
    -ExtensionName "DSC" `
    -ResourceGroupName "myResourceGroupLoadBalancer" `
    -VMName "myVM$i" `
    -Publisher "Microsoft.Powershell" `
    -ExtensionType "DSC" `
    -TypeHandlerVersion 2.7 `
    -SettingString $1PublicSettings `
    -Location "East US"
}
