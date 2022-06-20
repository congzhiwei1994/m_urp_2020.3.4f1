// @ https://www.zhihu.com/people/jefford-55


Shader "URP/RiverWater"
{
    Properties
    {
        _ShallowColor("浅水颜色", Color) = (0.5,0.5,0.5,1)
        _DeepColor("深水颜色", Color) = (0.5,0.5,0.5,1)
        _DepthRange("深度范围",range(0.1,1)) = 0.5
        _WaterDir("水流方向",Vector) = (0,1,0,0)
        _CustormLightDir("自定义灯光方向",vector) = (-0.64,-1,0,0)
        _SpecularColor("高光颜色", Color) = (0.5,0.5,0.5,1)
        _Smoothness("光滑度", Range(0.0, 1.0)) = 0
        _SpecularRange("高光范围",range(0.1,1)) = 0.5
        _SpecularIntensity("高光强度", Range(0.0, 1.0)) = 0
        _CustormLightColor("自定义灯光颜色", Color) = (1,1,1,1)
        _CustormLightRange("自定义灯光范围",range(0.1,1)) = 0.5
        _CustormLightIntensity("自定义灯光强度", Range(0.0, 1.0)) = 0

        _FresnelColor("菲涅尔颜色", Color) = (0.5,0.5,0.5,1)
        _FresnelRange("菲涅尔范围",Range(0,1)) = 0.5
        _FresnelIntensity("菲涅尔强度",Range(0,1)) = 0.5
        _StartTilling("星光图纹理缩放",range(0,1)) = 0.5
        _StartSpeed("星光噪点速度",Range(0,1)) = 0.5
        _StartIntensity("星光强度",Range(0,1)) = 1
        _FoamRange("泡沫范围",Range(0.1,1)) = 0.5
        _FoamIntensity("泡沫强度",Range(0,1)) = 1
        _BumpScale("法线强度", Range(0,1)) = 1.0
        _NormalTilling("法线缩放",range(0,1)) = 1
        _NoiseScale("第二层高光强度", Range(0,1)) = 1.0
        [Toggle(IsNegate)] _IsNehateEnable("CubeMap是否反向",float) = 0
        [NoScaleOffset] _WaterNormalMap("法线扭曲纹理", 2D) = "bump" {}
        [NoScaleOffset] _StartMap("星光纹理", 2D) = "white" {}
        [NoScaleOffset] _DepthMap("深度纹理", 2D) = "white" {}
        [NoScaleOffset] _FoamMap("泡沫纹理", 2D) = "white" {}
        [NoScaleOffset] _CubeMap("环境反射纹理", Cube) = "white" {}
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


        Pass
        {

            Name "ForwardLit"
            Tags
            {
                "LightMode" = "UniversalForward"
            }


            HLSLPROGRAM
            #pragma prefer_hlslcc gles
            #pragma exclude_renderers d3d11_9x
            #pragma target 2.0

            #pragma multi_compile _ _MAIN_LIGHT_SHADOWS
            #pragma multi_compile _ _ADDITIONAL_LIGHTS_VERTEX
            #pragma multi_compile_fog
            #pragma  shader_feature_local_fragment IsNegate

            #pragma vertex LitPassVertex
            #pragma fragment LitPassFragment

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.core/ShaderLibrary/CommonMaterial.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/SurfaceInput.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"


            CBUFFER_START(UnityPerMaterial)
            half3 _ShallowColor;
            half3 _DeepColor;
            half _DepthRange;
            half2 _WaterDir;
            half3 _CustormLightDir;
            half _BumpScale;
            half _NormalTilling;
            half _Smoothness;
            half _SpecularRange;
            half _SpecularIntensity;
            half3 _FresnelColor;
            half _FresnelRange;
            half _FresnelIntensity;
            half _StartSpeed;
            half _StartIntensity;
            half _FoamRange;
            half _FoamIntensity;
            half4 _CubeMap_HDR;
            half3 _CustormLightColor;
            half _StartTilling;
            half _NoiseScale;
            half _CustormLightRange;
            half _CustormLightIntensity;
            half3 _SpecularColor;
            CBUFFER_END

            TEXTURE2D(_WaterNormalMap);
            SAMPLER(sampler_WaterNormalMap);

            TEXTURE2D(_StartMap);
            SAMPLER(sampler_StartMap);
            TEXTURE2D(_DepthMap);
            SAMPLER(sampler_DepthMap);
            TEXTURE2D(_FoamMap);
            SAMPLER(sampler_FoamMap);
            TEXTURECUBE(_CubeMap);
            SAMPLER(sampler_CubeMap);


            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS : NORMAL;
                float4 tangentOS : TANGENT;
                float2 texcoord : TEXCOORD0;
            };

            struct Varyings
            {
                float2 uv : TEXCOORD0;
                half3 vertexSH :TEXCOORD1;
                float3 positionWS : TEXCOORD2;
                float4 normalWS : TEXCOORD3;
                float4 tangentWS : TEXCOORD4;
                float4 bitangentWS : TEXCOORD5;
                half4 fogFactorAndVertexLight : TEXCOORD6;
                float4 positionCS : SV_POSITION;
            };


            half3 GlossyEnvironmentReflection1(half3 viewDirWS, half3 normalWS, half perceptualRoughness)
            {
                half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
                #ifdef  IsNegate
                viewDirWS = viewDirWS;
                #else
                viewDirWS = -viewDirWS;
                #endif

                half3 reflectVector = reflect(viewDirWS, normalWS);
                half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(_CubeMap, sampler_CubeMap, reflectVector, mip);

                #if !defined(UNITY_USE_NATIVE_HDR)
                half3 irradiance = DecodeHDREnvironment(encodedIrradiance, _CubeMap_HDR);
                #else
                        half3 irradiance = encodedIrradiance.rbg;
                #endif
                return irradiance;
            }


            half3 GlobalIllumination1(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS,
                                      half3 viewDirectionWS)
            {
                half3 reflectVector = reflect(-viewDirectionWS, normalWS);
                half fresnelTerm = Pow4(1.0 - saturate(dot(normalWS, viewDirectionWS)));

                half3 indirectDiffuse = bakedGI * occlusion * brdfData.diffuse;
                half3 ibl = GlossyEnvironmentReflection1(reflectVector, brdfData.perceptualRoughness, occlusion);

                float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
                half3 indirectSpecular = surfaceReduction * ibl * lerp(brdfData.specular, brdfData.grazingTerm,
                                                                       fresnelTerm);

                half3 indirect = indirectDiffuse + indirectSpecular;
                return indirect;
            }


            half4 UniversalFragmentPBR1(InputData inputData, half3 albedo, half metallic, half3 specular,
                                        half smoothness, half occlusion, half3 emission, half alpha)
            {
                BRDFData brdfData;
                InitializeBRDFData(albedo, metallic, specular, smoothness, alpha, brdfData);

                Light mainLight = GetMainLight(inputData.shadowCoord);
                MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

                half3 color = GlobalIllumination1(brdfData, inputData.bakedGI, occlusion, inputData.normalWS,
                                                  inputData.viewDirectionWS);
                color += LightingPhysicallyBased(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS);

                #ifdef _ADDITIONAL_LIGHTS
                    uint pixelLightCount = GetAdditionalLightsCount();
                    for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
                    {
                        Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
                        color += LightingPhysicallyBased(brdfData, light, inputData.normalWS, inputData.viewDirectionWS);
                    }
                #endif

                #ifdef _ADDITIONAL_LIGHTS_VERTEX
                    color += inputData.vertexLighting * brdfData.diffuse;
                #endif

                color += emission;
                return half4(color, alpha);
            }

            // ----------------------------------------------------------------------------------------------------

            Varyings LitPassVertex(Attributes v)
            {
                Varyings o = (Varyings)0;

                o.uv = v.texcoord;
                o.positionWS = mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)).xyz;
                o.positionCS = mul(UNITY_MATRIX_VP, mul(UNITY_MATRIX_M, float4(v.positionOS.xyz, 1.0)));

                // ------------ 法线 ------------
                half3 normalWS;
                {
                    #ifdef UNITY_ASSUME_UNIFORM_SCALING
                        normalWS = SafeNormalize(mul((float3x3)UNITY_MATRIX_M, v.normalOS));
                    #else
                    // Normal need to be multiply by inverse transpose
                    normalWS = SafeNormalize(mul(v.normalOS, (float3x3)UNITY_MATRIX_I_M));
                    #endif
                }

                // ------------ 切线 ------------
                half3 tangentWS = mul((float3x3)UNITY_MATRIX_M, v.tangentOS.xyz);
                tangentWS = SafeNormalize(tangentWS);

                // ------------ 副切线 ------------
                half sign = v.tangentOS.w * unity_WorldTransformParams.w;
                half3 bitangentWS = cross(normalWS, tangentWS) * sign;

                // ------------ 视线 ------------
                half3 viewDirWS = _WorldSpaceCameraPos - o.positionWS;

                o.normalWS = half4(normalWS, viewDirWS.x);
                o.tangentWS = half4(tangentWS, viewDirWS.y);
                o.bitangentWS = half4(bitangentWS, viewDirWS.z);

                half3 vertexLight = VertexLighting(o.positionWS, normalWS);
                half fogFactor = ComputeFogFactor(o.positionCS.z);
                o.fogFactorAndVertexLight = half4(fogFactor, vertexLight);

                OUTPUT_SH(o.normalWS.xyz, o.vertexSH);

                return o;
            }


            half4 LitPassFragment(Varyings i) : SV_Target
            {
                half3 viewDirWS = NormalizeNormalPerPixel(half3(i.normalWS.w, i.tangentWS.w, i.bitangentWS.w));


                half2 worldUV = i.positionWS.xz;
                half2 waterSpeed = _Time.y * _WaterDir * 0.1;

                half4 foamMap = SAMPLE_TEXTURE2D(_FoamMap, sampler_FoamMap, worldUV);
                // 法线计算
                half2 normalUV_A = worldUV * _NormalTilling * 0.1;
                half4 normalMap_A = SAMPLE_TEXTURE2D(_WaterNormalMap, sampler_WaterNormalMap, normalUV_A);
                half3 normapTS_A = UnpackNormalScale(normalMap_A, 0.15);

                half2 normalUV_B = normalUV_A * 2 + waterSpeed + normapTS_A.xz;
                half4 normalMap_B = SAMPLE_TEXTURE2D(_WaterNormalMap, sampler_WaterNormalMap, normalUV_B);
                half3 normapTS_B = UnpackNormalScale(normalMap_B, _BumpScale);
                half3 normalTS = BlendNormal(normapTS_A, normapTS_B);

                half3x3 tbn = half3x3(i.tangentWS.xyz, i.bitangentWS.xyz, i.normalWS.xyz);
                float3 normalWS = NormalizeNormalPerPixel(mul(normalTS, tbn));

                half3 cubeMap = GlossyEnvironmentReflection1(viewDirWS, normalWS, 1 - saturate(_Smoothness));
                // R:depth G:foamMask
                half2 depthMap = SAMPLE_TEXTURE2D(_DepthMap, sampler_DepthMap, i.uv);
                half depth = pow(depthMap, exp(_DepthRange));
                half3 waterColor = lerp(_DeepColor, _ShallowColor, depth);
                Light mainLight = GetMainLight();
                half NoL = saturate(dot(half3(0, 1, 0), normalWS));
                half3 diffuse = NoL * waterColor * mainLight.color;

                half3 halfDir = SafeNormalize(normalize(_CustormLightDir) + viewDirWS);
                half NoH = saturate(dot(halfDir, normalWS));

                half3 negateHalfDir = SafeNormalize(normalize(_CustormLightDir) + -viewDirWS);
                half nagateNoH = saturate(dot(negateHalfDir, normalWS));

                half custormLightRange = pow(nagateNoH, exp(_CustormLightRange * 5));
                custormLightRange += custormLightRange * 20;

                half specularRange = pow(NoH, exp(_SpecularRange * 8));
                half3 specular = specularRange * mainLight.color * _SpecularIntensity * _SpecularColor +
                    custormLightRange * _CustormLightColor * _CustormLightIntensity;

                specular = specularRange * mainLight.color * _SpecularIntensity * _SpecularColor;

                half NoV = saturate(dot(normalWS, viewDirWS));

                half3 fresnel = pow(1 - NoV, exp(_FresnelRange * 5)) * _FresnelIntensity;
                half3 color = lerp(diffuse + specular, _FresnelColor, fresnel) + cubeMap;

                half2 startUV = worldUV * _StartTilling;
                half2 startSpeed = half2(0.05, 0.1) * _Time.y;
                half3 startMap_A = SAMPLE_TEXTURE2D(_StartMap, sampler_StartMap, startUV + startSpeed);
                half3 startMap_B = SAMPLE_TEXTURE2D(_StartMap, sampler_StartMap, startUV * 0.5 + startSpeed * -0.5);
                half3 startMap = startMap_A * startMap_B;
                half start = startMap.x + startMap.y + startMap.z;
                start *= custormLightRange * 10 * _StartIntensity;
                // return start;

                half3 sh = SampleSHPixel(i.vertexSH, normalWS);

                color = color + start;
                return color.xyzz;


                // SurfaceData surfaceData;
                // ZERO_INITIALIZE(SurfaceData, surfaceData);
                // surfaceData.albedo = albedo.rgb;
                // surfaceData.alpha = albedo.a;
                // surfaceData.metallic = saturate(mixMap.r * _Metallic);
                // surfaceData.specular = half3(0.0h, 0.0h, 0.0h);
                // surfaceData.smoothness = saturate(mixMap.g * _Smoothness);
                // surfaceData.normalTS = normapTS;
                // surfaceData.occlusion = saturate(mixMap.b * _OcclusionStrength);
                // surfaceData.emission = 0;
                //
                // // --------------------------------------- 数据 ---------------------------------------
                // half3 viewDirWS = half3(i.normalWS.w, i.tangentWS.w, i.bitangentWS.w);
                //
                //
                // // --------------------------------------- InputData ---------------------------------------
                // InputData inputData;
                // ZERO_INITIALIZE(InputData, inputData);
                // inputData.positionWS = i.positionWS;
                //
                // inputData.normalWS = mul(surfaceData.normalTS, tbn);
                // inputData.normalWS = NormalizeNormalPerPixel(inputData.normalWS);
                // inputData.viewDirectionWS = SafeNormalize(viewDirWS);
                //
                // #if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
                //     inputData.shadowCoord = i.shadowCoord;
                // #elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
                //     inputData.shadowCoord = TransformWorldToShadowCoord(inputData.positionWS);
                // #else
                // inputData.shadowCoord = float4(0, 0, 0, 0);
                // #endif
                //
                // inputData.fogCoord = i.fogFactorAndVertexLight.x;
                // inputData.vertexLighting = i.fogFactorAndVertexLight.yzw;
                // inputData.bakedGI = SAMPLE_GI(i.lightmapUV, i.vertexSH, inputData.normalWS);
                //
                // half4 color = UniversalFragmentPBR1(inputData, surfaceData.albedo, surfaceData.metallic,
                //                                     surfaceData.specular, surfaceData.smoothness, surfaceData.occlusion,
                //                                     surfaceData.emission, surfaceData.alpha);
                //
                // color.rgb = MixFog(color.rgb, inputData.fogCoord);
                // return color;
            }
            ENDHLSL
        }
    }
    FallBack "Hidden/Universal Render Pipeline/FallbackError"
    // CustomEditor "UnityEditor.Rendering.Universal.ShaderGUI.LitShader"
}