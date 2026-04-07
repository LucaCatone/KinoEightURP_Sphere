# *Fork of [keijiro/KinoEightURP](https://github.com/keijiro/KinoEightURP)*

**Changes from original:**
- Replaced screen-space Bayer dithering with **triplanar world-space dithering**.
- The dither pattern is now firmly anchored to the 3D environment by reconstructing the absolute world position from the depth buffer. This entirely eliminates both camera rotation and translation jitter.
- Upgraded from 2x2 to 4x4 Bayer matrix for finer dithering.
- Retained the `SphereDitherMatrix.cs` component to pass camera orientation to the shader each frame (now used to calculate triplanar blending weights). 

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
"jp.keijiro.kino.post-processing.eight.universal": "https://github.com/LucaCatone/KinoEightURP_Sphere.git?path=Packages/jp.keijiro.kino.post-processing.eight.universal"
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

1.  **Crucial:** Enable **Depth Texture** in your URP Asset and on your Camera. The shader requires depth to reconstruct the world-space position.
2.  Add the **Eight Color Feature** to the **Renderer Features** list in your URP Renderer asset.
3.  Add the **Eight Color Controller** and **SphereDitherMatrix** components to any camera you want to apply the effect to. The effect is applied only to cameras with these components.
