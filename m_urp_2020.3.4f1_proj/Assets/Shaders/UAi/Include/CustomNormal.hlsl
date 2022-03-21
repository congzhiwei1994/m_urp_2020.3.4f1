#ifndef _CustomNormal
#define _CustomNormal

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
TEXTURE2D(_BumpMapCustom);            SAMPLER(sampler_BumpMapCustom);

half3 UnpackNormalScaleCustom(half3 packedNormal, half scale = 1.0)
{
    half3 normal;
    normal.xyz = packedNormal.rgb * 2.0 - 1.0;
    normal.xy *= scale;
    normal = normalize(normal);
    return normal;
}

half3 SampleNormalCustom(float2 uv, TEXTURE2D_PARAM(bumpMap, sampler_bumpMap), half scale = 1.0h)
{
#ifdef _NORMALMAP
    half4 n = SAMPLE_TEXTURE2D(bumpMap, sampler_bumpMap, uv);

    return UnpackNormalScaleCustom(n, scale);
    
#else
    return half3(0.0h, 0.0h, 1.0h);
#endif
}

half3 SampleNormalCustom(float2 uv, half scale = 1.0h)
{
    return SampleNormalCustom(uv, TEXTURE2D_ARGS(_BumpMapCustom, sampler_BumpMapCustom));
}

#endif
