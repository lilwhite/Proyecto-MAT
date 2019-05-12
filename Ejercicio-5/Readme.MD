# Ejercicio 5

Para el departamento de desarrollo, nos han encargado implementar un portal Web a partir de una imagen de Ubuntu Server personalizada con Apache y usando una plantilla JSON. El portal debe desplegarse con un máximo de 3 instancias y un mínimo de 1. El escalado de la solución debe ser automático incrementándose en una instancia cuando el uso de CPU supere el 75% durante 5 minutos (este escalado deberá comprobarse forzando la CPU por encima de este valor). Del mismo modo, si el uso de CPU cae por debajo de un 25% durante 5 minutos, el número de instancias se reducirá en 1. Las instancias que estén en ejecución para el portal deben estar monitorizados usando Azure Log Analytics presentando el uso de CPU de forma gráfica en un dashboard, y debe llegar un correo electrónico a los administradores siempre que se escale el servicio, tanto añadiendo como eliminando instancias.



* Instalamos la máquina Ubuntu, con disco no gestionado
* apt-get update
* apt-get install apache2
* apt-get install auditd
* crearemos una carpeta para el agente
* wget https://raw.githubusercontent.com/Microsoft/OMS-Agent-for-Linux/master/installer/scripts/onboard_agent.sh && sh onboard_agent.sh -w <YOUR WORKSPACE ID> -s <YOUR WORKSPACE PRIMARY KEY> -d opinsights.azure.us
* sudo waagent -deprovision
* Paramos la máquina


https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-linux-customimage-autoscale

## Creación y configuración de máquina Ubuntu

Como primer paso, deberemos de configurar una máquina Ubuntu, y desprovisionarla para dejarla como plantilla de creación de las instancias del scale set.

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
Paramos la máquina y esperamos a que se quede en estado **Stopped (deallocated)**:

<p align="center">
  <img src="https://live.staticflickr.com/65535/47783188422_94be4e4810_z.jpg" width="640" height="168" alt="Stopped">
</p>

Una vez parada, podemos proceder a eliminar todos los recursos a excepción de la cuenta de almacenamiento:

<p align="center">
  <img src="https://live.staticflickr.com/65535/47045728304_ba2fff639d_z.jpg" width="426" height="545" alt="Captura de pantalla 2019-05-12 a las 21.36.52">
</p>

## Despliegue de Scale-Set

La plantilla **ScaleSet.json** despliega el scale set con las características requeridas. La plantilla está basada en las Quick Templates de Microsoft

https://github.com/Azure/azure-quickstart-templates/tree/master/201-vmss-linux-customimage-autoscale

Procedemos a desplegar la plantilla personalizada

<a href=https://portal.azure.com/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2Flilwhite%2FProyecto-MAT%2Fmaster%2FEjercicio-5%2FScaleSet.json rel="nofollow">
  <img src="https://live.staticflickr.com/65535/32892687807_70317bb54a_o.png" width="161" height="34" alt="boton">
</a>

<p align="center">
  <img src="https://live.staticflickr.com/65535/47784611092_c331a57b8b_o.jpg" width="943" height="1087" alt="PlantillaPersonalizada">
</p>

Como vemos en la imagen nos requerirá los siguientes parámetros:

* Grupo de recursos
* Tamaño de las instancias a desplegar
* Nombre de la máquina
* Número de instancias que desplegará en un inicio
* Usuario y password
* URI del VHD

Con respecto a la URI del VHD, la podremos encontrar en la cuenta de almacenamiento. De ahí la importancia de no haber creado anteriormente la imagen con un disco gestionado.

<p align="center">
  <img src="https://live.staticflickr.com/65535/33959394468_c33688f199_o.jpg" width="1258" height="967" alt="VHD">
</p>

Una vez finalizado el despliegue, comprobaremos que efectivamente, únicamente se encuentra una instancia activa.

<p align="center">
  <img src="https://live.staticflickr.com/65535/47784690812_7a4243052f_o.jpg" width="1375" height="1063" alt="Captura de pantalla 2019-05-13 a las 1.18.57">
</p>

Para realizar las pruebas de rendiemto sobre las máquinas habilitaremos **Boot Diagnostics** en el scale set, y dentro de las instancias tendremos que actualizar la máquina para que reciba el boot diagnostics y así habilitar la consola remota:

<p align="center">
  <img src="https://live.staticflickr.com/65535/46920541205_71987bc5aa_o.png" width="855" height="378" alt="Upgrade">
</p>
