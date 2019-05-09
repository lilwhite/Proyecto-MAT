<h1>Ejercicio 5</h1>

<p>Para el departamento de desarrollo, nos han encargado implementar un portal Web a partir de una imagen de Ubuntu Server personalizada con Apache y usando una plantilla JSON. El portal debe desplegarse con un máximo de 3 instancias y un mínimo de 1. El escalado de la solución debe ser automático incrementándose en una instancia cuando el uso de CPU supere el 75% durante 5 minutos (este escalado deberá comprobarse forzando la CPU por encima de este valor). Del mismo modo, si el uso de CPU cae por debajo de un 25% durante 5 minutos, el número de instancias se reducirá en 1. Las instancias que estén en ejecución para el portal deben estar monitorizados usando Azure Log Analytics presentando el uso de CPU de forma gráfica en un dashboard, y debe llegar un correo electrónico a los administradores siempre que se escale el servicio, tanto añadiendo como eliminando instancias.</p>


<ul>
  <li>Instalamos la máquina Ubuntu</li>
  <li>apt-get install apache2</li>
  <li>sudo waagent -deprovision</li>
  <li>Paramos la máquina</li>
  <li>Una vez desasignada realizaremos la captura</li>
  <li>Eliminaremos la maquina al crear la imagen</li>  
</ul>
