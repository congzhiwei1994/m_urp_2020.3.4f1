// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Jefford/River"
{
	Properties
	{
		[HideInInspector] _EmissionColor("Emission Color", Color) = (1,1,1,1)
		[HideInInspector] _AlphaCutoff("Alpha Cutoff ", Range(0, 1)) = 0.5
		[ASEBegin]_NormalMap("NormalMap", 2D) = "bump" {}
		_NormalTilling_A("NormalTilling_A", Range( 0 , 10)) = 1
		_NormalTilling_B("NormalTilling_B", Range( 0 , 10)) = 1
		_NormalScale_A("NormalScale_A", Range( 0 , 1)) = 0
		_NormalScale_B("NormalScale_B", Range( 0 , 1)) = 0
		_WaterDir("WaterDir", Vector) = (0,0,0,0)
		_CustormLight_X("CustormLight_X", Range( -1 , 1)) = 0
		_CustormLight_Y("CustormLight_Y", Range( -1 , 1)) = 0
		_CustormLight_Z("CustormLight_Z", Range( -1 , 1)) = 0
		_SpecularlRange("SpecularlRange", Range( 0.1 , 10)) = 1
		_Specularlntensity("Specularlntensity", Range( 0 , 1)) = 0
		_Smothness("Smothness", Range( 0 , 1)) = 0
		_CubeMap("CubeMap", CUBE) = "white" {}
		_DepthMap("DepthMap", 2D) = "white" {}
		_DepthMin("_DepthMin", Range( -1 , 1)) = 0
		_DepthMax("_DepthMax", Range( -1 , 1)) = 0
		_ShallowColor("ShallowColor", Color) = (0,0,0,0)
		_DeepColor("DeepColor", Color) = (0,0,0,0)
		_FresnelRange("FresnelRange", Range( 0 , 10)) = 0
		_FresnelIntensity("FresnelIntensity", Range( 0 , 5)) = 1
		_FresnelColor("FresnelColor", Color) = (0.493236,0.6356439,0.6415094,0)
		_StartTexture("StartTexture", 2D) = "white" {}
		_StartTexTlling("StartTexTlling", Range( 0 , 1)) = 0
		_FormTexture("FormTexture", 2D) = "white" {}
		_FormTexTilling("FormTexTilling", Range( 0 , 1)) = 0
		_FormRange("FormRange", Range( 0 , 1)) = 0
		_FormIntensity("FormIntensity", Range( 0 , 1)) = 0
		_StartSpeed("StartSpeed", Float) = 0
		[ASEEnd]_StartIntensity("StartIntensity", Float) = 0
		[HideInInspector] _texcoord( "", 2D ) = "white" {}

		//_TessPhongStrength( "Tess Phong Strength", Range( 0, 1 ) ) = 0.5
		//_TessValue( "Tess Max Tessellation", Range( 1, 32 ) ) = 16
		//_TessMin( "Tess Min Distance", Float ) = 10
		//_TessMax( "Tess Max Distance", Float ) = 25
		//_TessEdgeLength ( "Tess Edge length", Range( 2, 50 ) ) = 16
		//_TessMaxDisp( "Tess Max Displacement", Float ) = 25
	}

	SubShader
	{
		LOD 0

		
		Tags { "RenderPipeline"="UniversalPipeline" "RenderType"="Transparent" "Queue"="Transparent" }
		
		Cull Off
		AlphaToMask Off
		HLSLINCLUDE
		#pragma target 2.0

		float4 FixedTess( float tessValue )
		{
			return tessValue;
		}
		
		float CalcDistanceTessFactor (float4 vertex, float minDist, float maxDist, float tess, float4x4 o2w, float3 cameraPos )
		{
			float3 wpos = mul(o2w,vertex).xyz;
			float dist = distance (wpos, cameraPos);
			float f = clamp(1.0 - (dist - minDist) / (maxDist - minDist), 0.01, 1.0) * tess;
			return f;
		}

		float4 CalcTriEdgeTessFactors (float3 triVertexFactors)
		{
			float4 tess;
			tess.x = 0.5 * (triVertexFactors.y + triVertexFactors.z);
			tess.y = 0.5 * (triVertexFactors.x + triVertexFactors.z);
			tess.z = 0.5 * (triVertexFactors.x + triVertexFactors.y);
			tess.w = (triVertexFactors.x + triVertexFactors.y + triVertexFactors.z) / 3.0f;
			return tess;
		}

		float CalcEdgeTessFactor (float3 wpos0, float3 wpos1, float edgeLen, float3 cameraPos, float4 scParams )
		{
			float dist = distance (0.5 * (wpos0+wpos1), cameraPos);
			float len = distance(wpos0, wpos1);
			float f = max(len * scParams.y / (edgeLen * dist), 1.0);
			return f;
		}

		float DistanceFromPlane (float3 pos, float4 plane)
		{
			float d = dot (float4(pos,1.0f), plane);
			return d;
		}

		bool WorldViewFrustumCull (float3 wpos0, float3 wpos1, float3 wpos2, float cullEps, float4 planes[6] )
		{
			float4 planeTest;
			planeTest.x = (( DistanceFromPlane(wpos0, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[0]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[0]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.y = (( DistanceFromPlane(wpos0, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[1]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[1]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.z = (( DistanceFromPlane(wpos0, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[2]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[2]) > -cullEps) ? 1.0f : 0.0f );
			planeTest.w = (( DistanceFromPlane(wpos0, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos1, planes[3]) > -cullEps) ? 1.0f : 0.0f ) +
						  (( DistanceFromPlane(wpos2, planes[3]) > -cullEps) ? 1.0f : 0.0f );
			return !all (planeTest);
		}

		float4 DistanceBasedTess( float4 v0, float4 v1, float4 v2, float tess, float minDist, float maxDist, float4x4 o2w, float3 cameraPos )
		{
			float3 f;
			f.x = CalcDistanceTessFactor (v0,minDist,maxDist,tess,o2w,cameraPos);
			f.y = CalcDistanceTessFactor (v1,minDist,maxDist,tess,o2w,cameraPos);
			f.z = CalcDistanceTessFactor (v2,minDist,maxDist,tess,o2w,cameraPos);

			return CalcTriEdgeTessFactors (f);
		}

		float4 EdgeLengthBasedTess( float4 v0, float4 v1, float4 v2, float edgeLength, float4x4 o2w, float3 cameraPos, float4 scParams )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;
			tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
			tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
			tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
			tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			return tess;
		}

		float4 EdgeLengthBasedTessCull( float4 v0, float4 v1, float4 v2, float edgeLength, float maxDisplacement, float4x4 o2w, float3 cameraPos, float4 scParams, float4 planes[6] )
		{
			float3 pos0 = mul(o2w,v0).xyz;
			float3 pos1 = mul(o2w,v1).xyz;
			float3 pos2 = mul(o2w,v2).xyz;
			float4 tess;

			if (WorldViewFrustumCull(pos0, pos1, pos2, maxDisplacement, planes))
			{
				tess = 0.0f;
			}
			else
			{
				tess.x = CalcEdgeTessFactor (pos1, pos2, edgeLength, cameraPos, scParams);
				tess.y = CalcEdgeTessFactor (pos2, pos0, edgeLength, cameraPos, scParams);
				tess.z = CalcEdgeTessFactor (pos0, pos1, edgeLength, cameraPos, scParams);
				tess.w = (tess.x + tess.y + tess.z) / 3.0f;
			}
			return tess;
		}
		ENDHLSL

		
		Pass
		{
			
			Name "Forward"
			Tags { "LightMode"="UniversalForward" }
			
			Blend SrcAlpha OneMinusSrcAlpha, One OneMinusSrcAlpha
			ZWrite Off
			ZTest LEqual
			Offset 0 , 0
			ColorMask RGBA
			

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/UnityInstancing.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"

			#if ASE_SRP_VERSION <= 70108
			#define REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR
			#endif

			#define ASE_NEEDS_FRAG_WORLD_POSITION
			#define ASE_NEEDS_VERT_NORMAL


			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				#ifdef ASE_FOG
				float fogFactor : TEXCOORD2;
				#endif
				float4 ase_texcoord3 : TEXCOORD3;
				float4 ase_texcoord4 : TEXCOORD4;
				float4 ase_texcoord5 : TEXCOORD5;
				float4 ase_texcoord6 : TEXCOORD6;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ShallowColor;
			float4 _FresnelColor;
			float4 _DepthMap_ST;
			float4 _DeepColor;
			float2 _WaterDir;
			float _StartTexTlling;
			float _FormRange;
			float _FormIntensity;
			float _FormTexTilling;
			float _FresnelIntensity;
			float _FresnelRange;
			float _DepthMax;
			float _DepthMin;
			float _NormalTilling_A;
			float _Specularlntensity;
			float _SpecularlRange;
			float _CustormLight_Z;
			float _CustormLight_Y;
			float _CustormLight_X;
			float _Smothness;
			float _NormalScale_B;
			float _NormalTilling_B;
			float _NormalScale_A;
			float _StartSpeed;
			float _StartIntensity;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			samplerCUBE _CubeMap;
			sampler2D _NormalMap;
			sampler2D _DepthMap;
			sampler2D _FormTexture;
			sampler2D _StartTexture;


						
			VertexOutput VertexFunction ( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				float3 ase_worldTangent = TransformObjectToWorldDir(v.ase_tangent.xyz);
				o.ase_texcoord3.xyz = ase_worldTangent;
				float3 ase_worldNormal = TransformObjectToWorldNormal(v.ase_normal);
				o.ase_texcoord4.xyz = ase_worldNormal;
				float ase_vertexTangentSign = v.ase_tangent.w * unity_WorldTransformParams.w;
				float3 ase_worldBitangent = cross( ase_worldNormal, ase_worldTangent ) * ase_vertexTangentSign;
				o.ase_texcoord5.xyz = ase_worldBitangent;
				
				o.ase_texcoord6.xyz = v.ase_texcoord.xyz;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord3.w = 0;
				o.ase_texcoord4.w = 0;
				o.ase_texcoord5.w = 0;
				o.ase_texcoord6.w = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif
				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );
				float4 positionCS = TransformWorldToHClip( positionWS );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				VertexPositionInputs vertexInput = (VertexPositionInputs)0;
				vertexInput.positionWS = positionWS;
				vertexInput.positionCS = positionCS;
				o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				#ifdef ASE_FOG
				o.fogFactor = ComputeFogFactor( positionCS.z );
				#endif
				o.clipPos = positionCS;
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_tangent : TANGENT;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_tangent = v.ase_tangent;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_tangent = patch[0].ase_tangent * bary.x + patch[1].ase_tangent * bary.y + patch[2].ase_tangent * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag ( VertexOutput IN  ) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif
				float3 ase_worldViewDir = ( _WorldSpaceCameraPos.xyz - WorldPosition );
				ase_worldViewDir = SafeNormalize( ase_worldViewDir );
				float2 appendResult72 = (float2(WorldPosition.x , WorldPosition.z));
				float2 WorldUV88 = appendResult72;
				float3 unpack15 = UnpackNormalScale( tex2D( _NormalMap, ( WorldUV88 * _NormalTilling_A * 0.1 ) ), _NormalScale_A );
				unpack15.z = lerp( 1, unpack15.z, saturate(_NormalScale_A) );
				float3 NormalTS83 = unpack15;
				float2 Speed244 = ( _WaterDir * _TimeParameters.x * 0.1 );
				float3 break87 = NormalTS83;
				float2 appendResult95 = (float2(break87.x , break87.z));
				float3 unpack75 = UnpackNormalScale( tex2D( _NormalMap, ( ( ( WorldUV88 * _NormalTilling_B * 0.1 ) + Speed244 ) + appendResult95 ) ), _NormalScale_B );
				unpack75.z = lerp( 1, unpack75.z, saturate(_NormalScale_B) );
				float3 temp_output_79_0 = BlendNormal( NormalTS83 , unpack75 );
				float3 ase_worldTangent = IN.ase_texcoord3.xyz;
				float3 ase_worldNormal = IN.ase_texcoord4.xyz;
				float3 ase_worldBitangent = IN.ase_texcoord5.xyz;
				float3 tanToWorld0 = float3( ase_worldTangent.x, ase_worldBitangent.x, ase_worldNormal.x );
				float3 tanToWorld1 = float3( ase_worldTangent.y, ase_worldBitangent.y, ase_worldNormal.y );
				float3 tanToWorld2 = float3( ase_worldTangent.z, ase_worldBitangent.z, ase_worldNormal.z );
				float3 tanNormal24 = temp_output_79_0;
				float3 worldNormal24 = normalize( float3(dot(tanToWorld0,tanNormal24), dot(tanToWorld1,tanNormal24), dot(tanToWorld2,tanNormal24)) );
				float3 WorldNormal47 = worldNormal24;
				float perceptualRoughness108 = ( 1.0 - _Smothness );
				float4 CubeMapColor118 = texCUBElod( _CubeMap, float4( reflect( -ase_worldViewDir , WorldNormal47 ), ( perceptualRoughness108 * ( 1.7 - ( perceptualRoughness108 * 0.7 ) ) * 6.0 )) );
				float3 appendResult169 = (float3(_CustormLight_X , _CustormLight_Y , _CustormLight_Z));
				float3 normalizeResult54 = normalize( appendResult169 );
				float3 normalizeResult165 = normalize( ( ase_worldViewDir + normalizeResult54 ) );
				float dotResult28 = dot( WorldNormal47 , normalizeResult165 );
				float Specular170 = ( pow( saturate( dotResult28 ) , exp( _SpecularlRange ) ) * _Specularlntensity );
				ase_worldViewDir = normalize(ase_worldViewDir);
				float dotResult140 = dot( WorldNormal47 , ase_worldViewDir );
				float2 uv_DepthMap = IN.ase_texcoord6.xyz.xy * _DepthMap_ST.xy + _DepthMap_ST.zw;
				float4 tex2DNode121 = tex2D( _DepthMap, uv_DepthMap );
				float smoothstepResult123 = smoothstep( _DepthMin , _DepthMax , tex2DNode121.r);
				float Depth127 = saturate( smoothstepResult123 );
				float4 lerpResult133 = lerp( _DeepColor , _ShallowColor , Depth127);
				float4 WaterColor134 = lerpResult133;
				float4 temp_cast_0 = (0.0).xxxx;
				float4 temp_cast_1 = (1.5).xxxx;
				float4 clampResult155 = clamp( ( saturate( dotResult140 ) * _MainLightColor * WaterColor134 ) , temp_cast_0 , temp_cast_1 );
				float4 Diffuse173 = clampResult155;
				float dotResult182 = dot( ase_worldViewDir , WorldNormal47 );
				float FresnelLerp190 = saturate( ( pow( ( 1.0 - saturate( dotResult182 ) ) , _FresnelRange ) * _FresnelIntensity ) );
				float4 lerpResult191 = lerp( ( ( CubeMapColor118 + ( Specular170 * _MainLightColor ) ) + Diffuse173 ) , _FresnelColor , FresnelLerp190);
				float3 FlowNormalTS233 = temp_output_79_0;
				float3 break234 = FlowNormalTS233;
				float2 appendResult237 = (float2(break234.x , break234.z));
				float FormMask225 = saturate( pow( tex2DNode121.g , exp( _FormRange ) ) );
				float temp_output_266_0 = ( _TimeParameters.x * _StartSpeed );
				float4 break263 = ( ( tex2D( _StartTexture, ( ( _StartTexTlling * WorldUV88 ) + temp_output_266_0 ) ) * tex2D( _StartTexture, ( ( _StartTexTlling * WorldUV88 * 0.5 ) + ( temp_output_266_0 * -0.5 ) ) ) ) * Specular170 );
				float StartColor257 = ( ( break263.r + break263.g + break263.b ) * _StartIntensity );
				
				float3 BakedAlbedo = 0;
				float3 BakedEmission = 0;
				float3 Color = ( ( lerpResult191 + ( tex2D( _FormTexture, ( ( WorldUV88 * _FormTexTilling ) + Speed244 + ( appendResult237 * _FormIntensity ) ) ).g * FormMask225 ) ) + StartColor257 ).rgb;
				float Alpha = ( 1.0 - Depth127 );
				float AlphaClipThreshold = 0.5;
				float AlphaClipThresholdShadow = 0.5;

				#ifdef _ALPHATEST_ON
					clip( Alpha - AlphaClipThreshold );
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif

				#ifdef ASE_FOG
					Color = MixFog( Color, IN.fogFactor );
				#endif

				return half4( Color, Alpha );
			}

			ENDHLSL
		}

		
		Pass
		{
			
			Name "DepthOnly"
			Tags { "LightMode"="DepthOnly" }

			ZWrite On
			ColorMask 0
			AlphaToMask Off

			HLSLPROGRAM
			#define _RECEIVE_SHADOWS_OFF 1
			#define ASE_SRP_VERSION 999999

			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x

			#pragma vertex vert
			#pragma fragment frag

			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/ShaderGraphFunctions.hlsl"
			#include "Packages/com.unity.render-pipelines.core/ShaderLibrary/Color.hlsl"

			

			struct VertexInput
			{
				float4 vertex : POSITION;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct VertexOutput
			{
				float4 clipPos : SV_POSITION;
				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 worldPos : TEXCOORD0;
				#endif
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
				float4 shadowCoord : TEXCOORD1;
				#endif
				float4 ase_texcoord2 : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};

			CBUFFER_START(UnityPerMaterial)
			float4 _ShallowColor;
			float4 _FresnelColor;
			float4 _DepthMap_ST;
			float4 _DeepColor;
			float2 _WaterDir;
			float _StartTexTlling;
			float _FormRange;
			float _FormIntensity;
			float _FormTexTilling;
			float _FresnelIntensity;
			float _FresnelRange;
			float _DepthMax;
			float _DepthMin;
			float _NormalTilling_A;
			float _Specularlntensity;
			float _SpecularlRange;
			float _CustormLight_Z;
			float _CustormLight_Y;
			float _CustormLight_X;
			float _Smothness;
			float _NormalScale_B;
			float _NormalTilling_B;
			float _NormalScale_A;
			float _StartSpeed;
			float _StartIntensity;
			#ifdef TESSELLATION_ON
				float _TessPhongStrength;
				float _TessValue;
				float _TessMin;
				float _TessMax;
				float _TessEdgeLength;
				float _TessMaxDisp;
			#endif
			CBUFFER_END
			sampler2D _DepthMap;


			
			VertexOutput VertexFunction( VertexInput v  )
			{
				VertexOutput o = (VertexOutput)0;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO(o);

				o.ase_texcoord2.xy = v.ase_texcoord.xy;
				
				//setting value to unused interpolator channels and avoid initialization warnings
				o.ase_texcoord2.zw = 0;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					float3 defaultVertexValue = v.vertex.xyz;
				#else
					float3 defaultVertexValue = float3(0, 0, 0);
				#endif
				float3 vertexValue = defaultVertexValue;
				#ifdef ASE_ABSOLUTE_VERTEX_POS
					v.vertex.xyz = vertexValue;
				#else
					v.vertex.xyz += vertexValue;
				#endif

				v.ase_normal = v.ase_normal;

				float3 positionWS = TransformObjectToWorld( v.vertex.xyz );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				o.worldPos = positionWS;
				#endif

				o.clipPos = TransformWorldToHClip( positionWS );
				#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR) && defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					VertexPositionInputs vertexInput = (VertexPositionInputs)0;
					vertexInput.positionWS = positionWS;
					vertexInput.positionCS = clipPos;
					o.shadowCoord = GetShadowCoord( vertexInput );
				#endif
				return o;
			}

			#if defined(TESSELLATION_ON)
			struct VertexControl
			{
				float4 vertex : INTERNALTESSPOS;
				float3 ase_normal : NORMAL;
				float4 ase_texcoord : TEXCOORD0;

				UNITY_VERTEX_INPUT_INSTANCE_ID
			};

			struct TessellationFactors
			{
				float edge[3] : SV_TessFactor;
				float inside : SV_InsideTessFactor;
			};

			VertexControl vert ( VertexInput v )
			{
				VertexControl o;
				UNITY_SETUP_INSTANCE_ID(v);
				UNITY_TRANSFER_INSTANCE_ID(v, o);
				o.vertex = v.vertex;
				o.ase_normal = v.ase_normal;
				o.ase_texcoord = v.ase_texcoord;
				return o;
			}

			TessellationFactors TessellationFunction (InputPatch<VertexControl,3> v)
			{
				TessellationFactors o;
				float4 tf = 1;
				float tessValue = _TessValue; float tessMin = _TessMin; float tessMax = _TessMax;
				float edgeLength = _TessEdgeLength; float tessMaxDisp = _TessMaxDisp;
				#if defined(ASE_FIXED_TESSELLATION)
				tf = FixedTess( tessValue );
				#elif defined(ASE_DISTANCE_TESSELLATION)
				tf = DistanceBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, tessValue, tessMin, tessMax, GetObjectToWorldMatrix(), _WorldSpaceCameraPos );
				#elif defined(ASE_LENGTH_TESSELLATION)
				tf = EdgeLengthBasedTess(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams );
				#elif defined(ASE_LENGTH_CULL_TESSELLATION)
				tf = EdgeLengthBasedTessCull(v[0].vertex, v[1].vertex, v[2].vertex, edgeLength, tessMaxDisp, GetObjectToWorldMatrix(), _WorldSpaceCameraPos, _ScreenParams, unity_CameraWorldClipPlanes );
				#endif
				o.edge[0] = tf.x; o.edge[1] = tf.y; o.edge[2] = tf.z; o.inside = tf.w;
				return o;
			}

			[domain("tri")]
			[partitioning("fractional_odd")]
			[outputtopology("triangle_cw")]
			[patchconstantfunc("TessellationFunction")]
			[outputcontrolpoints(3)]
			VertexControl HullFunction(InputPatch<VertexControl, 3> patch, uint id : SV_OutputControlPointID)
			{
			   return patch[id];
			}

			[domain("tri")]
			VertexOutput DomainFunction(TessellationFactors factors, OutputPatch<VertexControl, 3> patch, float3 bary : SV_DomainLocation)
			{
				VertexInput o = (VertexInput) 0;
				o.vertex = patch[0].vertex * bary.x + patch[1].vertex * bary.y + patch[2].vertex * bary.z;
				o.ase_normal = patch[0].ase_normal * bary.x + patch[1].ase_normal * bary.y + patch[2].ase_normal * bary.z;
				o.ase_texcoord = patch[0].ase_texcoord * bary.x + patch[1].ase_texcoord * bary.y + patch[2].ase_texcoord * bary.z;
				#if defined(ASE_PHONG_TESSELLATION)
				float3 pp[3];
				for (int i = 0; i < 3; ++i)
					pp[i] = o.vertex.xyz - patch[i].ase_normal * (dot(o.vertex.xyz, patch[i].ase_normal) - dot(patch[i].vertex.xyz, patch[i].ase_normal));
				float phongStrength = _TessPhongStrength;
				o.vertex.xyz = phongStrength * (pp[0]*bary.x + pp[1]*bary.y + pp[2]*bary.z) + (1.0f-phongStrength) * o.vertex.xyz;
				#endif
				UNITY_TRANSFER_INSTANCE_ID(patch[0], o);
				return VertexFunction(o);
			}
			#else
			VertexOutput vert ( VertexInput v )
			{
				return VertexFunction( v );
			}
			#endif

			half4 frag(VertexOutput IN  ) : SV_TARGET
			{
				UNITY_SETUP_INSTANCE_ID(IN);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX( IN );

				#if defined(ASE_NEEDS_FRAG_WORLD_POSITION)
				float3 WorldPosition = IN.worldPos;
				#endif
				float4 ShadowCoords = float4( 0, 0, 0, 0 );

				#if defined(ASE_NEEDS_FRAG_SHADOWCOORDS)
					#if defined(REQUIRES_VERTEX_SHADOW_COORD_INTERPOLATOR)
						ShadowCoords = IN.shadowCoord;
					#elif defined(MAIN_LIGHT_CALCULATE_SHADOWS)
						ShadowCoords = TransformWorldToShadowCoord( WorldPosition );
					#endif
				#endif

				float2 uv_DepthMap = IN.ase_texcoord2.xy * _DepthMap_ST.xy + _DepthMap_ST.zw;
				float4 tex2DNode121 = tex2D( _DepthMap, uv_DepthMap );
				float smoothstepResult123 = smoothstep( _DepthMin , _DepthMax , tex2DNode121.r);
				float Depth127 = saturate( smoothstepResult123 );
				
				float Alpha = ( 1.0 - Depth127 );
				float AlphaClipThreshold = 0.5;

				#ifdef _ALPHATEST_ON
					clip(Alpha - AlphaClipThreshold);
				#endif

				#ifdef LOD_FADE_CROSSFADE
					LODDitheringTransition( IN.clipPos.xyz, unity_LODFade.x );
				#endif
				return 0;
			}
			ENDHLSL
		}

	
	}
	CustomEditor "UnityEditor.ShaderGraph.PBRMasterGUI"
	Fallback "Hidden/InternalErrorShader"
	
}
/*ASEBEGIN
Version=18707
2036;325;1513;563;243.0802;-647.2841;1.436723;True;False
Node;AmplifyShaderEditor.CommentaryNode;128;-4024.436,-1810.499;Inherit;False;1513.44;480.0864;Depth;11;127;126;123;125;124;121;221;222;223;224;225;Depth;1,1,1,1;0;0
Node;AmplifyShaderEditor.SamplerNode;121;-3974.436,-1760.499;Inherit;True;Property;_DepthMap;DepthMap;13;0;Create;True;0;0;False;0;False;-1;None;8f92785d6fc10d14e9daf7d7a241ca0c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;124;-3933.313,-1562.273;Inherit;False;Property;_DepthMin;_DepthMin;14;0;Create;True;0;0;False;0;False;0;-0.05;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;125;-3927.561,-1487.413;Inherit;False;Property;_DepthMax;_DepthMax;15;0;Create;True;0;0;False;0;False;0;0.29;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;123;-3500.562,-1739.413;Inherit;False;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;126;-3280.996,-1678.01;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;127;-3093.996,-1670.01;Inherit;False;Depth;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;174;-4035.762,1848.607;Inherit;False;1674.538;525.4693;Diffuse;13;141;139;142;140;145;155;157;156;173;138;137;144;274;Diffuse;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;119;-3541.67,-212.6477;Inherit;False;1651.584;772.547;CubeMapColor;16;117;106;114;105;107;108;103;102;104;116;110;112;109;111;100;118;CubeMapColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;258;-3958.371,2618.01;Inherit;False;3456.715;1062.745;StartColor;23;198;196;267;195;255;254;266;257;264;253;197;263;247;252;251;256;261;193;260;269;271;268;270;StartColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.GetLocalVarNode;148;486.3482,786.989;Inherit;False;127;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.CommentaryNode;120;-4048.756,-1250.306;Inherit;False;2429.514;1011.382;WorldNormal;30;74;87;84;89;65;72;71;90;24;93;97;73;95;85;63;88;83;75;79;92;96;94;15;64;70;47;150;151;233;244;WorldNormal;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;171;-4286.951,1338.798;Inherit;False;1932.569;434.9362;Specular;18;160;28;0;159;168;54;166;169;167;165;29;34;53;35;153;152;158;170;Specular;1,1,1,1;0;0
Node;AmplifyShaderEditor.CommentaryNode;143;-3090.766,714.8438;Inherit;False;782.166;522.9999;WaterColor;5;129;133;131;132;134;WaterColor;1,1,1,1;0;0
Node;AmplifyShaderEditor.DynamicAppendNode;237;-691.564,1526.632;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;15;-2953.654,-1081.838;Inherit;True;Property;_NormalMap;NormalMap;0;0;Create;True;0;0;False;0;False;-1;None;fe47f6b40e9ebad42852983fba562b03;True;0;True;bump;Auto;True;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SaturateNode;141;-3498.532,1973.607;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;100;-2464.422,14.36085;Inherit;True;Property;_CubeMap;CubeMap;12;0;Create;True;0;0;False;0;False;-1;None;9b14208227d207b47abf60e5852645e9;True;0;False;white;LockedToCube;False;Object;-1;MipLevel;Cube;8;0;SAMPLERCUBE;;False;1;FLOAT3;0,0,0;False;2;FLOAT;0;False;3;FLOAT3;0,0,0;False;4;FLOAT3;0,0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;226;387.2699,1144.608;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;263;-1920.48,3028.02;Inherit;False;COLOR;1;0;COLOR;0,0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SimpleAddOpNode;96;-3129.892,-654.3328;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;73;-3483.49,-997.0065;Inherit;False;Property;_NormalTilling_A;NormalTilling_A;1;0;Create;True;0;0;False;0;False;1;1.5;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;108;-3047.691,109.3301;Inherit;False;perceptualRoughness;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;186;-1067.855,985.8189;Inherit;False;Property;_FresnelRange;FresnelRange;18;0;Create;True;0;0;False;0;False;0;5.03;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.BlendNormalsNode;79;-2358.139,-835.4764;Inherit;False;0;3;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.OneMinusNode;149;647.3481,786.989;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;97;-3134.864,-535.1998;Inherit;False;Property;_NormalScale_B;NormalScale_B;4;0;Create;True;0;0;False;0;False;0;0.37;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;88;-3396.514,-1168.676;Inherit;False;WorldUV;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;114;-3289.689,254.8994;Inherit;False;108;perceptualRoughness;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;190;-307.1101,894.9281;Inherit;False;FresnelLerp;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;166;-4225.951,1495.734;Inherit;False;Property;_CustormLight_X;CustormLight_X;6;0;Create;True;0;0;False;0;False;0;-0.1;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;95;-3475.648,-461.4011;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;118;-2115.087,26.02389;Inherit;False;CubeMapColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;135;-842.9175,371.0949;Inherit;False;118;CubeMapColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;152;-2737.269,1450.082;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.BreakToComponentsNode;234;-884.5637,1525.632;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.SaturateNode;224;-3078.867,-1544.48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;28;-3237.362,1416.865;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;270;-1571.813,3216.175;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;256;-2535.624,2844.54;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.ExpOpNode;223;-3411.867,-1518.48;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;261;-2106.479,3014.02;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;102;-3491.67,122.2016;Inherit;False;Property;_Smothness;Smothness;11;0;Create;True;0;0;False;0;False;0;0.846;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;168;-4234.951,1657.734;Inherit;False;Property;_CustormLight_Z;CustormLight_Z;8;0;Create;True;0;0;False;0;False;0;-0.36;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.WorldPosInputsNode;71;-3833.274,-1200.306;Inherit;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SamplerNode;217;-47.69089,1162.497;Inherit;True;Property;_FormTexture;FormTexture;23;0;Create;True;0;0;False;0;False;-1;None;bafaec4577d94944fa0df69aa7f06801;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleTimeNode;64;-3934.01,-576.0483;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;47;-1857.542,-627.4917;Inherit;False;WorldNormal;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;239;-791.3699,1667.884;Inherit;False;Property;_FormIntensity;FormIntensity;26;0;Create;True;0;0;False;0;False;0;0.301;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;181;-1510.855,954.8187;Inherit;False;47;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.Vector2Node;63;-3937.903,-695.6202;Inherit;False;Property;_WaterDir;WaterDir;5;0;Create;True;0;0;False;0;False;0,0;-0.64,-1;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.SimpleAddOpNode;94;-3390.756,-709.5768;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;84;-3311.075,-827.0351;Inherit;False;Property;_NormalScale_A;NormalScale_A;3;0;Create;True;0;0;False;0;False;0;0.195;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;219;-730.4257,1255.88;Inherit;False;Property;_FormTexTilling;FormTexTilling;24;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;269;-3684.743,2884.197;Inherit;False;Constant;_Float9;Float 9;28;0;Create;True;0;0;False;0;False;0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;253;-3134.624,3027.54;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;176;-673.3427,600.7258;Inherit;False;173;Diffuse;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleAddOpNode;273;756.8391,1087.134;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;175;-969.343,495.726;Inherit;False;170;Specular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;197;-3446.266,2687.01;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.LerpOp;191;1.067455,764.8905;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.GetLocalVarNode;260;-2468.478,3184.02;Inherit;False;170;Specular;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;65;-3752.009,-655.048;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.BreakToComponentsNode;87;-3663.875,-397.9241;Inherit;False;FLOAT3;1;0;FLOAT3;0,0,0;False;16;FLOAT;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4;FLOAT;5;FLOAT;6;FLOAT;7;FLOAT;8;FLOAT;9;FLOAT;10;FLOAT;11;FLOAT;12;FLOAT;13;FLOAT;14;FLOAT;15
Node;AmplifyShaderEditor.RangedFloatNode;271;-1807.813,3280.175;Inherit;False;Property;_StartIntensity;StartIntensity;28;0;Create;True;0;0;False;0;False;0;10;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;275;736.765,946.1226;Inherit;False;Constant;_Float10;Float 10;29;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;257;-1396.584,3032.818;Inherit;False;StartColor;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;192;-608.4009,710.6312;Inherit;False;Property;_FresnelColor;FresnelColor;20;0;Create;True;0;0;False;0;False;0.493236,0.6356439,0.6415094,0;0.5303934,0.7336463,0.8207547,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;70;-3904.744,-505.4021;Inherit;False;Constant;_Float1;Float 1;4;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;232;-1123.326,1525.252;Inherit;True;233;FlowNormalTS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;187;-599.8555,958.8187;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;74;-3183.588,-1051.206;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;144;-3547.714,2232.082;Inherit;False;134;WaterColor;1;0;OBJECT;;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;193;-1770.122,2855.225;Inherit;False;DebugColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;151;-3361.233,-919.1887;Inherit;False;Constant;_Float5;Float 5;15;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;167;-4236.951,1578.734;Inherit;False;Property;_CustormLight_Y;CustormLight_Y;7;0;Create;True;0;0;False;0;False;0;0.14;-1;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;218;-617.4255,1166.88;Inherit;False;88;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;156;-3143.372,2157.895;Inherit;False;Constant;_Float6;Float 6;16;0;Create;True;0;0;False;0;False;0;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;155;-2952.68,2042.309;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;COLOR;1,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RangedFloatNode;105;-2957.125,211.6982;Inherit;False;Constant;_Float0;Float 0;10;0;Create;True;0;0;False;0;False;1.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;252;-2903.326,2948.835;Inherit;True;Property;_TextureSample1;Texture Sample 1;21;0;Create;True;0;0;False;0;False;-1;None;816ee134b3c585b449d3e2560630cc81;True;0;False;white;Auto;False;Instance;195;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;268;-3499.743,2883.197;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldNormalVector;24;-2084.532,-617.2508;Inherit;False;True;1;0;FLOAT3;0,0,1;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;111;-3092.826,-162.6477;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;83;-2619.418,-1075.214;Inherit;False;NormalTS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;251;-3114.003,2784.235;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.NormalizeNode;165;-3403.951,1484.734;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;179;-498.4317,374.1313;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;170;-2578.383,1455.624;Inherit;False;Specular;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;183;-1114.855,871.8188;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;238;-504.3192,1524.393;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;153;-3182.093,1634.858;Inherit;False;Property;_Specularlntensity;Specularlntensity;10;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;225;-2882.867,-1549.48;Inherit;False;FormMask;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;233;-2048.776,-866.6423;Inherit;False;FlowNormalTS;-1;True;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SaturateNode;189;-466.1099,902.9281;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;173;-2754.224,2053.026;Inherit;False;Diffuse;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;134;-2532.6,1015.482;Inherit;False;WaterColor;-1;True;1;0;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SaturateNode;29;-3078.823,1429.887;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;267;-3796.567,3104.09;Inherit;False;Property;_StartSpeed;StartSpeed;27;0;Create;True;0;0;False;0;False;0;0.1;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;75;-2771.075,-705.7511;Inherit;True;Property;_TextureSample0;Texture Sample 0;0;0;Create;True;0;0;False;0;False;-1;None;fe47f6b40e9ebad42852983fba562b03;True;0;True;bump;Auto;True;Instance;15;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;139;-3944.532,1898.607;Inherit;False;47;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.GetLocalVarNode;85;-3917.958,-405.2861;Inherit;False;83;NormalTS;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.RangedFloatNode;157;-3139.372,2248.895;Inherit;False;Constant;_Float7;Float 7;16;0;Create;True;0;0;False;0;False;1.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;132;-3040.766,944.8439;Inherit;False;Property;_ShallowColor;ShallowColor;16;0;Create;True;0;0;False;0;False;0,0,0,0;0.6132076,0.5979198,0.5929601,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleAddOpNode;264;-1756.48,3036.02;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;72;-3564.476,-1165.006;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;35;-3420.08,1564.306;Inherit;False;Property;_SpecularlRange;SpecularlRange;9;0;Create;True;0;0;False;0;False;1;4.69;0.1;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;222;-3655.867,-1423.48;Inherit;False;Property;_FormRange;FormRange;25;0;Create;True;0;0;False;0;False;0;1;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;129;-2995.766,1121.844;Inherit;False;127;Depth;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;142;-3301.532,2057.607;Inherit;False;3;3;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;2;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.Vector3Node;145;-3949.266,2020.77;Inherit;False;Constant;_Vector0;Vector 0;15;0;Create;True;0;0;False;0;False;0,1,0;0,0,0;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;180;-1497.855,774.8189;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.SimpleAddOpNode;177;-383.3427,567.7258;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.DynamicAppendNode;169;-3904.951,1558.734;Inherit;False;FLOAT3;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ExpOpNode;53;-3139.503,1566.949;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.LightColorNode;216;-896.2785,596.1861;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.LightColorNode;137;-3546.209,2087.243;Inherit;False;0;3;COLOR;0;FLOAT3;1;FLOAT;2
Node;AmplifyShaderEditor.PowerNode;221;-3243.867,-1558.48;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;188;-979.8546,1086.82;Inherit;False;Property;_FresnelIntensity;FresnelIntensity;19;0;Create;True;0;0;False;0;False;1;2.88;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.NegateNode;112;-2908.154,-149.5444;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;236;-178.9574,1265.486;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.PowerNode;185;-793.855,895.8187;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.LerpOp;133;-2708.766,1019.844;Inherit;False;3;0;COLOR;0,0,0,0;False;1;COLOR;0,0,0,0;False;2;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;106;-2785.125,242.6983;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;131;-3031.766,764.8438;Inherit;False;Property;_DeepColor;DeepColor;17;0;Create;True;0;0;False;0;False;0,0,0,0;0,0,0,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;116;-2863.689,443.8996;Inherit;False;Constant;_Float3;Float 3;10;0;Create;True;0;0;False;0;False;6;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;110;-3015.812,1.955014;Inherit;False;47;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ReflectOpNode;109;-2764.128,-52.59653;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;178;-641.4314,474.1312;Inherit;False;2;2;0;FLOAT;0;False;1;COLOR;0,0,0,0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;220;-368.4254,1213.88;Inherit;False;2;2;0;FLOAT2;0,0;False;1;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;255;-3548.624,3255.54;Inherit;False;Constant;_Float8;Float 8;28;0;Create;True;0;0;False;0;False;-0.5;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;104;-2918.542,326.4856;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;160;-3548.418,1494.956;Inherit;False;2;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.NormalizeNode;54;-3746.648,1551.307;Inherit;False;1;0;FLOAT3;0,0,0;False;1;FLOAT3;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;159;-3777.48,1391.536;Inherit;False;World;True;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RegisterLocalVarNode;244;-3602.543,-617.4529;Inherit;False;Speed;-1;True;1;0;FLOAT2;0,0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.OneMinusNode;184;-972.8547,872.8188;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;103;-3206.542,122.4856;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;195;-2905.879,2675.186;Inherit;True;Property;_StartTexture;StartTexture;21;0;Create;True;0;0;False;0;False;-1;None;816ee134b3c585b449d3e2560630cc81;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.GetLocalVarNode;158;-3474.096,1388.798;Inherit;False;47;WorldNormal;1;0;OBJECT;;False;1;FLOAT3;0
Node;AmplifyShaderEditor.SimpleAddOpNode;228;547.267,971.2419;Inherit;False;2;2;0;COLOR;0,0,0,0;False;1;FLOAT;0;False;1;COLOR;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;117;-2626.087,175.8977;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.PowerNode;34;-2925.738,1435.774;Inherit;False;False;2;0;FLOAT;0;False;1;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;140;-3647.532,1970.607;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;107;-3319.542,343.4856;Inherit;False;Constant;_Float2;Float 2;10;0;Create;True;0;0;False;0;False;0.7;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;254;-3301.624,3211.54;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;266;-3572.567,3010.09;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;196;-3802.865,2765.81;Inherit;False;88;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;245;-694.8154,1366.59;Inherit;False;244;Speed;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.WorldSpaceLightDirHlpNode;138;-3967.563,2187.177;Inherit;False;True;1;0;FLOAT;0;False;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;198;-3799.265,2667.01;Inherit;False;Property;_StartTexTlling;StartTexTlling;22;0;Create;True;0;0;False;0;False;0;0.572;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.ViewDirInputsCoordNode;274;-3761.291,2113.449;Inherit;False;World;False;0;4;FLOAT3;0;FLOAT;1;FLOAT;2;FLOAT;3
Node;AmplifyShaderEditor.RangedFloatNode;150;-3942.233,-806.1887;Inherit;False;Constant;_Float4;Float 4;15;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;90;-3917.756,-969.5769;Inherit;False;88;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;93;-3708.756,-902.5768;Inherit;False;3;3;0;FLOAT2;0,0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SimpleTimeNode;247;-3811.903,2976.635;Inherit;False;1;0;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;89;-3394.359,-1079.105;Inherit;False;88;WorldUV;1;0;OBJECT;;False;1;FLOAT2;0
Node;AmplifyShaderEditor.GetLocalVarNode;227;206.3814,1446.284;Inherit;False;225;FormMask;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;259;481.7275,1249.952;Inherit;False;257;StartColor;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.DotProductOpNode;182;-1268.855,873.8188;Inherit;False;2;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;92;-4011.756,-878.5767;Inherit;False;Property;_NormalTilling_B;NormalTilling_B;2;0;Create;True;0;0;False;0;False;1;2.12;0;10;0;1;FLOAT;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;3;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;DepthOnly;0;3;DepthOnly;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;True;False;False;False;False;0;False;-1;False;False;False;False;True;1;False;-1;False;False;True;1;LightMode=DepthOnly;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;1;958.457,972.3435;Float;False;True;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;Jefford/River;2992e84f91cbeb14eab234972e07ea9d;True;Forward;0;1;Forward;8;False;False;False;False;False;False;False;False;True;0;False;-1;True;2;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Transparent=RenderType;Queue=Transparent=Queue=0;True;0;0;True;1;5;False;-1;10;False;-1;1;1;False;-1;10;False;-1;False;False;False;False;False;False;False;False;False;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;2;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;1;LightMode=UniversalForward;False;0;Hidden/InternalErrorShader;0;0;Standard;22;Surface;1;  Blend;0;Two Sided;0;Cast Shadows;0;  Use Shadow Threshold;0;Receive Shadows;0;GPU Instancing;0;LOD CrossFade;0;Built-in Fog;0;DOTS Instancing;0;Meta Pass;0;Extra Pre Pass;0;Tessellation;0;  Phong;0;  Strength;0.5,False,-1;  Type;0;  Tess;16,False,-1;  Min;10,False,-1;  Max;25,False,-1;  Edge Length;16,False,-1;  Max Displacement;25,False,-1;Vertex Position,InvertActionOnDeselection;1;0;5;False;True;False;True;False;False;;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;2;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ShadowCaster;0;2;ShadowCaster;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;True;0;False;-1;False;False;False;False;False;False;True;1;False;-1;True;3;False;-1;False;True;1;LightMode=ShadowCaster;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;0;-3146.045,1600.476;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;ExtraPrePass;0;0;ExtraPrePass;5;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;True;1;1;False;-1;0;False;-1;0;1;False;-1;0;False;-1;False;False;False;False;False;False;False;False;True;0;False;-1;True;True;True;True;True;0;False;-1;False;False;False;True;False;255;False;-1;255;False;-1;255;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;7;False;-1;1;False;-1;1;False;-1;1;False;-1;True;1;False;-1;True;3;False;-1;True;True;0;False;-1;0;False;-1;True;0;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
Node;AmplifyShaderEditor.TemplateMultiPassMasterNode;4;0,0;Float;False;False;-1;2;UnityEditor.ShaderGraph.PBRMasterGUI;0;3;New Amplify Shader;2992e84f91cbeb14eab234972e07ea9d;True;Meta;0;4;Meta;0;False;False;False;False;False;False;False;False;True;0;False;-1;True;0;False;-1;False;False;False;False;False;False;False;False;True;3;RenderPipeline=UniversalPipeline;RenderType=Opaque=RenderType;Queue=Geometry=Queue=0;True;0;0;False;False;False;False;False;False;False;False;False;True;2;False;-1;False;False;False;False;False;False;False;False;True;1;LightMode=Meta;False;0;Hidden/InternalErrorShader;0;0;Standard;0;False;0
WireConnection;123;0;121;1
WireConnection;123;1;124;0
WireConnection;123;2;125;0
WireConnection;126;0;123;0
WireConnection;127;0;126;0
WireConnection;237;0;234;0
WireConnection;237;1;234;2
WireConnection;15;1;74;0
WireConnection;15;5;84;0
WireConnection;141;0;140;0
WireConnection;100;1;109;0
WireConnection;100;2;117;0
WireConnection;226;0;217;2
WireConnection;226;1;227;0
WireConnection;263;0;261;0
WireConnection;96;0;94;0
WireConnection;96;1;95;0
WireConnection;108;0;103;0
WireConnection;79;0;83;0
WireConnection;79;1;75;0
WireConnection;149;0;148;0
WireConnection;88;0;72;0
WireConnection;190;0;189;0
WireConnection;95;0;87;0
WireConnection;95;1;87;2
WireConnection;118;0;100;0
WireConnection;152;0;34;0
WireConnection;152;1;153;0
WireConnection;234;0;232;0
WireConnection;224;0;221;0
WireConnection;28;0;158;0
WireConnection;28;1;165;0
WireConnection;270;0;264;0
WireConnection;270;1;271;0
WireConnection;256;0;195;0
WireConnection;256;1;252;0
WireConnection;223;0;222;0
WireConnection;261;0;256;0
WireConnection;261;1;260;0
WireConnection;217;1;236;0
WireConnection;47;0;24;0
WireConnection;94;0;93;0
WireConnection;94;1;244;0
WireConnection;253;0;268;0
WireConnection;253;1;254;0
WireConnection;273;0;228;0
WireConnection;273;1;259;0
WireConnection;197;0;198;0
WireConnection;197;1;196;0
WireConnection;191;0;177;0
WireConnection;191;1;192;0
WireConnection;191;2;190;0
WireConnection;65;0;63;0
WireConnection;65;1;64;0
WireConnection;65;2;70;0
WireConnection;87;0;85;0
WireConnection;257;0;270;0
WireConnection;187;0;185;0
WireConnection;187;1;188;0
WireConnection;74;0;89;0
WireConnection;74;1;73;0
WireConnection;74;2;151;0
WireConnection;155;0;142;0
WireConnection;155;1;156;0
WireConnection;155;2;157;0
WireConnection;252;1;253;0
WireConnection;268;0;198;0
WireConnection;268;1;196;0
WireConnection;268;2;269;0
WireConnection;24;0;79;0
WireConnection;83;0;15;0
WireConnection;251;0;197;0
WireConnection;251;1;266;0
WireConnection;165;0;160;0
WireConnection;179;0;135;0
WireConnection;179;1;178;0
WireConnection;170;0;152;0
WireConnection;183;0;182;0
WireConnection;238;0;237;0
WireConnection;238;1;239;0
WireConnection;225;0;224;0
WireConnection;233;0;79;0
WireConnection;189;0;187;0
WireConnection;173;0;155;0
WireConnection;134;0;133;0
WireConnection;29;0;28;0
WireConnection;75;1;96;0
WireConnection;75;5;97;0
WireConnection;264;0;263;0
WireConnection;264;1;263;1
WireConnection;264;2;263;2
WireConnection;72;0;71;1
WireConnection;72;1;71;3
WireConnection;142;0;141;0
WireConnection;142;1;137;0
WireConnection;142;2;144;0
WireConnection;177;0;179;0
WireConnection;177;1;176;0
WireConnection;169;0;166;0
WireConnection;169;1;167;0
WireConnection;169;2;168;0
WireConnection;53;0;35;0
WireConnection;221;0;121;2
WireConnection;221;1;223;0
WireConnection;112;0;111;0
WireConnection;236;0;220;0
WireConnection;236;1;245;0
WireConnection;236;2;238;0
WireConnection;185;0;184;0
WireConnection;185;1;186;0
WireConnection;133;0;131;0
WireConnection;133;1;132;0
WireConnection;133;2;129;0
WireConnection;106;0;105;0
WireConnection;106;1;104;0
WireConnection;109;0;112;0
WireConnection;109;1;110;0
WireConnection;178;0;175;0
WireConnection;178;1;216;0
WireConnection;220;0;218;0
WireConnection;220;1;219;0
WireConnection;104;0;114;0
WireConnection;104;1;107;0
WireConnection;160;0;159;0
WireConnection;160;1;54;0
WireConnection;54;0;169;0
WireConnection;244;0;65;0
WireConnection;184;0;183;0
WireConnection;103;0;102;0
WireConnection;195;1;251;0
WireConnection;228;0;191;0
WireConnection;228;1;226;0
WireConnection;117;0;108;0
WireConnection;117;1;106;0
WireConnection;117;2;116;0
WireConnection;34;0;29;0
WireConnection;34;1;53;0
WireConnection;140;0;139;0
WireConnection;140;1;274;0
WireConnection;254;0;266;0
WireConnection;254;1;255;0
WireConnection;266;0;247;0
WireConnection;266;1;267;0
WireConnection;93;0;90;0
WireConnection;93;1;92;0
WireConnection;93;2;150;0
WireConnection;182;0;180;0
WireConnection;182;1;181;0
WireConnection;1;2;273;0
WireConnection;1;3;149;0
ASEEND*/
//CHKSM=C17B434CD0C49799D0A8DEC3F51FB6140A12B63F