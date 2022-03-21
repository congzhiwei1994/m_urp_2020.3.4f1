
Shader "末日/演示/Ray Lit"
{
    Properties
    {
        [MainColor] _BaseColor("基础颜色", Color) = (1,1,1,1)
        [NoScaleOffset][MainTexture] _BaseMap("固有色纹理", 2D) = "white" {}
        [NoScaleOffset]_NormalCustorm("法线纹理",2D) = "bump"{}
        [NoScaleOffset]_MixMap("金属度(R)光滑度(G)环境光遮蔽(B)", 2D) = "white" {}
        _Mettalic("金属度",Range(0,1)) = 1
        _Smoothness("光滑度",Range(0,1)) = 1
        _AO("AO强度",Range(0,1)) = 1
        _IndirIntensity("环境光强度",Range(0,5)) = 1
        [NoScaleOffset]_RampMap("镭射颜色纹理", 2D) = "black" {}
        _RayOffset("镭射偏移",Range(-1, 1)) = 0
        _RayIntensity("镭射强度",Range(0, 1)) = 0
        [Toggle(_EMISSION)] _EMISSION_ENABLE("自发光开启", Float) = 0.0
        [if(_EMISSION)] [HDR] _EmissionColor("自发光颜色", Color) = (0, 0, 0, 0)
        [if(_EMISSION)] [NoScaleOffset] _EmissionMap("自发光纹理", 2D) = "black" {}

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
            "Queue"="Geometry"
            "RenderType" = "Opaque" 
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
            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #pragma shader_feature_local_fragment _EMISSION
            
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS_CASCADE
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX

            #if _ADDITIONAL_LIGHTS_VERTEX
                #define  _ADDITIONAL_LIGHTS 
                #undef _ADDITIONAL_LIGHTS_VERTEX
            #endif
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
            
            #include "../Include/ActorShadowCaster.hlsl"

            ENDHLSL
        }
    }

    SubShader
    {
        Tags 
        {
            "Queue"="Geometry"
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

            #include "../Include/ActorForwardPassLow.hlsl"

            ENDHLSL
        }

    }

    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor"CustomShaderGUI2"
}

