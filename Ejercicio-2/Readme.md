# EJERCICIO 2

Se nos solicita implementar un script de automatización que despliegue dos máquinas virtuales Windows Server 2016 Datacenter Core con IIS y un balanceador de carga para publicar el servicio web de las dos máquinas en una IP pública. El servicio web debe desplegarse en las máquinas virtuales utilizando DSC (Desired State Configuration). Este servicio web balanceado debe estar monitorizado de forma que cuando deje de estar disponible (las dos máquinas virtuales fallan) se reiniciarán. Si el reinicio falla tras 3 intentos, debe enviar un correo electrónico al administrador del tenant Azure.

## Esquema implementación

** Insertar esquema **

## Procedimiento

Primero procederemos a crear el Script para la creación de las dos máquinas virtuales. Mediante este script configuraremos los siguientes elementos:

* Creación de un nuevo grupo de recursos

Aquí definiremos el nombre del grupo de recursos, y su localización:

```PowerShell
New-AzResourceGroup `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location
```
* Crear una dirección IP pública

Asociaremos la IP pública al grupo de recursos creados:

```PowerShell
$1publicIP = New-AzPublicIpAddress `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location `
  -AllocationMethod "Static" `
  -Name "WebEmpresaIP"
```

* Creación de un grupo de direcciones IP de front-end

```PowerShell
$1frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name "WebFrontEndPool" `
  -PublicIpAddress $1publicIP
```

* Creación de un grupo de direcciones de back-end

```PowerShell
$1backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name "WebBackEndPool"
```

* Creación del balanceador de carga

```PowerShell
$1lb = New-AzLoadBalancer `
  -ResourceGroupName $1ResourceGroupName `
  -Name "WebEmpresaLB" `
  -Location $1Location `
  -FrontendIpConfiguration $1frontendIP `
  -BackendAddressPool $1backendPool
```
* Creación de un sondeo de estado

```PowerShell
Add-AzLoadBalancerProbeConfig `
  -Name "Hubble" `
  -LoadBalancer $1lb `
  -Protocol http `
  -Port 80 `
  -RequestPath / `
  -IntervalInSeconds 15 `
  -ProbeCount 3
```

* Aplicamos el sondeo de estado

```PowerShell
Set-AzLoadBalancer -LoadBalancer $1lb
```

* Creación de una regla de equilibrador de carga

```PowerShell
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
```

* Actualizamos el equilibrador de carga


```PowerShell
Set-AzLoadBalancer -LoadBalancer $1lb
```

* Creamos la configuración de la subNet

```PowerShell
$1subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name $1SubnetName `
  -AddressPrefix 192.168.1.0/24
```

* Creamos la Red Virtual

```PowerShell
$1vnet = New-AzVirtualNetwork `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location `
  -Name $1VirtualNetworkName `
  -AddressPrefix 192.168.0.0/16 `
  -Subnet $1subnetConfig
```

* Creación de NIC virtuales

```PowerShell
for ($i=1; $i -le 2; $i++)
{
   New-AzNetworkInterface `
     -ResourceGroupName $1ResourceGroupName `
     -Name "$1vmName$i" `
     -Location $1Location `
     -Subnet $1vnet.Subnets[0] `
     -LoadBalancerBackendAddressPool $1lb.BackendAddressPools[0]
}
```

* Creación de AzAvailabilitySet

```PowerShell
$1availabilitySet = New-AzAvailabilitySet `
  -ResourceGroupName $1ResourceGroupName `
  -Name "WebEmpresaAS" `
  -Location $1Location `
  -Sku aligned `
  -PlatformFaultDomainCount 2 `
  -PlatformUpdateDomainCount 2
```

* Introducimos credenciales

```PowerShell
$1cred = Get-Credential
```

* Creación de la máquina virtual

```PowerShell
for ($i=1; $i -le 2; $i++)
  {

    Write-Host "Instalacion VM iniciandose" -ForegroundColor DarkGreen -BackgroundColor Black

    $2vmName = $1vmName + $i

    New-AzVM `
      -ResourceGroupName $1ResourceGroupName `
      -Name $2vmName `
      -Location $1location `
      -ImageName $1ImageName `
      -AvailabilitySetName "WebEmpresaAS" `
      -Credential $1cred `
      -Size $1Size `
      -OpenPorts 80
  }
```
