// Upgrade NOTE: upgraded instancing buffer 'JeffordFireDissolve_CarToon' to new syntax.

// Made with Amplify Shader Editor
// Available at the Unity Asset Store - http://u3d.as/y3X 
Shader "Jefford/FireDissolve_CarToon(火溶溶解)"
{
	Properties
	{
		[HDR]_FireColor("FireColor", Color) = (0,0,0,0)
		_ShapeTex("ShapeTex", 2D) = "white" {}
		_NoiseMap("NoiseMap", 2D) = "white" {}
		_GradientTex("GradientTex", 2D) = "white" {}
		_Speed("Speed", Vector) = (0,0,0,0)
		_Soft("Soft", Range( 0 , 1)) = 0.1
		[HideInInspector] _texcoord( "", 2D ) = "white" {}
		[HideInInspector] __dirty( "", Int ) = 1
	}

	SubShader
	{
		Tags{ "RenderType" = "Transparent"  "Queue" = "Transparent+0" "IgnoreProjector" = "True" "IsEmissive" = "true"  }
		Cull Off
		CGINCLUDE
		#include "UnityShaderVariables.cginc"
		#include "UnityPBSLighting.cginc"
		#include "Lighting.cginc"
		#pragma target 3.0
		#pragma multi_compile_instancing
		struct Input
		{
			float2 uv_texcoord;
		};

		uniform float4 _FireColor;
		uniform sampler2D _NoiseMap;
		SamplerState sampler_NoiseMap;
		uniform float2 _Speed;
		uniform float4 _NoiseMap_ST;
		uniform float _Soft;
		uniform sampler2D _GradientTex;
		SamplerState sampler_GradientTex;
		uniform float4 _GradientTex_ST;
		uniform sampler2D _ShapeTex;
		SamplerState sampler_ShapeTex;

		UNITY_INSTANCING_BUFFER_START(JeffordFireDissolve_CarToon火溶溶解)
			UNITY_DEFINE_INSTANCED_PROP(float4, _ShapeTex_ST)
#define _ShapeTex_ST_arr JeffordFireDissolve_CarToon
		UNITY_INSTANCING_BUFFER_END(JeffordFireDissolve_CarToon)

		inline half4 LightingUnlit( SurfaceOutput s, half3 lightDir, half atten )
		{
			return half4 ( 0, 0, 0, s.Alpha );
		}

		void surf( Input i , inout SurfaceOutput o )
		{
			float4 appendResult41 = (float4(_FireColor.r , _FireColor.g , _FireColor.b , 0.0));
			o.Emission = appendResult41.xyz;
			float2 uv_NoiseMap = i.uv_texcoord * _NoiseMap_ST.xy + _NoiseMap_ST.zw;
			float2 panner9 = ( 1.0 * _Time.y * _Speed + uv_NoiseMap);
			float Noise28 = tex2D( _NoiseMap, panner9 ).r;
			float clampResult23 = clamp( ( Noise28 - _Soft ) , 0.0 , 1.0 );
			float2 uv_GradientTex = i.uv_texcoord * _GradientTex_ST.xy + _GradientTex_ST.zw;
			float4 tex2DNode14 = tex2D( _GradientTex, uv_GradientTex );
			float Gradient24 = tex2DNode14.r;
			float smoothstepResult18 = smoothstep( clampResult23 , Noise28 , Gradient24);
			float4 _ShapeTex_ST_Instance = UNITY_ACCESS_INSTANCED_PROP(_ShapeTex_ST_arr, _ShapeTex_ST);
			float2 uv_ShapeTex = i.uv_texcoord * _ShapeTex_ST_Instance.xy + _ShapeTex_ST_Instance.zw;
			float Shape37 = tex2D( _ShapeTex, uv_ShapeTex ).r;
			float Alpha31 = saturate( ( smoothstepResult18 * Shape37 * Shape37 ) );
			o.Alpha = Alpha31;
		}

		ENDCG
		CGPROGRAM
		#pragma surface surf Unlit alpha:fade keepalpha fullforwardshadows 

		ENDCG
		Pass
		{
			Name "ShadowCaster"
			Tags{ "LightMode" = "ShadowCaster" }
			ZWrite On
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag
			#pragma target 3.0
			#pragma multi_compile_shadowcaster
			#pragma multi_compile UNITY_PASS_SHADOWCASTER
			#pragma skip_variants FOG_LINEAR FOG_EXP FOG_EXP2
			#include "HLSLSupport.cginc"
			#if ( SHADER_API_D3D11 || SHADER_API_GLCORE || SHADER_API_GLES || SHADER_API_GLES3 || SHADER_API_METAL || SHADER_API_VULKAN )
				#define CAN_SKIP_VPOS
			#endif
			#include "UnityCG.cginc"
			#include "Lighting.cginc"
			#include "UnityPBSLighting.cginc"
			sampler3D _DitherMaskLOD;
			struct v2f
			{
				V2F_SHADOW_CASTER;
				float2 customPack1 : TEXCOORD1;
				float3 worldPos : TEXCOORD2;
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			v2f vert( appdata_full v )
			{
				v2f o;
				UNITY_SETUP_INSTANCE_ID( v );
				UNITY_INITIALIZE_OUTPUT( v2f, o );
				UNITY_INITIALIZE_VERTEX_OUTPUT_STEREO( o );
				UNITY_TRANSFER_INSTANCE_ID( v, o );
				Input customInputData;
				float3 worldPos = mul( unity_ObjectToWorld, v.vertex ).xyz;
				half3 worldNormal = UnityObjectToWorldNormal( v.normal );
				o.customPack1.xy = customInputData.uv_texcoord;
				o.customPack1.xy = v.texcoord;
				o.worldPos = worldPos;
				TRANSFER_SHADOW_CASTER_NORMALOFFSET( o )
				return o;
			}
			half4 frag( v2f IN
			#if !defined( CAN_SKIP_VPOS )
			, UNITY_VPOS_TYPE vpos : VPOS
			#endif
			) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID( IN );
				Input surfIN;
				UNITY_INITIALIZE_OUTPUT( Input, surfIN );
				surfIN.uv_texcoord = IN.customPack1.xy;
				float3 worldPos = IN.worldPos;
				half3 worldViewDir = normalize( UnityWorldSpaceViewDir( worldPos ) );
				SurfaceOutput o;
				UNITY_INITIALIZE_OUTPUT( SurfaceOutput, o )
				surf( surfIN, o );
				#if defined( CAN_SKIP_VPOS )
				float2 vpos = IN.pos;
				#endif
				half alphaRef = tex3D( _DitherMaskLOD, float3( vpos.xy * 0.25, o.Alpha * 0.9375 ) ).a;
				clip( alphaRef - 0.01 );
				SHADOW_CASTER_FRAGMENT( IN )
			}
			ENDCG
		}
	}
	Fallback "Diffuse"
	CustomEditor "ASEMaterialInspector"
}
/*ASEBEGIN
Version=18500
2273;96;1411;861;1766.498;-344.3624;1.139278;True;False
Node;AmplifyShaderEditor.CommentaryNode;29;-1525.758,-212.4465;Inherit;False;1049.813;296.4515;Noise;5;28;6;9;2;10;Noise;1,1,1,1;0;0
Node;AmplifyShaderEditor.Vector2Node;10;-1446.171,-46.99482;Inherit;False;Property;_Speed;Speed;4;0;Create;True;0;0;False;0;False;0,0;0,-0.5;0;3;FLOAT2;0;FLOAT;1;FLOAT;2
Node;AmplifyShaderEditor.TextureCoordinatesNode;2;-1475.758,-162.4465;Inherit;False;0;6;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.PannerNode;9;-1210.958,-119.8333;Inherit;False;3;0;FLOAT2;0,0;False;2;FLOAT2;0,0;False;1;FLOAT;1;False;1;FLOAT2;0
Node;AmplifyShaderEditor.SamplerNode;6;-1003.172,-146.5675;Inherit;True;Property;_NoiseMap;NoiseMap;2;0;Create;True;0;0;False;0;False;-1;None;cd460ee4ac5c1e746b7a734cc7cc64dd;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;27;-2139.714,-929.3591;Inherit;False;1763.868;606.5885;Gradient;10;48;54;51;52;50;49;47;24;14;8;Gradient;1,1,1,1;0;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;8;-2089.714,-859.405;Inherit;False;0;14;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.CommentaryNode;33;-1607.367,169.5227;Inherit;False;1882.29;538.6056;Alpha;10;31;17;38;39;18;26;23;21;30;20;Alpha;1,1,1,1;0;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;28;-697.9449,-123.8549;Inherit;False;Noise;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;30;-1557.367,241.3352;Inherit;True;28;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;14;-1822.608,-879.3591;Inherit;True;Property;_GradientTex;GradientTex;3;0;Create;True;0;0;False;0;False;-1;None;4821f5ba214e10a4a89801fdf4965c5f;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RangedFloatNode;20;-1581.582,449.3416;Inherit;False;Property;_Soft;Soft;5;0;Create;True;0;0;False;0;False;0.1;0.19;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;21;-1287.671,342.1176;Inherit;False;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SamplerNode;36;-989.0528,1011.911;Inherit;True;Property;_ShapeTex;ShapeTex;1;0;Create;True;0;0;False;0;False;-1;None;4d9adfe8e6c941c4ba2952d97a78185c;True;0;False;white;Auto;False;Object;-1;Auto;Texture2D;8;0;SAMPLER2D;;False;1;FLOAT2;0,0;False;2;FLOAT;0;False;3;FLOAT2;0,0;False;4;FLOAT2;0,0;False;5;FLOAT;1;False;6;FLOAT;0;False;7;SAMPLERSTATE;;False;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;24;-1352.724,-881.1374;Inherit;False;Gradient;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;26;-1125.21,215.7003;Inherit;False;24;Gradient;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;37;-631.3428,1020.96;Inherit;False;Shape;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ClampOpNode;23;-1128.511,347.8108;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;39;-807.0428,470.8818;Inherit;False;37;Shape;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SmoothstepOpNode;18;-874.7877,229.5871;Inherit;True;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;1;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;38;-556.2679,324.7174;Inherit;False;3;3;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;17;-371.1371,318.8563;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.ColorNode;13;-80.22571,-397.0239;Inherit;False;Property;_FireColor;FireColor;0;1;[HDR];Create;True;0;0;False;0;False;0,0,0,0;1,0.8406706,0.06132078,0;True;0;5;COLOR;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.RegisterLocalVarNode;31;-205.8457,313.8484;Inherit;False;Alpha;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;50;-1599.653,-520.5146;Inherit;False;Property;_BottomPos;BottomPos;7;0;Create;True;0;0;False;0;False;0;0.291919;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;68;-1215.892,1025.276;Inherit;False;FLOAT2;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT2;0
Node;AmplifyShaderEditor.RangedFloatNode;44;-207.8076,-180.7595;Inherit;False;Property;_ChangeColor;ChangeColor;6;0;Create;True;0;0;False;0;False;0;0.3823529;0;5;0;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;66;-1565.741,1233.928;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;32;522.6611,152.4924;Inherit;False;31;Alpha;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;62;-1777.741,1182.928;Inherit;False;28;Noise;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;65;-1749.741,1284.928;Inherit;False;Constant;_Float0;Float 0;9;0;Create;True;0;0;False;0;False;0.1;0;0;0;0;1;FLOAT;0
Node;AmplifyShaderEditor.RegisterLocalVarNode;48;-678.8593,-596.5867;Inherit;True;bottom;-1;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.OneMinusNode;47;-1507.059,-745.5871;Inherit;True;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.GetLocalVarNode;56;-129.3894,-73.0296;Inherit;False;48;bottom;1;0;OBJECT;;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;61;319.5374,-236.9197;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.DynamicAppendNode;41;566.0225,-367.205;Inherit;False;FLOAT4;4;0;FLOAT;0;False;1;FLOAT;0;False;2;FLOAT;0;False;3;FLOAT;0;False;1;FLOAT4;0
Node;AmplifyShaderEditor.SimpleSubtractOpNode;49;-1296.654,-666.5147;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SaturateNode;54;-848.84,-588.9378;Inherit;False;1;0;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleMultiplyOpNode;43;148.7456,-170.6789;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.RangedFloatNode;52;-1366.84,-445.9376;Inherit;False;InstancedProperty;_BottomSoft;BottomSoft;8;0;Create;True;0;0;False;0;False;0.24;0.5105882;0;1;0;1;FLOAT;0
Node;AmplifyShaderEditor.TextureCoordinatesNode;35;-1667.092,1011.215;Inherit;False;0;36;2;3;2;SAMPLER2D;;False;0;FLOAT2;1,1;False;1;FLOAT2;0,0;False;5;FLOAT2;0;FLOAT;1;FLOAT;2;FLOAT;3;FLOAT;4
Node;AmplifyShaderEditor.SimpleDivideOpNode;51;-1077.84,-594.9378;Inherit;True;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.SimpleAddOpNode;64;-1388.741,968.9282;Inherit;False;2;2;0;FLOAT;0;False;1;FLOAT;0;False;1;FLOAT;0
Node;AmplifyShaderEditor.StandardSurfaceOutputNode;0;766.1181,-46.00163;Float;False;True;-1;2;ASEMaterialInspector;0;0;Unlit;Jefford/FireDissolve_CarToon(火溶溶解);False;False;False;False;False;False;False;False;False;False;False;False;False;False;True;False;False;False;False;False;False;Off;0;False;-1;0;False;-1;False;0;False;-1;0;False;-1;False;0;Transparent;0.5;True;True;0;False;Transparent;;Transparent;All;14;all;True;True;True;True;0;False;-1;False;0;False;-1;255;False;-1;255;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;-1;False;2;15;10;25;False;0.5;True;2;5;False;-1;10;False;-1;0;0;False;-1;0;False;-1;0;False;-1;0;False;-1;0;False;0;0,0,0,0;VertexOffset;True;False;Cylindrical;False;Relative;0;;-1;-1;-1;-1;0;False;0;0;False;-1;-1;0;False;-1;0;0;0;False;0.1;False;-1;0;False;-1;False;15;0;FLOAT3;0,0,0;False;1;FLOAT3;0,0,0;False;2;FLOAT3;0,0,0;False;3;FLOAT;0;False;4;FLOAT;0;False;6;FLOAT3;0,0,0;False;7;FLOAT3;0,0,0;False;8;FLOAT;0;False;9;FLOAT;0;False;10;FLOAT;0;False;13;FLOAT3;0,0,0;False;11;FLOAT3;0,0,0;False;12;FLOAT3;0,0,0;False;14;FLOAT4;0,0,0,0;False;15;FLOAT3;0,0,0;False;0
WireConnection;9;0;2;0
WireConnection;9;2;10;0
WireConnection;6;1;9;0
WireConnection;28;0;6;1
WireConnection;14;1;8;0
WireConnection;21;0;30;0
WireConnection;21;1;20;0
WireConnection;24;0;14;1
WireConnection;37;0;36;1
WireConnection;23;0;21;0
WireConnection;18;0;26;0
WireConnection;18;1;23;0
WireConnection;18;2;30;0
WireConnection;38;0;18;0
WireConnection;38;1;39;0
WireConnection;38;2;39;0
WireConnection;17;0;38;0
WireConnection;31;0;17;0
WireConnection;68;0;64;0
WireConnection;68;1;35;2
WireConnection;66;0;62;0
WireConnection;66;1;65;0
WireConnection;48;0;54;0
WireConnection;47;0;14;1
WireConnection;61;0;13;2
WireConnection;61;1;43;0
WireConnection;41;0;13;1
WireConnection;41;1;13;2
WireConnection;41;2;13;3
WireConnection;49;0;47;0
WireConnection;49;1;50;0
WireConnection;54;0;51;0
WireConnection;43;0;44;0
WireConnection;43;1;56;0
WireConnection;51;0;49;0
WireConnection;51;1;52;0
WireConnection;64;0;35;1
WireConnection;64;1;66;0
WireConnection;0;2;41;0
WireConnection;0;9;32;0
ASEEND*/
//CHKSM=366BF1C0EE3550D7F1FC1508F04FAAA791CA63A0