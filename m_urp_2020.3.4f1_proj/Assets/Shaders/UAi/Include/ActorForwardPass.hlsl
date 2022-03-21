#ifndef ACTOR_FORWARD_PASS_INCLUDED
    #define ACTOR_FORWARD_PASS_INCLUDED

    #include "ActorInput.hlsl"
    #include "ActorLighting.hlsl"
    #include "ActorCommonMethod.hlsl"

    struct Attributes
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
        float4 tangentOS    : TANGENT;
        float2 texcoord     : TEXCOORD0;
        #if defined (_FLOW) || defined (_DISSOLVE)
            float2 uv2      : TEXCOORD1;
        #endif
        #ifdef _DISSOLVE
            float2 uv3      : TEXCOORD2;
        #endif
    };

    struct Varyings
    {
        float4 uv                       : TEXCOORD0;
        float3 vertexSH                 : TEXCOORD1;        
        float3 positionWS               : TEXCOORD2;                     
        float4 normalWS                 : TEXCOORD3;   
        float4 tangentWS                : TEXCOORD4;  
        float4 bitangentWS              : TEXCOORD5;             
        half3 vertexLight               : TEXCOORD6; 
        float4 shadowCoord              : TEXCOORD7;                
        #ifdef _DISSOLVE
            float4 dissolveUV           : TEXCOORD8;
        #endif
        float4 positionCS               : SV_POSITION;

    };

    Varyings LitPassVertex(Attributes v)
    {
        Varyings o = (Varyings)0;
        o.uv.xy = TRANSFORM_TEX(v.texcoord, _BaseMap);
        #ifdef _FLOW
            o.uv.zw = v.uv2 * _FlowMap_ST.xy + frac(half2(0, _FlowSpeed)  * _Time.y);
        #endif
        
        #ifdef _DISSOLVE
            o.dissolveUV = float4(v.uv2,v.uv3);
        #endif

        o.positionWS = mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)).xyz;
        o.positionCS = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)));             

        half3 normalWS;
        {
            #ifdef UNITY_ASSUME_UNIFORM_SCALING
                normalWS = SafeNormalize(mul((float3x3)UNITY_MATRIX_M, v.normalOS));
            #else
                normalWS = SafeNormalize(mul(v.normalOS, (float3x3)UNITY_MATRIX_I_M));
            #endif
        }

        half3 tangentWS = mul((float3x3)UNITY_MATRIX_M, v.tangentOS.xyz);
        tangentWS = SafeNormalize(tangentWS);

        half sign = v.tangentOS.w * unity_WorldTransformParams.w;
        half3 bitangentWS = cross(normalWS,tangentWS) * sign;
        half3 viewDirWS = _WorldSpaceCameraPos - o.positionWS;

        o.normalWS = half4(normalWS, viewDirWS.x);
        o.tangentWS = half4(tangentWS, viewDirWS.y);
        o.bitangentWS = half4(bitangentWS, viewDirWS.z); 
        o.vertexLight = VertexLighting(o.positionWS,normalWS);
        o.vertexSH = SampleSHVertex(o.normalWS.xyz);
        o.shadowCoord = TransformWorldToShadowCoord(o.positionWS);

        return o;
    }

    half4 LitPassFragment(Varyings i) : SV_Target
    {
        half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv.xy);
        #ifdef _AlphaTest
            clip(baseMap.a - 0.5);
        #endif
        half3 albedo = baseMap.rgb * _BaseColor.rgb;
        half4 mixMap = SAMPLE_TEXTURE2D(_MixMap, sampler_MixMap,i.uv.xy);
        
        // 冰块材质
        #if defined(Ice)
            half detail = saturate(_Detail * mixMap.r);
        #endif
        
        // 溶解
        #ifdef _DISSOLVE
            albedo.rgb +=  DissolveColor(i.dissolveUV);
        #endif

        half4 normalMap = SAMPLE_TEXTURE2D(_NormalCustorm, sampler_NormalCustorm,i.uv.xy);
        half3 normapTS = normalMap.rgb;
        normapTS.xy = (normalMap.rg * 2 - 1);
        half3x3 tbn = half3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz);
        float3 normalWS =  NormalizeNormalPerPixel(mul(normapTS, tbn));
        
        half3 viewDirWS = half3(i.normalWS.w, i.tangentWS.w, i.bitangentWS.w);

        // 镭射
        #ifdef _Ray
            Light mainLight = GetMainLight();
            half3 rayNormal = normalize(i.normalWS.xyz * 0.6 + normalWS * 0.4);
            half3 rayDir = SafeNormalize(mainLight.direction * 0.6 + viewDir * 0.4);
            half NoL = saturate(smoothstep(_RayOffset, 1, dot(rayDir, rayNormal)));
            half3 rampMap = SAMPLE_TEXTURE2D(_RampMap, sampler_RampMap, half2(NoL, 1)) * _RayIntensity;
            albedo = albedo + albedo * rampMap * 2;
        #endif

        SurfaceData surfaceData;
        ZERO_INITIALIZE(SurfaceData, surfaceData);
        surfaceData.albedo = albedo.rgb;
        surfaceData.alpha = baseMap.a;
        surfaceData.metallic = mixMap.r * _Mettalic;

        // GGX 各向异性需要用到高光
        #ifdef _GGXAnisotropic
            surfaceData.specular = surfaceData.albedo * _SpecColor.rgb;
        #else
            surfaceData.specular = half3(0.0h, 0.0h, 0.0h);
        #endif

        #if defined(Ice)
            surfaceData.smoothness = saturate((mixMap.g + detail) * _Smoothness);
        #else
            surfaceData.smoothness = mixMap.g * _Smoothness;
        #endif

        surfaceData.normalTS = normapTS;
        surfaceData.occlusion = lerp(1, mixMap.b, _AO);

        #ifdef _EMISSION
            surfaceData.emission = SAMPLE_TEXTURE2D(_EmissionMap, sampler_EmissionMap,i.uv).rgb * _EmissionColor.rgb;
        #else
            surfaceData.emission = 0;
        #endif

        // 呼吸灯效果
        #ifdef _BREATH
            half breathLight = (sin(_BreathSpeed *_Time.y * 3.1415926) + 1) * 0.5;
            surfaceData.emission = lerp(surfaceData.emission * _MinEmission, surfaceData.emission, breathLight);
        #endif
        
        InputData inputData;
        ZERO_INITIALIZE(InputData, inputData);
        inputData.positionWS = i.positionWS;
        inputData.normalWS = normalWS;
        inputData.viewDirectionWS = SafeNormalize(viewDirWS);
        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            inputData.shadowCoord = i.shadowCoord;
        #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
        #else
            inputData.shadowCoord = float4(0, 0, 0, 0);
        #endif

        // 雾效坐标替换成透射强度
        #ifdef _TRANSMISISSION
            inputData.fogCoord = lerp(1,mixMap.a, _ThicknessIntensity);
        #else
            inputData.fogCoord = 0;
        #endif

        inputData.vertexLighting = i.vertexLight;
        inputData.bakedGI = SampleSHPixel(i.vertexSH, inputData.normalWS) * _IndirIntensity;
        
        
        #ifdef _GGXAnisotropic    // GGX 各向异性
            half3 tangentWS = i.tangentWS.xyz;
            half3 bitangentWS = i.bitangentWS.xyz;
            half thickness = 0;
            half3 color = GGXAnisotropicFragment(inputData, surfaceData, tangentWS, bitangentWS,thickness);
        #else
            half3 color = UniversalFragmentPBR1(inputData, surfaceData.albedo, surfaceData.metallic, surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion, surfaceData.emission, surfaceData.alpha);
        #endif
        
        #ifdef _FLOW
            half flowTex = SAMPLE_TEXTURE2D(_FlowMap, sampler_FlowMap, i.uv.zw).r;
            color += flowTex * _FlowColor.rgb * mixMap.a;
        #endif

        #if defined(Ice)
            color += detail * color;
            half fresnel = pow((1 - saturate(dot(inputData.normalWS,inputData.viewDirectionWS))), _RimPower);
            
            half3 rimColor = fresnel * _RimColor;
            color = lerp(color, color + rimColor, saturate(fresnel));
        #endif
        
        return half4(color,baseMap.a);
    }

#endif
