# Ejercio 3

Como este servicio balanceado es crítico para la organización, debemos implementar un nivel adecuado de seguridad. Con este objetivo debes garantizar que las máquinas virtuales están protegidas mediante Azure Backup y que el acceso remoto a las mismas para los administradores está protegido de forma que sólo sea posible mediante una VPN para estos administradores.

# Backup

Primero comenzaremos creando un **Recovery Service Vault** dentro del grupo de recursos.

<p align="center">
  <img src="https://live.staticflickr.com/65535/40877550653_a105fdd5b9_o.jpg" width="640" height="211" alt="Backup">
</p>

Posteriormente configuraremos la política del Backup y las máquinas a realizar el Backup.

<p align="center">
  <img src="https://live.staticflickr.com/65535/40877576023_04f6fd1169_o.png" width="640" height="211" alt="Backup">
</p>

Para verificar que se han añadido correctamente nos dirigiremos a la sección de **Backup Items**.

<p align="center">
  <img src="https://live.staticflickr.com/65535/40877586713_0ea3ac2799_o.png" width="640" height="211" alt="Backup">
</p>

Finalmente deberemos esperar a que se realicen los Backup de las máquinas según la política establecida.

<p align="center">
  <img src="https://live.staticflickr.com/65535/33966983798_b9bdb0e27a_o.png" width="640" height="211" alt="Backup">
</p>

<p align="center">
  <img src="https://live.staticflickr.com/65535/47844403751_2302b17fb3_o.png" width="640" height="211" alt="Backup">
</p>

# Acceso mediante VPN

Para permitir el acceso mediante VPN deberemos haber implementado anteriormente una **Autoridad Certificadora** on-premises, la cual emita certificados de usuario únicamente a los usuarios que pertenezcan al grupo de administradores. Con esto lograremos discriminar al resto de usuarios directamente.

Posteriormente exportaremos el certificado raiz de la Autoridad Certificadora en base64, para más adelante añadirlo al gateway.

Una vez hecho esto, proseguiremos al despliegue en Azure. Primero deberemos de crear un **Virtual Network Gateway**, configurar que el acceso sea mediante VPN y asociarlo a la VNET de las máquinas implementadas con el servicio IIS (WebVNET).

<p align="center">
  <img src="https://live.staticflickr.com/65535/33967043368_7301ff6a01_z.jpg" width="640" height="211" alt="Captura de pantalla 2019-05-13 a las 23.57.54">
</p>

El acceso será del tipo **Point-to-Site**, ya que nos conectaremos desde una máquina on-premises. Para ello nos dirigiremos a la opción de **Point-to-Site Configration**. Desde aquí le indicaremos un espacio de direcciones válido, el nombre de la conexión y deberemos de insertar el código del certificado en el campo de **PUBLIC CERTIFICATE DATA**. La conexión que estableceremos será de tipo SSTP.

<p align="center">
  <img src="https://live.staticflickr.com/65535/47844555131_8e7b1d2a58_z.jpg" width="640" height="318" alt="Captura de pantalla 2019-05-14 a las 0.21.13">
</p>

Una vez que guardemos la configuración, nos permitirá descargar el cliente de VPN para establecer la conexión desde nuestro equipo on-premises. Dentro de estos estos archivos deberemos de instalar el certificado raíz que aparece, que se instalará dentro de la Autoridades Certificadoras de Confianza.

Para más información podemos encontrar información en la documentación de Microsoft https://docs.microsoft.com/es-es/azure/vpn-gateway/point-to-site-about
