# EJERCICIO 2

Se nos solicita implementar un script de automatización que despliegue dos máquinas virtuales Windows Server 2016 Datacenter Core con IIS y un balanceador de carga para publicar el servicio web de las dos máquinas en una IP pública. El servicio web debe desplegarse en las máquinas virtuales utilizando DSC (Desired State Configuration). Este servicio web balanceado debe estar monitorizado de forma que cuando deje de estar disponible (las dos máquinas virtuales fallan) se reiniciarán. Si el reinicio falla tras 3 intentos, debe enviar un correo electrónico al administrador del tenant Azure.

## Esquema implementación

** Insertar esquema **

## Script de automatización para la creación de máquinas y balanceador de carga

Primero procederemos a crear el Script para la creación de las dos máquinas virtuales. Mediante este script configuraremos los siguientes elementos:

* Creación de un nuevo grupo de recursos

Aquí definiremos el nombre del grupo de recursos, y su localización:

```PowerShell
New-AzResourceGroup `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location
```
* Crear una dirección IP pública

Para que tengamos acceso desde Internet al servicio IIS deberemos de asignarle una IP pública a la que llamaremos **WebEmpresaIP**, la cual asociaremos al recurso anteriormente creado:

```PowerShell
$1publicIP = New-AzPublicIpAddress `
  -ResourceGroupName $1ResourceGroupName `
  -Location $1Location `
  -AllocationMethod "Static" `
  -Name "WebEmpresaIP"
```

* Creación de un grupo de direcciones IP de front-end

Antes de pasar a la creación del Load Balancer, definiremos el nombre de la pila de direcciones de front-end de este:

```PowerShell
$1frontendIP = New-AzLoadBalancerFrontendIpConfig `
  -Name "WebFrontEndPool" `
  -PublicIpAddress $1publicIP
```

* Creación de un grupo de direcciones de back-end

También haremos lo mismo con la pila de direcciones del back-end:

```PowerShell
$1backendPool = New-AzLoadBalancerBackendAddressPoolConfig `
  -Name "WebBackEndPool"
```

* Creación del balanceador de carga

Una vez definidos las pilas, procederemos a crear el balanceador:

```PowerShell
$1lb = New-AzLoadBalancer `
  -ResourceGroupName $1ResourceGroupName `
  -Name "WebEmpresaLB" `
  -Location $1Location `
  -FrontendIpConfiguration $1frontendIP `
  -BackendAddressPool $1backendPool
```
* Creación de la sonda de estado

Esta sonda, supervisará el estado del servicio, y por defecto después de dos errores consecutivos en un intervalo de 15 segundos, quitará la máquina que reporte el error de la distribución del equilibrador de carga:

```PowerShell
Add-AzLoadBalancerProbeConfig `
  -Name "Hubble" `
  -LoadBalancer $1lb `
  -Protocol tcp `
  -Port 80 `
  -IntervalInSeconds 15 `
  -ProbeCount 2
```

* Aplicamos el sondeo de estado

```PowerShell
Set-AzLoadBalancer -LoadBalancer $1lb
```

* Creación de una regla de equilibrador de carga

En base a la sonda creada y las pilas de direcciones determinaremos que la regla equilibre el tráfico en el puerto TCP 80:

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

Antes de ponernos a crear las máquinas, tendremos que configurar las redes virtuales que asignarles. Primero configuraremos la subn:

```PowerShell
$1subnetConfig = New-AzVirtualNetworkSubnetConfig `
  -Name $1SubnetName `
  -AddressPrefix 192.168.1.0/24
