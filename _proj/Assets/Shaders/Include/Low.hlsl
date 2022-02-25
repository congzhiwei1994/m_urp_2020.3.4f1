#ifndef UNIVERSAL_LOW_INCLUDED
#define UNIVERSAL_LOW_INCLUDED

//#include "Lighting.hlsl"
#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
// float3 Lambert2(Light mainLight, float3 normalWS){

//     half contributionTerm = saturate(dot(mainLight.direction, normalWS));
//     half3 lambert = mainLight.color * contributionTerm;
//     return Lambert;
// }

// 为了统一写法 这个就统一调用了，如果要统一去掉sh就这里去掉就行了
void OUTPUT_SH_2(float3 normalWS, out float3 vertexSH){
#ifdef LIGHTMAP_ON

#else
    OUTPUT_SH(normalWS, vertexSH);
#endif
    // OUTPUT_SH(normalWS, vertexSH);
}



float3 SampleSHPixel2(float3 vertexSH, float3 normalWS){
    
    return SampleSHPixel(vertexSH, normalWS);
}


float3 LambertWithSH(Light mainLight, float3 vertexSH, float3 normalWS, float shIntensity){

    half3 lambert = LightingLambert(mainLight.color, mainLight.direction, normalWS);
#ifdef LIGHTMAP_ON

#else
    half3 sh = SampleSHPixel2(vertexSH, normalWS);
    lerp(lambert.rgb, sh*lambert.rgb, shIntensity);
    sh = lerp(half3(0,0,0), sh+lambert.rgb, shIntensity);
    lambert = sh + lambert;

#endif

    // half3 lambert = LightingLambert(mainLight.color, mainLight.direction, normalWS);
    // half3 sh = SampleSHPixel2(vertexSH, normalWS);
    // lambert = lerp(lambert.rgb, sh*lambert.rgb, shIntensity);
    return lambert;
}

#endif