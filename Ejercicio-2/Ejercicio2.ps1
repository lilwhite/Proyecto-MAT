# Script Ejercicio 2
# Variables Comunes
$1ResourceGroupName = "myResourceGroup"
$1Location = "eastus"
$1vmName = "WebEmpresa"
$1ImageName = "MicrosoftWindowsServer:WindowsServer:2016-Datacenter-Server-Core:latest"
$1VirtualNetworkName = "WebVNET"
$1SubnetName = "WebSubVNET"
$1SecurityGroupName = "WebNSG"
$1PublicIpAddressName = "WebPublicIP"
$1Size = "Standard_B1s"

# Crear grupo de recursos
New-AzResourceGroup -Name $1ResourceGroupName -Location $1Location

# Crea el objeto de usuario
$1cred = Get-Credential -Message "Introduce el usuario y la contraseña para la máquina virtual."

# LOOP creación de máquinas virtuales

while ($i -lt 2)
  {
    $i++
    # Crea la máquina virtual

    Write-Host "Instalación VM iniciándose" -ForegroundColor DarkGreen -BackgroundColor Black

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
      -SecurityGroupName $1SecurityGroupName `
      -PublicIpAddressName $2PublicIpAddressName `
      -Credential $1cred `
      -Size $1Size `
      -OpenPorts 80

    Write-Host "Instalación VM finalizada" -ForegroundColor DarkGreen -BackgroundColor Black

    # Instalación IIS

    Write-Host "Instalación Servidor IIS iniciándose" -ForegroundColor DarkGreen -BackgroundColor Black

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

    Write-Host "Instalación Servidor IIS completada" -ForegroundColor DarkGreen -BackgroundColor Black
  }
