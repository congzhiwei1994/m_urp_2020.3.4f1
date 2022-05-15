
Shader "URP/RenderTextureToMat"
{
    Properties
    {
        _BaseColor("Base Color",color) = (1,1,1,1)
        // _MyRenderTexture("BaseMap", 2D) = "white" {}
    }

    SubShader
    {
        Tags { "Queue"="Geometry" "RenderType" = "Opaque" "IgnoreProjector" = "True" "RenderPipeline" = "UniversalPipeline" }
        LOD 100

        Pass
        {
            Name "Unlit"
            HLSLPROGRAM
            // Required to compile gles 2.0 with standard srp library
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fog
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS       : POSITION;
                float2 uv               : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS       : SV_POSITION;
                float2 uv           : TEXCOORD0;
                float fogCoord      : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                half4 _BaseColor;
                float4 _MyRenderTexture_ST;
            CBUFFER_END
            TEXTURE2D (_MyRenderTexture);SAMPLER(sampler_MyRenderTexture);

            Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;

                o.positionCS = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0))); 
                o.uv = TRANSFORM_TEX(v.uv, _MyRenderTexture);
                o.fogCoord = ComputeFogFactor(o.positionCS.z);

                return o;
            }

            half4 frag(Varyings i) : SV_Target
            {
                half2 screenUV = i.positionCS.xy / _ScaledScreenParams.xy;
                half4 renderTexture = SAMPLE_TEXTURE2D(_MyRenderTexture, sampler_MyRenderTexture, screenUV);
                return renderTexture * _BaseColor;
            }
            ENDHLSL
        }
    }
}

