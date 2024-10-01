# Lynx Note

Este proyecto esta realizado para la asignatura optativa sistemas web de la carrera ingeneria informatica en la ESI, donde esta aplicacion, tiene dos modos, administracion donde los administradores pueden manejar toda la base de datos desde la web y los usuarios donde tienen notas, notas compartidas y amigos.

Esta aplicacion es resposive en todos los dispositivos, con un diseño bonito y vistoso.

##  🗄 Tabla de Contenido

- [Creadores](#construction_worker-creadores)
- [Video](#video_camera-video)
- [Requisitos](#%EF%B8%8F-requisitos)
- [Ejecución](#%EF%B8%8F-ejecución)
- [Documentación](#-documentación)
- [Contacto](#-contacto)

## 	:construction_worker: Creadores

- Alejandro Paniagua Rodriguez
- Ángela Gijón Flores

## :video_camera: Video

Aquí tienes un [video]() haciendote un tour por la aplicación. (Se subirá pronto...)

## ⚙️ Requisitos

- Bundler
- Ruby 3.0.2
- Rails ~> 7.1.3
- Node.js (Recomendado: 16.x)
- Yarn (Última versión estable)
- Mongoid: ~> 8.1, >= 8.1.5
- Carrierwave: ~> 2.2, >= 2.2.6
- Carrierwave-mongoid: ~> 1.4
- Dependencias de compilación y desarrollo del sistema (libssl-dev, libreadline-dev, zlib1g-dev, libsqlite3-dev)

## 🛠️ Ejecución

Nosotros hemos usado el WSL (Subsistema de Windows para Linux) para instalar todo lo anterior.

- Para ejecutar la aplicacion lanzamos el siguiente comando:
  - rails server

## 📚 Documentación

La documentación proporcionada por el profesor y en la que esta basada la aplicación es:

Queremos desarrollar una aplicación web de notas, similar a Notion, en Ruby on Rails o NodeJS. Esta aplicación debe cumplir con los siguientes requisitos:

- Debe ser accesible desde cualquier navegador web.
- La aplicación debe permitir al usuario la gestión (operaciones CRUD) de:

  - **Notas** (Crear, Editar, Eliminar y Compartir). Las notas pueden tener texto, listas e imágenes.
  - **Colecciones de notas** (Crear, Añadir y Eliminar Notas, Eliminar y Compartir).
  - **Usuarios** (Registrarse, Iniciar sesión, Cerrar sesión, Eliminar).
  - **Amistades de usuarios** (Solicitudes, Aceptación, Rechazo, Revocación).
    
- La aplicación debe tener un módulo de gestión de usuarios, que permita a los usuarios acceder al sistema autenticándose y determinando roles de usuario:

  - **Administrador:** Puede gestionar usuarios, relaciones, colecciones de notas y notas.
  - **Usuario:** Puede crear notas (con o sin imágenes) y colecciones, puede listar todas las notas y colecciones de sus amigos, puede solicitar una relación de 
    amistad y puede aceptar o rechazar una relación de amistad. Además, puede compartir notas.

## ☎ Contacto

Cualquier duda o consulta, escribidnos a nuestro correo: 

- alejandro.paniagua1@alu.uclm.es.
- angela.gijon@alu.uclm.es


