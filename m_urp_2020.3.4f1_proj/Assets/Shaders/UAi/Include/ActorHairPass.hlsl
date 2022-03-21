#ifndef ACTOR_HAIR_PASS_INCLUDED
    #define ACTOR_HAIR_PASS_INCLUDED

    #include "ActorInput.hlsl"
    #include "ActorLighting.hlsl"

    struct Attributes
    {
        float4 positionOS       : POSITION;
        float3 normalOS         : NORMAL;
        float4 tangentOS        :TANGENT;
        float2 uv               : TEXCOORD0;
        float4 color            : COLOR;
    };

    struct Varyings
    {
        float4 positionCS       : SV_POSITION;
        float2 uv               : TEXCOORD0;
        float fogCoord          : TEXCOORD1;
        half3 normalWS          : TEXCOORD2;
        half3 tangentWS         : TEXCOORD3;
        half3 bitangentWS       : TEXCOORD4;               
        half3 viewDirWS         : TEXCOORD5;
        float3 positionWS       : TEXCOORD6;
        float4 color            : TEXCOORD7;
        float3 vertexSH         : TEXCOORD8;
    };
    

    Varyings vert(Attributes v)
    {
        Varyings o = (Varyings)0;
        o.positionCS = TransformObjectToHClip(v.positionOS.xyz);
        o.uv = v.uv;
        half3 positionWS = TransformObjectToWorld(v.positionOS.xyz);
        o.positionWS = positionWS;

        o.normalWS = TransformObjectToWorldNormal(v.normalOS);
        o.tangentWS = TransformObjectToWorldDir(v.tangentOS.xyz);
        half sign = v.tangentOS.w * GetOddNegativeScale();
        o.bitangentWS = cross(o.normalWS, o.tangentWS) * sign;
        o.vertexSH = SampleSHVertex(o.normalWS.xyz);
        o.viewDirWS = SafeNormalize(GetCameraPositionWS() - positionWS);
        o.color = v.color;
        
        return o;
    }

    half4 frag(Varyings i) : SV_Target
    {

        half2 baseMap_uv =  i.uv * _BaseMap_ST.xy + _BaseMap_ST.zw;
        half4 baseMap = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, baseMap_uv) * _BaseColor;
        
        #ifdef AlphaClip
            clip(baseMap.a - _AlphaClip);
        #endif

        #ifdef Specular
            half2 hairNoise_uv =  i.uv * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
            half hairNoise= SAMPLE_TEXTURE2D(_NoiseMap, sampler_NoiseMap, hairNoise_uv).r;
            hairNoise  = (hairNoise * 2 - 1);
        #endif

        HairData hairData;
        ZERO_INITIALIZE(HairData, hairData);
        hairData.shadowCoord = TransformWorldToShadowCoord(i.positionWS);
        hairData.albedo = baseMap.rgb;
        hairData.ao = 1;
        hairData.normalWS = i.normalWS;
        #ifdef Specular
            hairData.tangentWS = i.tangentWS;
            hairData.bitangentWS = i.bitangentWS;
            hairData.positionWS = i.positionWS;
            hairData.viewDirWS = i.viewDirWS;
            hairData.noiseShift = _HairShiftA + hairNoise * _NoiseIntensityA;
            #ifdef _DOUBLESPEC
                hairData.noiseShiftB = _HairShiftB + hairNoise * _NoiseIntensityB;
            #endif
        #endif 
        hairData.sh = SampleSHPixel(i.vertexSH, i.normalWS) * _IndirIntensity;
        
        half3 color = HairFragementLighting(hairData);
        return half4(color, baseMap.a);
    }

#endif
