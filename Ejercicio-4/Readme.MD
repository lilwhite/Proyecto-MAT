# Ejercicio4

En un futuro, el servicio web hará uso de una base de datos SQL. Debes implementar esta base de datos mediante Azure SQL Server (usar la base de datos de ejemplo AdventureWorks). Las únicas máquinas que deben acceder a esta base de datos deben ser las del servicio balanceado y la base de datos debe estar protegida mediante cifrado.

Referencia de configuración

https://docs.microsoft.com/es-es/azure/sql-database/sql-database-single-database-get-started

## Creación Base de datos

Crearemos en un nuevo grupo de recursos nuestra base de datos SQL. Configuraremos nuestra base de datos como **Basic** seleccionando la base de datos de ejemplo de AdventureWorks.

<p align="center">
  <a href="https://imgur.com/XOJCapd"><img src="https://i.imgur.com/XOJCapdl.png?1" title="source: imgur.com" /></a>
</p>

<p align="center">
  <a href="https://imgur.com/EwoimVj"><img src="https://i.imgur.com/EwoimVjl.png" title="source: imgur.com" /></a>
</p>

Una vez desplegada, tendremos que realizar la conexión con la WebVNET para que los servidores tengan acceso a la base de datos. Para ello, deberemos de configurarlo a traves de las opciones de seguridad **Firewalls and virtual networks**. Añadiremos una nueva IP cliente y la asociaremos a la VNET indicada.

<p align="center">
  <a href="https://imgur.com/VZzg8j0"><img src="https://i.imgur.com/VZzg8j0l.png" title="source: imgur.com" /></a>
</p>

Esto creará un endpoint en la VNET mediante el cual podremos establecer la conexión.

Comprobamos que la encriptación está activada por defecto.

<p align="center">
  <a href="https://imgur.com/tOFF4xY"><img src="https://i.imgur.com/tOFF4xYl.png" title="source: imgur.com" /></a>
</p>

Y finalmente añadiremos una capa de enmascaramiento:

<p align="center">
  <a href="https://imgur.com/st4aNSz"><img src="https://i.imgur.com/st4aNSzl.png" title="source: imgur.com" /></a>
</p>
