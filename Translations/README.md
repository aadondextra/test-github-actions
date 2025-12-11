# Traducciones / Translations

Este proyecto incluye soporte multiidioma usando archivos XLIFF.

## Idiomas Disponibles

- **English (en-US)** - Base language
- **Español México (es-MX)** - Spanish (Mexico) translation

## Estructura de Archivos

```
Translations/
├── Purchase Order.g.xlf       # Archivo generado base (inglés)
└── Purchase Order.es-MX.xlf   # Traducción al español (México)
```

## Cómo Funciona

Business Central carga automáticamente la traducción según el idioma del usuario:
- Usuario con idioma **Inglés** → ve textos en inglés
- Usuario con idioma **Español (México)** → ve textos en español

## Textos Traducidos

- ✅ Captions de tablas y campos
- ✅ ToolTips de páginas
- ✅ Labels de reportes
- ✅ Títulos de acciones
- ✅ OptionCaptions (Open/Abierto, Released/Lanzado, etc.)

## Compilar con Traducciones

Las traducciones se incluyen automáticamente al compilar con **F5** o al generar el paquete `.app`.

## Agregar Nuevos Idiomas

Para agregar más idiomas (francés, alemán, etc.):

1. Copiar `Purchase Order.g.xlf`
2. Renombrar a `Purchase Order.[código-idioma].xlf` (ej: `Purchase Order.fr-FR.xlf`)
3. Cambiar `target-language` en el archivo a tu código de idioma
4. Traducir los elementos `<target>` en el nuevo archivo
5. Compilar el proyecto

## Códigos de Idioma Comunes

- `en-US` - English (United States)
- `es-MX` - Español (México)
- `es-ES` - Español (España)
- `fr-FR` - Français (France)
- `de-DE` - Deutsch (Germany)
- `it-IT` - Italiano (Italy)
- `pt-PT` - Português (Portugal)
- `nl-NL` - Nederlands (Netherlands)

## Verificar Traducciones

1. Publicar la extensión con **F5**
2. En BC, cambiar el idioma del usuario:
   - **My Settings** → **Language**
3. Navegar a las páginas de Purchase Order
4. Verificar que los textos aparecen en el idioma seleccionado
