# Vídeo de Lynx Note

Tutorial en español, realizado con **Remotion**, con narración sintética, subtítulos,
música instrumental original y grabaciones reales de la aplicación Rails.
El vídeo utiliza exclusivamente usuarios y datos ficticios.

## Archivos de entrega

- `exports/lynx-note-tutorial.mp4`: vídeo final H.264, Full HD, 30 fps, sonido AAC.
- `exports/lynx-note-portada.png`: miniatura para YouTube.
- `exports/lynx-note-subtitulos.srt`: subtítulos independientes, además de los integrados en imagen.
- `exports/youtube-descripcion.txt`: título, descripción y capítulos sugeridos.

El repositorio incluye la entrega final, las capturas utilizadas y el audio,
de modo que puedes editar el montaje sin volver a instalar la aplicación ni
generar la narración. Las dependencias, cachés y exportaciones de prueba están
excluidas de Git.

## Abrir el proyecto de Remotion

Con Node.js 22 instalado:

```bash
cd mi-video
npm ci
npm run studio
```

Para exportar de nuevo usando las capturas y el audio incluidos:

```bash
npm run render
npm run finalize
```

## Ejecutar la aplicación de demostración

Desde la raíz del repositorio:

```bash
docker compose -f demo/compose.yml up --build -d
```

La aplicación queda en http://127.0.0.1:3100. Ruby, las gemas y MongoDB se ejecutan
en contenedores. La base de datos de demostración se llama `lynx_note_demo` y no
utiliza ninguna base de datos externa. El puerto solo escucha en localhost.

Cuentas ficticias: `alex@example.com`, `sara@example.com`, `admin@example.com`.
Contraseña de todas las cuentas de demo: `DemoLynx2026!`.

Para detener y borrar **solo** los contenedores y volúmenes de esta demostración:

```bash
docker compose -f demo/compose.yml down -v
```

## Regenerar el vídeo

Requisitos: Node.js 22, Python 3, FFmpeg y un navegador Chromium compatible.

```bash
cd mi-video
npm ci
python3 -m venv --system-site-packages .venv
.venv/bin/pip install -r requirements.txt
.venv/bin/python -m playwright install chromium
.venv/bin/python scripts/audio.py
.venv/bin/python scripts/capture.py
npm run typecheck
npm run render
npm run finalize
npm run cover
```

`audio.py` requiere conexión para sintetizar la narración con `edge-tts`; solo
envía el guion escrito en `src/scenes.json`. El montaje utiliza archivos locales.
`LYNX_BROWSER` permite indicar otro ejecutable Chromium para las capturas.
En Remotion se puede usar `--browser-executable=/ruta/a/chromium`.

Las capturas ejecutan acciones que guardan datos. Para repetir el recorrido
completo desde el principio, reinicia la demo con `down -v` y vuelve a levantarla.
Los resultados de las comprobaciones del navegador se guardan en
`public/captures/verification.json`.

El archivo `src/scenes.json` contiene el guion y `src/timeline.json` añade las
duraciones y los subtítulos sincronizados. `src/Video.tsx` contiene el montaje.
La tipografía Ubuntu Sans se incluye con su licencia en `public/fonts/`.

`npm run finalize` ajusta el sonido a −16 LUFS con análisis en dos pasadas,
conserva el vídeo sin recodificarlo y permite la reproducción progresiva del MP4.

La publicación en YouTube queda a cargo del propietario. No se sube ningún
contenido ni se modifica el canal desde este proyecto.
