#ifndef ACTOR_IPUT_INCLUDED
    #define ACTOR_IPUT_INCLUDED

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Shadows.hlsl"
    
    
    CBUFFER_START(UnityPerMaterial)
    // 基本参数
    float4 _BaseMap_ST;
    half4 _BaseColor;
    half4 _EmissionColor;
    half _Mettalic;
    half _Smoothness;
    half _AO;
    half _IndirIntensity;

    // 流光效果
    half4 _FlowMap_ST;
    half4 _FlowColor;
    half _FlowSpeed;

    // 呼吸灯
    half _BreathSpeed;
    half _MinEmission;    
    
    // 溶解效果
    half _DissolveClip;
    half _DissolveScale;
    half4 _DissolveNoiseMap_ST;
    half3 _DissolveColor;
    
    half _Detail;
    // 外发光
    half _RimPower;
    half3 _RimColor;

    // 透射效果
    half3 _TranslucencyColor;
    half _ThicknessIntensity;
    half _TranslucencyPower;
    half _Distortion;
    half _TranslucencyInt;
    
    // 羽毛
    half4 _SpecColor;
    half _GGXAnisotropy;

    //镭射
    half _RayIntensity;
    half _RayOffset;

    // 毛发
    float4 _NoiseMap_ST;
    half _AlphaClip;
    float _NoiseIntensityA;
    float _ShininessA;
    float4 _HairColorA;
    float _HairShiftA;
    half4 _HairColorB;
    half _NoiseIntensityB;
    half _ShininessB;
    half _HairShiftB;

    // 绒毛
    half _Smoothnee;
    half _FurLength;
    half _NoiseTilling;
    half3 _SpecularColor;
    half3 _FurDir;
    half _FresnelIntensity;
    half _FresnelPow;
    half _1UNormalTilling;
    half _NormalTillingB;
    half _NormalScaleA;
    half _NormalScaleB;

    CBUFFER_END

    TEXTURE2D(_MixMap);                        SAMPLER(sampler_MixMap);
    TEXTURE2D(_NormalCustorm);                 SAMPLER(sampler_NormalCustorm);
    #ifdef _FLOW
        TEXTURE2D(_FlowMap);                   SAMPLER(sampler_FlowMap);
    #endif
    TEXTURE2D (_NoiseMap);             SAMPLER(sampler_NoiseMap);
    TEXTURE2D(_RampMap);                 SAMPLER(sampler_RampMap);
    
    #ifdef _DISSOLVE
        TEXTURE2D(_DissolveRampMap);                   SAMPLER(sampler_DissolveRampMap);
        TEXTURE2D(_DissolveNoiseMap);                  SAMPLER(sampler_DissolveNoiseMap);               
    #endif

    // ShadowCaster Pass
    float3 _LightDirection;
    // 绒毛
    half _pallPos;

#endif
