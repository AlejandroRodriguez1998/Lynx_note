# Verificación del tutorial

La grabación se hizo contra la aplicación Rails original, con Ruby 3.0.2,
Rails 7.1.3.2 y MongoDB 7 en contenedores Docker. El único puerto publicado fue
`127.0.0.1:3100`. No se usó una maqueta de la aplicación ni una base de datos real.

Se comprobaron en el navegador los siguientes recorridos:

| Recorrido | Evidencia comprobada |
| --- | --- |
| Inicio de sesión | La cuenta de Alex accede y aparecen las secciones privadas. |
| Consulta de notas | La selección obtiene el JSON real y muestra el texto y la lista guardados. |
| Creación de una nota | El formulario guarda un título, texto, tres elementos de lista y una imagen subida; el resultado se muestra en Notes. |
| Organización | Se crea «Proyecto web» y se añade la nota desde el formulario de edición; la colección muestra la nota. |
| Amistades | Se acepta la solicitud de Leo y se abre una nota que Sara había compartido. |
| Compartir | Alex selecciona a Sara y el servidor confirma que la nota se ha compartido. |
| Recepción | Se inicia sesión con Sara, aparece el aviso y se abre la nota de Alex desde Friends. |
| Administración | La cuenta administradora accede al panel y consulta usuarios y notas. |
| Móvil | Con viewport y user agent móviles se abre la vista individual de una nota y se navega con el menú desplegable. |

Las aserciones del navegador están en `scripts/capture.py`; el resultado de la
grabación queda en `public/captures/verification.json`.

Durante la navegación aparecieron dos errores de JavaScript de la aplicación
original: una llamada a `createToast` antes de su definición y un temporizador
que intenta pulsar un botón de aviso que ya no existe. Las comprobaciones de
guardado, aceptación, notificación y lectura compartida terminaron correctamente.
Estos avisos no se muestran dentro del vídeo. No se modificó la lógica ni la
interfaz de la aplicación para la grabación.

El proyecto de Remotion pasó la comprobación de TypeScript. Se revisaron
fotogramas de la introducción, el formulario de creación y la vista móvil antes
del render completo.

## Archivo entregado

- Duración: 3 minutos y 14 segundos.
- Vídeo: H.264, 1920 × 1080, 30 fps, 5820 fotogramas.
- Audio: AAC estéreo a 48 kHz; volumen final medido de −16,0 LUFS.
- Tamaño: 22 877 341 bytes, aproximadamente 21,8 MiB.
- Reproducción progresiva: verificada, con el bloque `moov` antes de `mdat`.
- FFmpeg decodificó el archivo completo sin errores.
- Se revisaron fotogramas del MP4 final y el último fotograma de las nueve
  grabaciones de la aplicación, incluida la lectura de la nota desde Sara.

Los metadatos y el SHA-256 están en `exports/quality-report.json`. El montaje
incluye subtítulos integrados; también se entrega el archivo SRT independiente.
