# *Fork of [keijiro/KinoEightURP](https://github.com/keijiro/KinoEightURP)*

**Changes from original:**
- Replaced screen-space Bayer dithering with sphere-mapped dithering to eliminate camera rotation jitter
- Dither pattern is now anchored to world space via camera axis vectors, inspired by the technique described in Lucas Pope's Obra Dinn devlog
- Added `SphereDitherMatrix.cs` component to pass camera orientation to the shader each frame. Add this component to any GameObject to make the new shader work.
- Upgraded from 2x2 to 4x4 Bayer matrix for finer dithering
- Pole blending: smooth fallback to screen-space dithering when looking straight up/down to reduce spherical projection artifacts

# KinoEight for URP

![gif](https://i.imgur.com/KJ4pgJ3.gif)
![gif](https://i.imgur.com/gSs1Lc4.gif)

**[KinoEight]** is an 8-bit-style post-processing effect originally developed for
HDRP. **KinoEight URP** is a simple port of this effect for URP.

[KinoEight]: https://github.com/keijiro/KinoEight

## System Requirements

- Unity 6.0 or later
- Universal Render Pipeline

## How to Install
 
Add the following line to the `dependencies` section of your project's
`Packages/manifest.json`:
 
```json
"jp.keijiro.kino.post-processing.eight.universal": "https://github.com/LucaCatone/KinoEightURP.git?path=Packages/jp.keijiro.kino.post-processing.eight.universal"
```
 
> If you prefer installing the original package via the Keijiro scoped
> registry instead, follow [these instructions].
 
[these instructions]:
  https://gist.github.com/keijiro/f8c7e8ff29bfe63d86b888901b82644c

## Eight Color Effect

<img width="760" height="502" alt="Inspector" src="https://github.com/user-attachments/assets/0f14a50c-cfcf-457f-ad1e-065497edf5a2" />

The **Eight Color** effect reduces the color palette of an image to eight
colors. It includes additional options:

- **Extended**: Expands the color palette to 16 colors.
- **Dithering**: Soften banding artifacts with a low-resolution dithering
  pattern.
- **Downsampling**: Pixelate the image by lowering its resolution.

### How to Use

1. Add the **Eight Color Feature** to the **Renderer Features** list in your
   URP Renderer asset.
2. Add the **Eight Color Controller** component to any camera you want to apply
   the effect to. The effect is applied only to cameras with this component.

## Current Limitations

The Tiled Palette effect from the original KinoEight HDRP package is not yet
available in this URP version.
