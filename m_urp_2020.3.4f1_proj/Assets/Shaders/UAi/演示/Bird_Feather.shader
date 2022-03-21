Shader "末日/演示/Bird Feather"
{
    Properties
    {
        [MainColor]_BaseColor("Base Color",color) = (1,1,1,1)
        [MainTexture][NoScaleOffset]_BaseMap("BaseMap", 2D) = "white" {}
        [NoScaleOffset]_MixMap("厚度纹理:R  光滑度:G  AO:B", 2D) = "white" {}
        _Smoothness("光滑度强度",Range(0,1)) = 1
        _AO("AO强度",Range(0,1)) = 1
        _IndirIntensity("环境光强度",Range(0,5)) = 1
        [HDR]_SpecColor("高光颜色",color) = (1,1,1,1)
        [NoScaleOffset]_NormalCustorm("法线纹理",2D) = "bump"{}
        _GGXAnisotropy("各向异性偏移", Range(-1.0, 1.0)) = 0.0

        [Toggle(_Debug)] _Debug_Low("低端机调试(不用开启)",int) = 0
        [if(_Debug)] [HDR] _BaseColor_Low("低端机固有色颜色",Color) = (1,1,1,1)
        [if(_Debug)] _SHColor_Low("低端机环境光",Color) = (0.33,0.36,0.42,1)

        // 防止报错
        [HideInInspector] _MainTex("",2D) = "white" {}

    }

    SubShader
    {
        Tags 
        {
            "Queue"="AlphaTest"
            "RenderType" = "AlphaTest BirdFeature" 
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }
        LOD 300
        Pass
        {
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX

            #if _ADDITIONAL_LIGHTS_VERTEX
                #define  _ADDITIONAL_LIGHTS 
                #undef _ADDITIONAL_LIGHTS_VERTEX
            #endif

            #define _AlphaTest
            #define _GGXAnisotropic

            #include "../Include/ActorForwardPass.hlsl"
            ENDHLSL
        }
        Pass
        {
            Name "ShadowCaster"
            Tags{"LightMode" = "ShadowCaster"}

            ZWrite On
            ZTest LEqual
            
            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex ShadowPassVertex
            #pragma fragment ShadowPassFragment

            #define _AlphaTest
            #include "../Include/ActorShadowCaster.hlsl"

            ENDHLSL
        }

    }

    SubShader
    {
        Tags 
        {
            "Queue"="AlphaTest"
            "RenderType" = "Opaque" 
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        LOD 80

        Pass
        {
            
            Name "ForwardLit"
            Tags{"LightMode" = "UniversalForward"}

            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma vertex LitPassVertexLow
            #pragma fragment LitPassFragmentLow

            #define AlphaTest 1
            #include "../Include/ActorForwardPassLow.hlsl"

            ENDHLSL
        }

    }
    
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor"CustomShaderGUI2"
}
