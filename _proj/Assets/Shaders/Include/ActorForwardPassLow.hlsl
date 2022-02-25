#ifndef ACTOR_FORWARD_PASS_LOW_INCLUDED
    #define ACTOR_FORWARD_PASS_LOW_INCLUDED

    // ----------------------------------------------------------------------------------------------------------
    //  低端机
    // ----------------------------------------------------------------------------------------------------------

    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
    #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
    #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


    CBUFFER_START(UnityPerMaterial)
    half4 _BaseColor;
    half3 _BaseColor_Low;
    half4 _SHColor_Low;
    CBUFFER_END


    struct AttributesLow
    {
        float4 positionOS   : POSITION;
        float3 normalOS     : NORMAL;
        float2 texcoord     : TEXCOORD0;

    };

    struct VaryingsLow
    {
        float2 uv                       : TEXCOORD0;      
        float3 positionWS               : TEXCOORD1;                     
        float3 normalWS                 : TEXCOORD2;   
        float4 positionCS               : SV_POSITION;
    };

    
    VaryingsLow LitPassVertexLow(AttributesLow v)
    {
        VaryingsLow o = (VaryingsLow)0;
        o.uv = v.texcoord; 
        o.positionWS = mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)).xyz;
        o.positionCS = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)));             
        o.normalWS = TransformObjectToWorldNormal(v.normalOS);
        return o;
    }

    half4 LitPassFragmentLow(VaryingsLow i) : SV_Target
    {              
        Light mainLight = GetMainLight();
        float3 L = mainLight.direction;
        float3 N = i.normalWS;

        half NoL = saturate(dot(N,L)) * 0.8 + 0.2;
        
        half4 albedo = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv);
        half3 diffuse = NoL * albedo.rgb * mainLight.color * _BaseColor_Low;
        half3 c = diffuse + albedo.rgb * _SHColor_Low.rgb;
        #ifdef AlphaTest
            clip(albedo.a - 0.5);
        #endif
        
        return half4(c,albedo.a);
    }

#endif
