# Ejercio 3

Como este servicio balanceado es crítico para la organización, debemos implementar un nivel adecuado de seguridad. Con este objetivo debes garantizar que las máquinas virtuales están protegidas mediante Azure Backup y que el acceso remoto a las mismas para los administradores está protegido de forma que sólo sea posible mediante una VPN para estos administradores.

# Backup

Primero comenzaremos creando un **Recovery Service Vault** dentro del grupo de recursos.

<p align="center">
  <img src="https://live.staticflickr.com/65535/40877550653_a105fdd5b9_o.jpg" width="1398" height="531" alt="Backup">
</p>

Posteriormente configuraremos la política del Backup y las máquinas a realizar el Backup.

<p align="center">
  <img src="https://live.staticflickr.com/65535/40877576023_04f6fd1169_o.png" width="878" height="565" alt="Backup">
</p>

Para verificar que se han añadido correctamente nos dirigiremos a la sección de **Backup Items**.

<p align="center">
  <img src="https://live.staticflickr.com/65535/40877586713_0ea3ac2799_o.png" width="1189" height="629" alt="Backup">
</p>

Finalmente deberemos esperar a que se realicen los Backup de las máquinas según la política establecida.

<p align="center">
  <img src="https://live.staticflickr.com/65535/33966983798_b9bdb0e27a_o.png" width="859" height="401" alt="Backup">
</p>

<p align="center">
  <img src="https://live.staticflickr.com/65535/47844403751_2302b17fb3_o.png" width="1171" height="505" alt="Captura de pantalla 2019-05-13 a las 23.44.51">
</p>

# Acceso mediante VPN
