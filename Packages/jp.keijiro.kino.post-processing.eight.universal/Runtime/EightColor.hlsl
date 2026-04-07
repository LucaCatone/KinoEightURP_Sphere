#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
#include "Packages/com.unity.render-pipelines.core/Runtime/Utilities/Blit.hlsl"
#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

half _Dithering;
uint _Downsampling;
half _Opacity;
float _DitherScale;
float4 _PaletteLab[PALETTE_ENTRIES];
float4 _PaletteRGB[PALETTE_ENTRIES];

float3 _CameraRight;
float3 _CameraUp;
float3 _CameraForward;
float _CameraFovScale;
float _CameraAspect;

SAMPLER(sampler_BlitTexture);

// 4x4 Bayer matrix for dithering
static const half bayer4x4[16] = {
    -0.5,    0.0,   -0.375,  0.125,
     0.25,  -0.25,   0.375, -0.125,
    -0.3125, 0.1875,-0.4375, 0.0625,
     0.4375,-0.0625, 0.3125,-0.1875
};

// Distance without sqrt
half ec_sqdist(half3 a, half3 b)
{
    return dot(a - b, a - b);
}

// Linear sRGB to OKLab
half3 ec_LinearToOKLab(half3 c)
{
    half3x3 rgb2lms = half3x3(0.4122214708,  0.5363325363,  0.0514459929,
                              0.2119034982,  0.6806995451,  0.1073969566,
                              0.0883024619,  0.2817188376,  0.6299787005);
    half3x3 lms2lab = half3x3(0.2104542553,  0.7936177850, -0.0040720468,
                              1.9779984951, -2.4285922050,  0.4505937099,
                              0.0259040371,  0.7827717662, -0.8086757660);
    return mul(lms2lab, pow(mul(rgb2lms, c), 1.0 / 3));
}

half4 Fragment(Varyings input) : SV_Target
{
    UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);

    // Downsampling (quantization)
    uint2 pss = input.texcoord * _BlitTexture_TexelSize.zw / _Downsampling;
    float2 uv = (pss + 0.5) * _Downsampling * _BlitTexture_TexelSize.xy;

    // Sphere-mapped dithering
    // Costruisce la world direction direttamente dagli assi della camera
    // cosi il pattern e' ancorato al mondo e non jitta alla rotazione
    float2 ndc = input.texcoord * 2.0 - 1.0;
    float3 worldDir = normalize(
        _CameraForward +
        _CameraRight   * ndc.x * _CameraFovScale * _CameraAspect +
        _CameraUp      * ndc.y * _CameraFovScale
    );

    // Coordinate sferiche -> indice Bayer 4x4
    float theta = atan2(worldDir.x, worldDir.z) / (2.0 * 3.14159265);
    float phi   = asin(clamp(worldDir.y, -1.0, 1.0)) / 3.14159265;
    uint2 sphereIndex = uint2(abs(frac(float2(theta, phi)) * _DitherScale) * 4.0) % 4;

    // Pole blending: fallback to screen-space near poles to reduce artifacts
    float poleFade = abs(worldDir.y);
    float2 screenIndex2 = frac(input.texcoord * _DitherScale * 0.2) * 4.0;
    uint2 screenIdx = uint2(screenIndex2) % 4;
    half ditherScreen = bayer4x4[screenIdx.y * 4 + screenIdx.x] * _Dithering;

    half dither = bayer4x4[sphereIndex.y * 4 + sphereIndex.x] * _Dithering;
    dither = lerp(dither, ditherScreen, pow(poleFade, 4.0));

    // Source color sampling in Linear sRGB / Gamma sRGB / OKLab
    half4 src = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, uv);
    half3 src_linear = saturate(src.rgb + dither);
    half3 src_gamma = LinearToSRGB(src_linear);
    half3 src_lab = ec_LinearToOKLab(src_linear);

    // Best fit search
    half3 best_gamma = _PaletteRGB[0].rgb;
    half best_dist = ec_sqdist(src_lab, _PaletteLab[0].rgb);

    [unroll]
    for (int i = 1; i < PALETTE_ENTRIES; i++)
    {
        half dist = ec_sqdist(src_lab, _PaletteLab[i].rgb);
        if (dist < best_dist)
        {
            best_gamma = _PaletteRGB[i].rgb;
            best_dist = dist;
        }
    }

    // Blending
    half4 orig = SAMPLE_TEXTURE2D_X(_BlitTexture, sampler_BlitTexture, input.texcoord);
    return lerp(orig, half4(SRGBToLinear(best_gamma), src.a), _Opacity);
}
