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

# LOOP

while ($i -lt 2)
{
  $i++
  # Crea la máquina virtual
  New-AzVM `
    -ResourceGroupName $1ResourceGroupName `
    -Name $1vmName+$i `
    -Location $1location `
    -ImageName $1ImageName `
    -VirtualNetworkName $1VirtualNetworkName+$i `
    -SubnetName $1SubnetName+$i `
    -SecurityGroupName $1SecurityGroupName `
    -PublicIpAddressName $1PublicIpAddressName+$i `
    -Credential $1cred `
    -Size $1Size `
    -OpenPorts 80

    # Instalación IIS

    Write-Host "Instalación Servidor IIS" -ForegroundColor DarkGreen -BackgroundColor Black

    $1PublicSettings = '{"ModulesURL":"https://github.com/lilwhite/Proyecto-MAT/raw/master/Ejercicio-2/WebEmpresa.ps1.zip", "configurationFunction": "WebEmpresa.ps1\\WebEmpresa", "Properties": {"MachineName": '+'"'+$1vmName+$i+'"'+'} }'

    Set-AzVMExtension `
    -ExtensionName "DSC" `
    -ResourceGroupName $1ResourceGroupName `
    -VMName $1vmName `
    -Publisher "Microsoft.Powershell" `
    -ExtensionType "DSC" `
    -TypeHandlerVersion 2.7 `
    -SettingString $1PublicSettings `
    -Location $1Location
}
