# Ejercicio 5

Para el departamento de desarrollo, nos han encargado implementar un portal Web a partir de una imagen de Ubuntu Server personalizada con Apache y usando una plantilla JSON. El portal debe desplegarse con un máximo de 3 instancias y un mínimo de 1. El escalado de la solución debe ser automático incrementándose en una instancia cuando el uso de CPU supere el 75% durante 5 minutos (este escalado deberá comprobarse forzando la CPU por encima de este valor). Del mismo modo, si el uso de CPU cae por debajo de un 25% durante 5 minutos, el número de instancias se reducirá en 1. Las instancias que estén en ejecución para el portal deben estar monitorizados usando Azure Log Analytics presentando el uso de CPU de forma gráfica en un dashboard, y debe llegar un correo electrónico a los administradores siempre que se escale el servicio, tanto añadiendo como eliminando instancias.


<ul>
  <li>Instalamos la máquina Ubuntu, con disco no gestionado</li>
  <li>apt-get update</li>
  <li>apt-get install apache2</li>
  <li>apt-get install auditd</li>
  <li>crearemos una carpeta para el agente</li>
  <li>wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w <YOUR WORKSPACE ID> -s <YOUR WORKSPACE PRIMARY KEY> -d opinsights.azure.us</li>
  <li>sudo waagent -deprovision</li>
  <li>Paramos la máquina</li>
  <li>Una vez desasignada realizaremos la captura</li>
  <li>Eliminaremos la maquina al crear la imagen</li>  
</ul>

<p>https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-linux-customimage-autoscale</p>

## Creación y configuración de máquina Ubuntu

<p align="center">
  <img src="https://live.staticflickr.com/65535/40868226613_7c3ec4e309_z.jpg" width="565" height="640" alt="Ubuntu">
</p>

<p align="center">
  <img src="https://live.staticflickr.com/65535/32890977987_e19c62e747_z.jpg" width="640" height="602" alt="UbuntuRED">
</p>

Nos conectamos mediante SSH una vez creada la máquina:

<p align="center">
  <img src="https://live.staticflickr.com/65535/33957674448_2873c62bfb_z.jpg" width="640" height="399" alt="SSH">
</p>

Posteriormente ejecutaremos los siguientes comandos para actualizar la máquina, instalar apache, instalar las dependencias del agente de Log Analytics y crear la carpeta de instalación del agente:

```Bash
#Actualización sistema
sudo apt-get update

#Instalación Apache
sudo apt-get install apache2

#Instalación dependencias
sudo apt-get install auditd

#Creación carpeta
mkdir agente

#Accedemos a la carpeta
cd agente
```

Posteriormente nos dirigiremos a **Advanced settings** dentro de nuestro WorkSpace de Logs Analytics, y procederemos a copiar el comando para descargar el agente en nuestra máquina

<p align="center">
  <img src="https://live.staticflickr.com/65535/47782984512_208a561746_z.jpg" width="640" height="314" alt="Agente">
</p>

```Bash
wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w <YOUR WORKSPACE ID> -s <YOUR WORKSPACE PRIMARY KEY> -d opinsights.azure.us
```

Y para dejar la máquina desprovisionada, ejecutaremos el siguiente comando:

```Bash
sudo waagent -deprovision
```
