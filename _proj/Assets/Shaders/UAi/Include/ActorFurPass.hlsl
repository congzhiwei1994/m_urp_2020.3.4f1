#ifndef ACTOR_HAIR_PASS_INCLUDED
    #define ACTOR_HAIR_PASS_INCLUDED

    #include "ActorInput.hlsl"
    #include "ActorLighting.hlsl"

    struct Attributes
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
        float4 tangentOS    : TANGENT;
        float2 texcoord     : TEXCOORD0;
        float4 color        : COLOR;
    };

    struct Varyings
    {
        float2 uv                       : TEXCOORD0;
        float3 vertexSH                 : TEXCOORD1;        
        float3 positionWS               : TEXCOORD2;                     
        float4 normalWS                 : TEXCOORD3;   
        float4 tangentWS                : TEXCOORD4;  
        float4 bitangentWS              : TEXCOORD5;             
        half3 vertexLight               : TEXCOORD6; 
        float4 shadowCoord              : TEXCOORD7;
        float4 positionCS               : SV_POSITION;
    };

    Varyings LitPassVertex(Attributes v)
    {
        Varyings o = (Varyings)0;
        o.uv = v.texcoord;
        float3 furDir = _FurDir + v.normalOS ;

        furDir = lerp(v.normalOS, furDir, _pallPos);
        v.positionOS.xyz += furDir * _pallPos * _FurLength * 0.2 * v.color.a; 
        
        o.positionWS = mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)).xyz;
        o.positionCS = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)));             

        half3 normalWS = TransformObjectToWorldNormal(v.normalOS);
        half3 tangentWS = SafeNormalize(mul((float3x3)UNITY_MATRIX_M, v.tangentOS.xyz));
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
        half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv) ;
        
        half4 normalA = SAMPLE_TEXTURE2D(_NormalCustorm, sampler_NormalCustorm, i.uv * _1UNormalTilling);
        half3 normalTSA = half3((normalA.rg * 2 - 1) * _NormalScaleA, normalA.b);
        half4 normalB = SAMPLE_TEXTURE2D(_NormalCustorm, sampler_NormalCustorm, i.uv * _NormalTillingB + half2(0.5, 0.5));
        half3 normalTSB = half3((normalB.rg * 2 - 1) * _NormalScaleB, normalB.b);
        
        half3 normalTS = BlendNormal(normalTSA, normalTSB);
        half3x3 tbn = half3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz);
        float3 normalWS = NormalizeNormalPerPixel(TransformTangentToWorld(normalTS, tbn));  

        FurData furData;
        ZERO_INITIALIZE(FurData, furData);
        furData.normalWS = normalWS;
        furData.vertexNormal = i.normalWS.xyz;
        #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
            furData.shadowCoord = i.shadowCoord;
        #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
            furData.shadowCoord = TransformWorldToShadowCoord(i.positionWS);
        #else
            furData.shadowCoord = float4(0, 0, 0, 0);
        #endif
        furData.viewDir = SafeNormalize(half3(i.normalWS.w, i.tangentWS.w, i.bitangentWS.w)); 
        furData.positionWS = i.positionWS;
        furData.sh = SampleSHPixel(i.vertexSH, i.normalWS).rgb;
        furData.ao = saturate(lerp(1, _pallPos + 0.15 , _AO));
        furData.albedo = albedo.rgb * _BaseColor.rgb;
        furData.noiseMap = SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, i.uv * exp(_NoiseTilling)).r;

        half3 c = FurLighting(furData);
        half alpha = step(lerp(0, 0.5, _pallPos), furData.noiseMap);
        half softEdge = 1 - _pallPos * _pallPos;
        softEdge = saturate(softEdge + dot(furData.vertexNormal, furData.viewDir) - 1);
        alpha = alpha * softEdge;
        return half4(c,alpha);
    }

#endif
