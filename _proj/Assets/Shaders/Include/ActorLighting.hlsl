#ifndef ACTOR_LIGHTING_INCLUDED
    #define ACTOR_LIGHTING_INCLUDED

    // 绒毛
    struct FurData
    {
        float3 normalWS;
        float4 shadowCoord;
        float3 vertexNormal;
        float3 viewDir;
        half3 sh;
        half ao;
        half alpha;
        half noiseMap;
        float3 positionWS;
        half3 albedo;
    };

    half3 Diffuse( Light light, FurData furData)
    {
        half3 attenColor = light.distanceAttenuation *  light.shadowAttenuation * light.color;
        half NoL = saturate(dot(light.direction, furData.normalWS));
        half3 diffuse = NoL * furData.albedo * furData.ao * attenColor;
        return diffuse;
    }

    half3 FurSpecular(Light light, FurData furData)
    {
        half3 attenColor = light.distanceAttenuation *  light.shadowAttenuation * light.color;
        float3 H = SafeNormalize(light.direction + furData.viewDir);
        half NoH = saturate(dot(furData.normalWS, H));
        half spec = pow(NoH, exp(_Smoothnee * 3 * (1 - furData.noiseMap)));
        half3 specColor = spec * _SpecularColor * furData.ao * furData.albedo;
        return specColor;
        
    }

    half3 FurLighting(FurData furData)
    {
        Light mainLight = GetMainLight(furData.shadowCoord);
        half3 diffuse = Diffuse( mainLight, furData);
        half3 specular = FurSpecular(mainLight, furData);

        half NoV = saturate(dot(furData.vertexNormal, furData.viewDir));
        half fresnel = saturate(pow((1 - NoV), exp(_FresnelPow)));
        half3 bakedGI = lerp(furData.sh * furData.albedo, furData.sh * _FresnelIntensity * 5, fresnel);

        half3 c = diffuse + specular;
        c += bakedGI;

        #ifdef _ADDITIONAL_LIGHTS
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
            {
                Light light = GetAdditionalLight(lightIndex, furData.positionWS);
                c += Diffuse( light, furData);
                c += FurSpecular(light, furData);
            }
        #endif
        return c;
        
    }

    // ------------------------------------ KJY 各向异性
    struct HairData
    {
        half3 albedo;
        half ao;
        half3 sh;
        half noiseShift;
        half noiseShiftB;
        float3 normalWS;
        float3 tangentWS;
        float3 bitangentWS;
        float3 viewDirWS;
        float3 positionWS;
        float4 shadowCoord;
    };

    half3 HairDiffuse( Light light, half3 albedo, half3 normalWS)
    {
        half NoL = saturate(dot(normalWS, light.direction)) * 0.9 + 0.1;
        half3 radiance = NoL * light.shadowAttenuation * light.color * light.distanceAttenuation;
        return albedo * radiance;
    }

    half3 HairSpecualr( Light light, HairData hairData)
    {
        
        half3 shadowColor = light.shadowAttenuation * light.distanceAttenuation * light.color;

        half3 shiftTangent = normalize(hairData.bitangentWS + hairData.normalWS * hairData.noiseShift);
        #ifdef _DOUBLESPEC
            half3 shiftTangentB = normalize(hairData.bitangentWS + hairData.normalWS * hairData.noiseShiftB);
        #endif

        float3 H = SafeNormalize(light.direction + hairData.viewDirWS);
        half NoV = dot(hairData.normalWS, hairData.viewDirWS);
        half BoH = dot(shiftTangent, H) / _ShininessA;
        #ifdef _DOUBLESPEC
            half BoH_B = dot(shiftTangentB, H) / _ShininessB;
        #endif
        half ToH = dot(hairData.tangentWS, H);
        half NoH = dot(hairData.normalWS, H);
        half NoL = saturate(dot(hairData.normalWS, light.direction));

        half noiseAtten = saturate(sqrt(max(0,NoL / NoV)));
        half specTerm = exp(-(ToH * ToH + BoH * BoH) / (1 + NoH));
        half3 specular = specTerm * _HairColorA.rgb;

        #ifdef _DOUBLESPEC
            half specTermB = exp(-(ToH * ToH + BoH_B * BoH_B) / (1 + NoH));
            half3 specularB = specTermB * _HairColorB.rgb;
            specular += specularB;
        #endif
        half3 c = specular * shadowColor * noiseAtten;

        return c;
    }


    half3 HairFragementLighting(HairData hairData)
    {
        half3 c;
        Light mainLight = GetMainLight(hairData.shadowCoord);
        half3 indirectDiffuse = hairData.sh * hairData.albedo;
        c = HairDiffuse(mainLight, hairData.albedo, hairData.normalWS) * hairData.ao;
        c += indirectDiffuse;
        #ifdef Specular
            c += HairSpecualr(mainLight, hairData) * hairData.ao;
        #endif

        #ifdef _ADDITIONAL_LIGHTS
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
            {
                Light light = GetAdditionalLight(lightIndex, hairData.positionWS);

                c += HairDiffuse(light, hairData.albedo, hairData.normalWS) * hairData.ao;
                #ifdef Specular
                    c += HairSpecualr(light, hairData) * hairData.ao;
                #endif 
            }
        #endif
        // c = ACESFilm(c);
        return c;
    }



    // --------------------------------------------------- GGX 各向异性 ----------------------------------------------

    // Ref: https://knarkowicz.wordpress.com/2018/01/04/cloth-shading/
    real D_CharlieNoPI_Lux(real NdotH, real roughness)
    {
        float invR = rcp(roughness);
        float cos2h = NdotH * NdotH;
        float sin2h = 1.0 - cos2h;
        // Note: We have sin^2 so multiply by 0.5 to cancel it
        return (2.0 + invR) * PositivePow(sin2h, invR * 0.5) / 2.0;
    }

    real D_Charlie_Lux(real NdotH, real roughness)
    {
        return INV_PI * D_CharlieNoPI_Lux(NdotH, roughness);
    }

    // We use V_Ashikhmin instead of V_Charlie in practice for game due to the cost of V_Charlie
    real V_Ashikhmin_Lux(real NoL, real NdotV)
    {
        // Use soft visibility term introduce in: Crafting a Next-Gen Material Pipeline for The Order : 1886
        return 1.0 / (4.0 * (NoL + NdotV - NoL * NdotV));
    }

    // A diffuse term use with fabric done by tech artist - empirical
    real FabricLambertNoPI_Lux(real roughness)
    {
        return lerp(1.0, 0.5, roughness);
    }

    real FabricLambert_Lux(real roughness)
    {
        return INV_PI * FabricLambertNoPI_Lux(roughness);
    }

    struct AdditionalData 
    {
        half3   tangentWS;
        half3   bitangentWS;
        float   partLambdaV;
        half    roughnessT;
        half    roughnessB;
        half3   anisoReflectionNormal;
        half3   sheenColor;
    };

    half3 IndirectLighting(BRDFData brdfData, SurfaceData surfaceData, InputData inputData, AdditionalData addData)
    {
        half3 indirectDiffuse = inputData.bakedGI * surfaceData.occlusion * brdfData.diffuse; 

        half3 reflectVector = reflect(-inputData.viewDirectionWS, addData.anisoReflectionNormal);
        half NoV = saturate(dot(addData.anisoReflectionNormal, inputData.viewDirectionWS));
        half fresnelTerm = Pow4(1.0 - NoV);
        half mip = PerceptualRoughnessToMipmapLevel(brdfData.perceptualRoughness);
        half4 envCubeMap = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);
        half3 ibl = DecodeHDREnvironment(envCubeMap, unity_SpecCube0_HDR) * surfaceData.occlusion;
        float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
        half3 indirectSpecular = ibl * surfaceReduction * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);
        half3 c = indirectSpecular + indirectDiffuse;
        return c;
    }
    

    half3 DirectBDRF_LuxCloth(BRDFData brdfData, Light light, AdditionalData addData, InputData inputData)
    {
        half lightAttenuation = light.distanceAttenuation * light.shadowAttenuation;
        half NoL = saturate(dot(inputData.normalWS, light.direction));
        half halfLambert = NoL * 0.8 + 0.2;
        half3 diffuse = brdfData.diffuse * halfLambert * light.color * lightAttenuation;
        half3 radiance = light.color * lightAttenuation * NoL;

        float3 halfDir = SafeNormalize(light.direction + inputData.viewDirectionWS);
        float NoH = saturate(dot(inputData.normalWS, halfDir));
        half LoH = saturate(dot(light.direction, halfDir));
        half NdotV = saturate(dot(inputData.normalWS, inputData.viewDirectionWS ));
        float TdotH = dot(addData.tangentWS, halfDir);
        float TdotL = dot(addData.tangentWS, light.direction);
        float BdotH = dot(addData.bitangentWS, halfDir);
        float BdotL = dot(addData.bitangentWS, light.direction);

        float3 F = F_Schlick(brdfData.specular, LoH);
        float DV = DV_SmithJointGGXAniso( TdotH, BdotH, NoH, NdotV, TdotL, BdotL, NoL,addData.roughnessT, addData.roughnessB, addData.partLambdaV);
        half3 specularLighting = F * DV;

        half3 c = specularLighting * radiance;
        
        return c + diffuse;
    }

    half3 GGXAnisotropicFragment(InputData inputData, SurfaceData surfaceData,half3 tangentWS,half3 bitangentWS, half thickness)
    {

        BRDFData brdfData;
        ZERO_INITIALIZE(BRDFData, brdfData);
        half reflectivity = ReflectivitySpecular(surfaceData.specular);
        half oneMinusReflectivity = 1.0 - reflectivity;
        half3 brdfDiffuse = surfaceData.albedo * (half3(1.0h, 1.0h, 1.0h) - surfaceData.specular);
        half3 brdfSpecular = surfaceData.specular;
        InitializeBRDFDataDirect(brdfDiffuse, brdfSpecular, reflectivity, oneMinusReflectivity, surfaceData.smoothness, surfaceData.alpha, brdfData);
        brdfData.diffuse = surfaceData.albedo;
        brdfData.specular = surfaceData.specular;

        half ToV = dot(tangentWS,  inputData.viewDirectionWS);
        half BoV = dot(bitangentWS,  inputData.viewDirectionWS);
        half NoV = dot(inputData.normalWS,  inputData.viewDirectionWS);
        half3 grainDirWS = (_GGXAnisotropy >= 0.0) ? bitangentWS : tangentWS;
        half stretch = abs(_GGXAnisotropy) * saturate(1.5h * sqrt(brdfData.perceptualRoughness));

        AdditionalData addData;
        ZERO_INITIALIZE(AdditionalData, addData);
        addData.bitangentWS = normalize(-cross(inputData.normalWS, tangentWS));
        addData.tangentWS = cross(inputData.normalWS, addData.bitangentWS);
        addData.roughnessT = brdfData.roughness * (1 + _GGXAnisotropy);
        addData.roughnessB = brdfData.roughness * (1 - _GGXAnisotropy);
        addData.partLambdaV = GetSmithJointGGXAnisoPartLambdaV(ToV, BoV, NoV, addData.roughnessT, addData.roughnessB);
        addData.anisoReflectionNormal = GetAnisotropicModifiedNormal(grainDirWS, inputData.normalWS,  inputData.viewDirectionWS, stretch);
        addData.sheenColor = 0;
        brdfData.perceptualRoughness = brdfData.perceptualRoughness * saturate(1.2 - abs(_GGXAnisotropy));

        Light mainLight = GetMainLight(inputData.shadowCoord);
        half3 indirect = IndirectLighting(brdfData, surfaceData, inputData, addData);
        half3 direct = DirectBDRF_LuxCloth(brdfData, mainLight, addData, inputData);
        half3 c = 0;
        c.rgb = indirect + direct;

        #ifdef _ADDITIONAL_LIGHTS
            int pixelLightCount = GetAdditionalLightsCount();
            for (int j = 0; j < pixelLightCount; ++j)
            {
                Light light = GetAdditionalLight(j, inputData.positionWS);
                c.rgb += DirectBDRF_LuxCloth(brdfData, light, addData, inputData);
            }
        #endif
        return c;
    }

    // ------------------------------------- PBR -------------------------------------------------
    half3 GlossyEnvironmentReflection1(half3 reflectVector, half perceptualRoughness, half occlusion)
    {
        half mip = PerceptualRoughnessToMipmapLevel(perceptualRoughness);
        half4 encodedIrradiance = SAMPLE_TEXTURECUBE_LOD(unity_SpecCube0, samplerunity_SpecCube0, reflectVector, mip);
        half3 irradiance = DecodeHDREnvironment(encodedIrradiance, unity_SpecCube0_HDR);
        return irradiance * occlusion;
    }
    

    half3 GlobalIllumination1(BRDFData brdfData, half3 bakedGI, half occlusion, half3 normalWS, half3 viewDirectionWS)
    {
        half3 reflectVector = reflect(-viewDirectionWS, normalWS);
        half fresnelTerm = Pow4(1.0 - saturate(dot(normalWS, viewDirectionWS)));

        half3 indirectDiffuse = bakedGI * occlusion * brdfData.diffuse;
        half3 ibl = GlossyEnvironmentReflection1(reflectVector, brdfData.perceptualRoughness, occlusion);

        float surfaceReduction = 1.0 / (brdfData.roughness2 + 1.0);
        half3 indirectSpecular = surfaceReduction * ibl * lerp(brdfData.specular, brdfData.grazingTerm, fresnelTerm);

        half3 indirect = indirectDiffuse + indirectSpecular;
        return indirect;
    }

    half3 DirectBDRF1(BRDFData brdfData, half3 normalWS, half3 lightDirectionWS, half3 viewDirectionWS)
    {
        
        float3 halfDir = SafeNormalize(float3(lightDirectionWS) + float3(viewDirectionWS));

        float NoH = saturate(dot(normalWS, halfDir));
        half LoH = saturate(dot(lightDirectionWS, halfDir));
        float d = NoH * NoH * brdfData.roughness2MinusOne + 1.00001f;
        half LoH2 = LoH * LoH;
        half specularTerm = brdfData.roughness2 / ((d * d) * max(0.1h, LoH2) * brdfData.normalizationTerm);
        #if defined (SHADER_API_MOBILE) || defined (SHADER_API_SWITCH)
            specularTerm = specularTerm - HALF_MIN;
            specularTerm = clamp(specularTerm, 0.0, 100.0); 
        #endif

        half3 color = specularTerm * brdfData.specular + brdfData.diffuse;
        return color;
    }

    half3 LightingPhysicallyBased1(BRDFData brdfData, Light light, half3 normalWS, half3 viewDirectionWS)
    {
        half lightAttenuation = light.distanceAttenuation ;
        half3 lightDirectionWS = light.direction;
        half3 lightColor = light.color;
        half NdotL = saturate(dot(normalWS, lightDirectionWS));
        half3 radiance = lightColor * (lightAttenuation * NdotL) * light.shadowAttenuation;
        return DirectBDRF1(brdfData, normalWS, lightDirectionWS, viewDirectionWS) * radiance;
    }

    half3 UniversalFragmentPBR1(InputData inputData, half3 albedo, half metallic, half3 specular,
    half smoothness, half occlusion, half3 emission, half alpha)
    {
        BRDFData brdfData;
        InitializeBRDFData(albedo, metallic, specular, smoothness, alpha, brdfData);
        
        Light mainLight = GetMainLight(inputData.shadowCoord);
        MixRealtimeAndBakedGI(mainLight, inputData.normalWS, inputData.bakedGI, half4(0, 0, 0, 0));

        half3 indirect = GlobalIllumination1(brdfData, inputData.bakedGI, occlusion, inputData.normalWS, inputData.viewDirectionWS);
        half3 direct = LightingPhysicallyBased1(brdfData, mainLight, inputData.normalWS, inputData.viewDirectionWS) * occlusion;
        half3 color = indirect + direct;

        #ifdef _TRANSMISISSION
            color += TranslucencyColor(mainLight, inputData.fogCoord, inputData.normalWS, inputData.viewDirectionWS) * brdfData.diffuse;
        #endif
        #ifdef _ADDITIONAL_LIGHTS
            uint pixelLightCount = GetAdditionalLightsCount();
            for (uint lightIndex = 0u; lightIndex < pixelLightCount; ++lightIndex)
            {
                Light light = GetAdditionalLight(lightIndex, inputData.positionWS);
                color += LightingPhysicallyBased1(brdfData, light, inputData.normalWS, inputData.viewDirectionWS);
                #ifdef _TRANSMISISSION
                    color += TranslucencyColor(light, inputData.fogCoord, inputData.normalWS, inputData.viewDirectionWS) * brdfData.diffuse;
                #endif
            }
        #endif

        #ifdef _ADDITIONAL_LIGHTS_VERTEX
            color += inputData.vertexLighting * brdfData.diffuse;
        #endif

        color += emission;
        return color;
    }

#endif
