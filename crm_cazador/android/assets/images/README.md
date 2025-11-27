# Assets - Imágenes

## Logo de Lotesenremate.pe

Para usar el logo real de Lotesenremate.pe:

1. Coloca el archivo de imagen del logo en esta carpeta con el nombre: `ler_logo.png` o `ler_logo.svg`
2. Si usas SVG, el widget `LerLogo` puede ser actualizado para usar `flutter_svg`
3. Si usas PNG, asegúrate de tener versiones para diferentes densidades:
   - `ler_logo.png` (1x)
   - `ler_logo@2x.png` (2x)
   - `ler_logo@3x.png` (3x)

## Uso actual

Actualmente se usa un widget `LerLogo` que renderiza el logo usando formas y colores programáticamente. Este widget está en:
- `lib/presentation/widgets/common/ler_logo.dart`

Para cambiar a usar una imagen real, actualiza el widget para usar `Image.asset()` o `SvgPicture.asset()`.

