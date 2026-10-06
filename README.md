# FIMACOR Flutter conectado a Spring Boot

Esta versión de la app Flutter está preparada para consumir el mismo backend Spring Boot de FIMACOR.

## Servidor

La app apunta a:

`https://springbootfimacor-production-1fe5.up.railway.app/MobileApiServlet`

El endpoint `/login` del navegador es la página HTML de Spring Security. Flutter no debe apuntar a `/login`: usa `/MobileApiServlet`, que devuelve JSON y mantiene la sesión HTTP.

## Arquitectura

Flutter → MobileApiServlet (Spring Boot) → servicios/repositorios JPA → MySQL

React puede consumir el mismo Spring Boot sin conectarse directamente a MySQL.

## Importante para Railway

El proyecto incluye el nuevo `MobileApiController.java`. Para que el enlace funcione realmente en Railway, hay que desplegar esta versión actualizada del backend. Cambiar solamente `config.dart` no agrega endpoints que no existan en el servidor.

## Flutter

```bash
flutter clean
flutter pub get
flutter run
```

El código conserva el contrato `accion=...` que ya usa la app, por lo que las pantallas existentes no necesitan una reescritura completa.

## Roles soportados por el flujo principal

- Cuentadante: máquinas asignadas, solicitudes de reubicación internas/externas y autorización de reubicaciones internas propias.
- Subdirección: todas las máquinas, solicitudes internas/externas y autorización interna/externa.
- Técnico: mantenimientos/reparaciones asignadas y reporte de arreglo.
