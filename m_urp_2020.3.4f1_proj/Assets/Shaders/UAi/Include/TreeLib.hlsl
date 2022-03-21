#ifndef TREELIB_INCLUDED
#define TREELIB_INCLUDED

#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

float2 Unity_GradientNoise_Dir_float(float2 p)
{
    // Permutation and hashing used in webgl-nosie goo.gl/pX7HtC
    p = p % 289;
    // need full precision, otherwise half overflows when p > 1
    float x = float(34 * p.x + 1) * p.x % 289 + p.y;
    x = (34 * x + 1) * x % 289;
    x = frac(x / 41) * 2 - 1;
    return normalize(float2(x - floor(x + 0.5), abs(x) - 0.5));
}

void Unity_GradientNoise_float(float2 UV, float Scale, out float Out)
{
    float2 p = UV * Scale;
    float2 ip = floor(p);
    float2 fp = frac(p);
    float d00 = dot(Unity_GradientNoise_Dir_float(ip), fp);
    float d01 = dot(Unity_GradientNoise_Dir_float(ip + float2(0, 1)), fp - float2(0, 1));
    float d10 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 0)), fp - float2(1, 0));
    float d11 = dot(Unity_GradientNoise_Dir_float(ip + float2(1, 1)), fp - float2(1, 1));
    fp = fp * fp * fp * (fp * (fp * 6 - 15) + 10);
    Out = lerp(lerp(d00, d01, fp.y), lerp(d10, d11, fp.y), fp.x) + 0.5;
}

float3 ObjectSpaceTreeAnim(float3 positionOS, float2 uv, float noiseScale, float bendStrength, float2 direction, float speed, float colorx, float colorz){
    // +1经验值
    float y = positionOS.y * bendStrength * 0.01 + 1;
    y = y * y;

    float y1 = y * y;
    float y2 = y;

    y = y1 - y2;

    float2 dir = direction * _TimeParameters.y.xx * y.xx;

    // 计算lerp值
    float sp = speed * _TimeParameters.x;
    uv = uv + sp.xx;

    float noise;
    Unity_GradientNoise_float(uv, noiseScale, noise);
    float vcx = colorx;
    float vcy = colorz;

    float3 lm = float3(1, 1, 1);
    float3 l = lerp(lm, noise.xxx, float3(vcx, vcy, 0));

    //

    half3 opos = half3(positionOS.x + dir.x, positionOS.y, positionOS.z + dir.y);
    half3 finalPos = lerp(positionOS.xyz, opos, l);
    finalPos = GetAbsolutePositionWS(finalPos.xyz);
    return finalPos;
}

#endif
