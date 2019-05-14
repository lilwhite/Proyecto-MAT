# Ejercicio 1

Estos usuarios deben poder acceder a los recursos de Azure utilizando sus credenciales on-premises. Los usuarios de sistemas deben tener acceso completo a todos los recursos. Los usuarios de logística sólo deben tener permisos de lectura y los usuarios de desarrollo sólo deben tener permisos de lectura y modificación sobre los recursos relacionados con las aplicaciones web, pero no deben tener acceso al resto de recursos. Cualquiera de los usuarios de los tres grupos debe poder resetear sus propias contraseñas y estas deben sincronizarse en el directorio activo on-premises.

La sincronización de los usuarios la realizaremos mediante Azure AD Connect, en una de las máquinas on-premises.

Para poder establecer que las contraseñas se modifiquen on-premises deberemos de seleccionar **Password Writeback** dentro de las opciones de configuración.

<p align="center">
  <a href="https://imgur.com/Je9riBy"><img src="https://i.imgur.com/Je9riByl.png" title="source: imgur.com" /></a>
</p>

Dentro de **Azure Active Directory** habilitaremos que los usuarios puedan resetearse ellos mismos sus propias contraseñas.

<p align="center">
  <a href="https://imgur.com/9MYLXIW"><img src="https://i.imgur.com/9MYLXIWl.png" title="source: imgur.com" /></a>
</p>

## Control de accesos

### Sistemas

El rol de **Contributor** se lo asignaremos sobre la suscripción para que tengan acceso completo a todos los recursos.

<p align="center">
  <a href="https://imgur.com/uvEs7cJ"><img src="https://i.imgur.com/uvEs7cJl.png" title="source: imgur.com" /></a>
</p>

### Logística

Únicamente deben tener permisos de lectura, por lo que les asignaremos el rol de **Reader**

<p align="center">
  <a href="https://imgur.com/Z2V1rx4"><img src="https://i.imgur.com/Z2V1rx4l.png" title="source: imgur.com" /></a>
</p>

### Desarrollo

Para los usuarios de desarrollo les asignaremos el rol de **Web Plan Contributor** y **WebSite Contributor** para que tengan acceso a los recursos web.

<p align="center">
  <a href="https://imgur.com/JNY5xlX"><img src="https://i.imgur.com/JNY5xlXl.png" title="source: imgur.com" /></a>
</p>
