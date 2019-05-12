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
* Creación del balanceador de carga
* Creación de un sondeo de estado
* Aplicamos el sondeo de estado
* Creación de una regla de equilibrador de carga
* Actualizamos el equilibrador de carga
* Creamos los recursos de red
* Creamos la configuración de la subNet
* Creamos la Red Virtual
* Creación de NIC virtuales
* Creación de AzAvailabilitySet
* Introducimos credenciales
* Creación de la máquina virtual
