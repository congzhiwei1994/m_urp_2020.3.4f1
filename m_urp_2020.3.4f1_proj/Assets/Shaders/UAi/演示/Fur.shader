
Shader "末日/演示/绒毛"
{
    Properties
    {
        // _FurClip("绒毛裁剪",Range(0,1)) = 0.5
        [MainColor] _BaseColor("基础颜色", Color) = (1,1,1,1)
        [NoScaleOffset] [MainTexture] _BaseMap("固有色纹理", 2D) = "white" {}
        [NoScaleOffset] _NoiseMap("绒毛生成纹理", 2D) = "white" {}
        _NoiseTilling("毛发生成纹理缩放",Range(1,5)) = 3
        [NoScaleOffset]_NormalCustorm("法线纹理",2D) = "bump"{}
        _1UNormalTilling("法线缩放A",Range(0,50)) = 1
        [PowerSlider(3)]_NormalScaleA("法线强度A",Range(0,1)) = 0.2
        _NormalTillingB("法线缩放B",Range(0,50)) = 1
        [PowerSlider(3)]_NormalScaleB("法线强度B",Range(0,1)) = 0.2

        _SpecularColor("高光颜色",Color) = (0.5, 0.5, 0.5, 1)
        _AO("AO强度",Range(0,1)) = 1
        _Smoothnee("光滑度",Range(0.001,3)) = 1

        [PowerSlider(3)] _FurLength("毛发长度",Range(0,1)) = 0.5
        _FurDir("毛发方向",vector) = (0,0,0,0)

        _FresnelPow("外发光范围",Range(0.01,2)) = 0.3
        _FresnelIntensity("外发光强度",Range(0.01,1)) = 0.3

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
            "Queue"="Transparent"
            "RenderType" = "Transparent" 
            "RenderPipeline" = "UniversalPipeline"
            "IgnoreProjector" = "True"
        }

        LOD 300

        Pass
        {
            Name "ParllRender"
            Tags{ "LightMode" = "ParllFeatureB"}

            HLSLPROGRAM

            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX

            #if _ADDITIONAL_LIGHTS_VERTEX
                #define  _ADDITIONAL_LIGHTS 
                #undef _ADDITIONAL_LIGHTS_VERTEX
            #endif
            
            #include "../Include/ActorFurPass.hlsl"
            

            ENDHLSL
        }

        Pass
        {
            Name "ParllRender"
            Tags{ "LightMode" = "ParllFeatureL"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX

            #if _ADDITIONAL_LIGHTS_VERTEX
                #define  _ADDITIONAL_LIGHTS 
                #undef _ADDITIONAL_LIGHTS_VERTEX
            #endif
            
            #include "../Include/ActorFurPass.hlsl"

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
            
            #pragma vertex LitPassVertexLow
            #pragma fragment LitPassFragmentLow

            #include "../Include/ActorForwardPassLow.hlsl"
            ENDHLSL
        }
        
    }


    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    CustomEditor"CustomShaderGUI2"
}