```

* Creamos la Red Virtual

Una vez que tenemos la configuración de la subnet, procederemos a crear la red virtual:

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

Crearemos el AvailabilitySet, para poder asociarlo a nuestro balanceador y también tener una mayor disponibilidad sobre las máquinas:

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

* Por último, creación de la máquina virtual

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

El archivo correspondiente con el script en PowerShell sería **LoadBalancer.ps1**.

Este sript está basado en el tutorial de Microsoft : **Equilibrio de carga de máquinas virtuales Windows en Azure para crear una aplicación de alta disponibilidad**.

https://docs.microsoft.com/es-es/azure/virtual-machines/windows/tutorial-load-balancer

Antes de lanzar el script deberemos estar conectados a nuestro tenant de Azure mediante el siguiente commando:

```PowerShell
Connect-AzAccount
```

## Despliegue de IIS mediante DSC

Una vez ejecutado el script se nos habrán creado los siguientes recursos:

<p align="center">
  <img src="https://live.staticflickr.com/65535/47829165101_61a59085c7_z.jpg" width="640" height="401" alt="RG-Webempresa">
</p>

A continuación, deberemos crear una cuenta de automatización para la instalación del IIS en las máquinas del balanceador de carga.

<p align="center">
  <img src="https://live.staticflickr.com/65535/32885509987_fe28ffd34e_o.png" width="315" height="437" alt="Cuenta de automatización">
</p>

Una vez creada, nos dirigiremos a la pestaña de **State Configuration (DSC)** y añadiremos una nueva configuración.

<p align="center">
  <img src="https://live.staticflickr.com/65535/33952094228_a8542ecbf6_z.jpg" width="640" height="336" alt="DSC">
</p>

Ahora procederemos a añadir nuestro archivo **WebEmpresa.ps1** para la instalación del IIS.

```PowerShell
Configuration WebEmpresa
{
  param ()

  Node 'localhost'
  {
    #Install the IIS Role
    WindowsFeature IIS
    {
      Ensure = "Present"
      Name = "Web-Server"
      IncludeAllSubFeature = $true
    }
    #Install ASP.NET 4.5
    WindowsFeature ASP
    {
      Ensure = "Present"
      Name = "Web-Asp-Net45"
    }
  }
}
```
Cuando comprobemos que se ha añadido correctamente, pulsaremos sobre el objeto y procedermos a realizar la compilación del archivo.

<p align="center">
  <img src="https://live.staticflickr.com/65535/40862902963_10aaf50545_z.jpg" width="640" height="496" alt="Compilación">
</p>

Una vez que se ha compilado correctamente el archivo, añadiremos los nodos del balanceador de carga. Esto hará que sea la cuenta de automatización, la que se encargue de realizar la configuración del DSC sobre los nodos.

<p align="center">
  <img src="https://live.staticflickr.com/65535/47829490291_b5dcea6d3c_z.jpg" width="640" height="272" alt="Configuración de nodos">
</p>

Para comprobar el correcto funcionamiento, podemos acceder a la IP pública del balanceador de carga a través de un navegador y nos aparecerá la página predeterminada del IIS.

## Monitorización servicio Web

Para esta monitorización nos ayudaremos de los **Runbooks** que nos ofrece la cuenta de automatización. Estos, nos permitirán ejecutar scripts en PowerShell sin necesidad de crear otra máquina.

<p align="center">
  <img src="https://live.staticflickr.com/65535/32885755907_13531bf13f_z.jpg" width="640" height="349" alt="Runbooks">
</p>

En la creación de este, seleccionaremos que sea de tipo **PowerShell**.

<p align="center">
  <img src="https://live.staticflickr.com/65535/32885769807_e861c6a2cc.jpg" width="319" height="349" alt="NewRunBook">
</p>

A continuación añadiremos el código del archivo **Automatizacion.ps1**. Hasta la línea 419 corresponde con la importación de módulos de PowerShell de AzureRM para que funcione correctamente (https://docs.microsoft.com/en-us/azure/automation/automation-update-azure-modules). En el resto del código, realizaremos los siguientes pasos:

* Primero deberemos conectarnos al tenant de Azure

```PowerShell
$User = "<TENANT DE AZURE>"
$PWord = ConvertTo-SecureString -String '<PASSWORD>' -AsPlainText -Force
$Credential = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $User, $PWord

Connect-AzureRmAccount -Credential $Credential
```
* A continuación realizaremos una solicitud HTTP al servicio Web del balanceador

```PowerShell
$WebServer1 = Invoke-WebRequest "http://<IP PUBLICA BALANCEADOR>" -UseBasicParsing

