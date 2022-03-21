
#ifndef ACTOR_SHADOWCASTOR_INCLUDED
    #define ACTOR_SHADOWCASTOR_INCLUDED

    #include "ActorInput.hlsl"
    #include "ActorCommonMethod.hlsl"
    
    struct Attributes
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
        float2 uv           : TEXCOORD0;   
        #ifdef _DISSOLVE
            float2 uv2      : TEXCOORD1;
            float2 uv3      : TEXCOORD2;
        #endif
    };

    struct Varyings
    {
        float4 positionCS   : SV_POSITION;

        #ifdef _DISSOLVE
            float4 dissolveUV           : TEXCOORD0;
        #endif
        float2 uv           : TEXCOORD1;
    };

    float3 ApplyShadowBias1(float3 positionWS, float3 normalWS, float3 lightDirection)
    {
        float invNdotL = 1.0 - saturate(dot(lightDirection, normalWS));
        float scale = invNdotL * _ShadowBias.y;

        positionWS = lightDirection * _ShadowBias.xxx + positionWS;
        positionWS = normalWS * scale.xxx + positionWS;
        return positionWS;
    }

    Varyings ShadowPassVertex(Attributes v)
    {
        Varyings o = (Varyings)0;
        o.uv = v.uv;
        float3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
        float3 normalWS = TransformObjectToWorldNormal(v.normalOS);
        float4 positionCS = TransformWorldToHClip(ApplyShadowBias1(positionWS, normalWS, _LightDirection));
        #if UNITY_REVERSED_Z
            positionCS.z = min(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #else
            positionCS.z = max(positionCS.z, positionCS.w * UNITY_NEAR_CLIP_VALUE);
        #endif
        
        o.positionCS = positionCS;
        #ifdef _DISSOLVE
            o.dissolveUV = float4(v.uv2,v.uv3);
        #endif
        return o;
    }

    half4 ShadowPassFragment(Varyings i) : SV_TARGET
    {
        #ifdef _DISSOLVE
            half3 color =  DissolveColor(i.dissolveUV);
        #endif

        #ifdef _AlphaTest
            half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap,i.uv);
            clip(baseMap.a - 0.5);
        #endif
        return 0;
    }
#endif