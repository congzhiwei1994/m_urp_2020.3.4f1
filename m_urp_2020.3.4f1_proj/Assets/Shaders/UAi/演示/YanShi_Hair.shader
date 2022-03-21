Shader "末日/演示/Hair Shader"
{
    Properties
    {
        _AlphaClip("裁剪",Range(0, 1)) = 0.5
        [MainColor]_BaseColor("固有色颜色",color) = (1,1,1,1)
        [NoScaleOffset] [MainTexture] _BaseMap("固有色纹理", 2D) = "white" {}
        [NoScaleOffset]_NoiseMap("头发高光扭曲纹理", 2D) = "white" {}
        // _AOIntensity("顶点AO强度",Range(0,1)) = 1
        _IndirIntensity("环境光强度",Range(0,5)) = 1
        _HairColorA("第一层高光颜色",Color) = (0.5, 0.5, 0.5,1)
        [PowerSlider(3)]_NoiseIntensityA("第一层高光扭曲强度",Range(0,1)) = 0.5
        [PowerSlider(5)]_ShininessA("第一层高光范围",Range(0,1)) = 0.05
        [PowerSlider(3)]_HairShiftA("第一层高光位置",Range(-1,1)) = 0.5

        [Toggle(_DOUBLESPEC)] _DOUBLEENABLE("第二层高光开启", Float) = 0.0
        [if(_DOUBLESPEC)] _HairColorB("第二层高光颜色",Color) = (0.5, 0.5, 0.5,1)
        [if(_DOUBLESPEC)] [PowerSlider(3)]_NoiseIntensityB("第二层高光扭曲强度",Range(0,1)) = 0.5
        [if(_DOUBLESPEC)] [PowerSlider(5)]_ShininessB("第二层高光范围",Range(0,1)) = 0.05
        [if(_DOUBLESPEC)] [PowerSlider(3)]_HairShiftB("第二层高光位置",Range(-1,1)) = 0.5

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
            "RenderType" = "TransparentCutout" 
            "IgnoreProjector" = "True" 
            "RenderPipeline" = "UniversalPipeline" 
        }
        LOD 300
        
        Pass
        {
            Name "HairPassAlphaTest"
            Tags{"LightMode" = "HairPassAlphaTest"}
            
            Cull Back
            ZWrite on
            
            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local_fragment _DOUBLESPEC
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX

            #if _ADDITIONAL_LIGHTS_VERTEX
                #define  _ADDITIONAL_LIGHTS 
                #undef _ADDITIONAL_LIGHTS_VERTEX
            #endif
            
            #define Specular 
            #define AlphaClip
            #include "../Include/ActorHairPass.hlsl"
            
            ENDHLSL
        }
        
        Pass
        {
            Name "HairPassAlphaBlend"
            Tags{"LightMode" = "HairPassAlphaBlend"}
            Blend SrcAlpha OneMinusSrcAlpha
            ZWrite off
            ZTest Less

            HLSLPROGRAM
            
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0
            
            #pragma vertex vert
            #pragma fragment frag

            #pragma shader_feature_local_fragment _DOUBLESPEC
            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX

            #if _ADDITIONAL_LIGHTS_VERTEX
                #define  _ADDITIONAL_LIGHTS 
                #undef _ADDITIONAL_LIGHTS_VERTEX
            #endif
            
            #define Specular

            #include "../Include/ActorHairPass.hlsl"
            
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