$Estado1 = $WebServer.StatusCode
```
* En la primera condición estableceremos que si el servicio responde correctamente nos devolverá una salida como **"STATUS OK"** y finalizará el proceso.

```PowerShell
if ($Estado1 -eq 200){

        Write-Output "STATUS OK"

        exit 0

}
```

* Si la respuesta fuese distinta a un correcto funcionamiento, le daríamos la orden de que reiniciara las dos máquinas, volviera a realizar la solicitud y si el estado es correcto finaliza el proceso. En caso contrario, reiniciará las máquinas hasta un total de 3 veces, y si el servicio siguiera indisponible, nos devolvería la salida **"STATUS NOK"**.

```PowerShell
if ($Estado1 -eq 200){

        Write-Output "STATUS OK"

        exit 0

}

else {
      Write-Output "STATUS KO Reiniciando Maquinas"

      $i = 1

      DO{

        $restart1 = Restart-AzureRmVM -ResourceGroupName "RG-WebEmpresa" -Name "WebEmpresa1"
        $restart2 = Restart-AzureRmVM -ResourceGroupName "RG-WebEmpresa" -Name "WebEmpresa2"

        $WebServer2 = Invoke-WebRequest "http://<IP PUBLICA BALANCEADOR>"

        $Estado2 = $WebServer.StatusCode

      }While(($Estado2 -eq 200)-or ($i -le 3))

      If ($Estado2 -eq 200){

        Write-Output "Servicio Reestablecido"

        Exit 1
      }
      else{

        Write-Output "STATUS NOK"

        Exit 2
      }
}
```
Una vez que tenemos ya el script de automatización, guardamos, lo publicamos y nos deberá aparecer en el listado de runbooks disponibles. A continación tendremos que crear la programación del script. Nos dirigiremos al apartado de **Schedule** e indicaremos el inicio de cualquier hora, lo seleccionamos como recurrente y crearemos otros 3 más cada 15 minutos, para que el servicio en caso de caída esté como máximo 15 minutos:

<p align="center">
<img src="https://live.staticflickr.com/65535/47040259114_9455a72303_z.jpg" width="640" height="400" alt="Schedule">
</p>

Volveremos al runbook que hemos creado y le asignaremos los **Schedule** con los siguientes parámetros:

<p align="center">
<img src="https://live.staticflickr.com/65535/47040284174_36381b8837_z.jpg" width="374" height="640" alt="Programación">
</p>

Teniendo ya la programación del script, podemos lanzarlo para comprobar como recoge las salidas:

<p align="center">
<img src="https://live.staticflickr.com/65535/46918276965_5c9e03e304_z.jpg" width="640" height="137" alt="Status">
</p>

Habilitaremos la recogida de logs para que los envíen a Log Analytics:

<p align="center">
<img src="https://live.staticflickr.com/65535/46918299345_cc143616bc_z.jpg" width="640" height="171" alt="TurnOn">
</p>

Mediante la siguiente query nos mostrará el resultado de los estados OK:

```Kusto
AzureDiagnostics | where ResourceProvider == "MICROSOFT.AUTOMATION"
| where StreamType_s == "Output"
| where ResultDescription == "STATUS OK"
```
## Creación de alerta al administrador

Una vez que tenemos ya monitorizado el servicio web, mediante la query para comprobar su estado, generaremos la nueva alerta:

<p align="center">
<img src="https://live.staticflickr.com/65535/33957418448_4bb5b4afef_z.jpg" width="640" height="97" alt="Alerta1">
</p>

En la condición le indicaremos que nos envíe la alerta en el momento que registre un nuevo valor:

<p align="center">
<img src="https://live.staticflickr.com/65535/46918379495_6a37b78f97_z.jpg" width="640" height="396" alt="Alerta2">
</p>

A continuación añadiremos la acción, que en nuestro caso será enviar un correo al administrador:

<p align="center">
<img src="https://live.staticflickr.com/65535/40868100523_cbeddb3a0f_z.jpg" width="640" height="531" alt="Alerta3">
</p>

Desde **Monitor Alert** comprobaremos la nueva alerta creada:

<p align="center">
<img src="https://live.staticflickr.com/65535/33957501458_df600a8259_z.jpg" width="640" height="203" alt="Alerta4">
</p>
