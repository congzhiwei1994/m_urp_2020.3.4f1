
#ifndef ACTOR_COMMON_METHOD_INCLUDED
    #define ACTOR_COMMON_METHOD_INCLUDED

    // 透射
    #ifdef _TRANSMISISSION
        half3 TranslucencyColor(Light light, half thickness, half3 normalWS, half3 viewDirWS)
        {

            half mainLightShadowAtten = lerp(1, light.shadowAttenuation, 0.5);
            half NoL = saturate(dot(light.direction, normalWS));
            half3 attenColor = light.distanceAttenuation * mainLightShadowAtten * light.color;
            half transLightDir = normalize(light.direction + normalWS * _Distortion);
            half LoV = saturate(dot(-transLightDir, viewDirWS));
            half LoV_Pow = saturate(pow(LoV, _TranslucencyPower)) * _TranslucencyInt;
            
            half3 translucencyColor = LoV_Pow * attenColor * _TranslucencyColor.rgb;
            return translucencyColor;
        }
    #endif
    
    // 溶解特效
    #ifdef _DISSOLVE
        half3 DissolveColor(half4 dissolveFoctor)
        {
            half dissolbeDir = dissolveFoctor.y;
            half2 dissolveUV = dissolveFoctor.zw;
            half dissolveFactor = (_DissolveClip - dissolbeDir * (1 - _DissolveScale * 2)) / _DissolveScale;
            dissolveUV =  dissolveUV * _DissolveNoiseMap_ST.xy;
            half dissolveNoise = SAMPLE_TEXTURE2D(_DissolveNoiseMap, sampler_DissolveNoiseMap, dissolveUV).r;
            dissolveFactor = saturate(dissolveFactor - dissolveNoise);
            clip(dissolveFactor - 0.5);
            
            #ifdef ShadowCasterPass
                return 0;
            #else
                half2 dissolveRampMapUV = half2(dissolveFactor, dissolveFactor);
                half3 dissolveColor = SAMPLE_TEXTURE2D(_DissolveRampMap, sampler_DissolveRampMap, dissolveRampMapUV).rgb * _DissolveColor;
                return dissolveColor;
            #endif
        }
    #endif

    float3 ACESFilm(float3 x)
    {
        float a = 2.51f;
        float b = 0.03f;
        float c = 2.43f;
        float d = 0.59f;
        float e = 0.14f;
        return saturate((x*(a*x + b))/(x*(c*x+d) + e));
    } 
    
#endif