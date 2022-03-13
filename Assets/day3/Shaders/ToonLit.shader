Shader "MyToon/Lit" {
	Properties {
		_Color ("Main Color", Color) = (0.5,0.5,0.5,1)
		_MainTex ("Base (RGB)", 2D) = "white" {}
		_Ramp ("Toon Ramp (RGB)", 2D) = "gray" {} 
	}

	SubShader {
		Tags { "RenderType"="Opaque" }
		LOD 200

        Pass {
            Tags { "LightMode" = "ForwardBase" }
		
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            #include "AutoLight.cginc"

            sampler2D _Ramp;
            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            struct appdata
            {
                float4 vertex   : POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
            };            

            struct v2f
            {
                float4 vertex   : SV_POSITION;
                float3 normal   : NORMAL;
                float2 uv       : TEXCOORD0;
                float4 worldPos : TEXCOORD1;
                float3 lightDir : TEXCOORD2;
                LIGHTING_COORDS(3,4)
            };

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                // 頂点のワールド座標を求めておく
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.lightDir = normalize(UnityWorldSpaceLightDir(o.worldPos));

                return o;
            }        


            fixed4 frag(v2f i) : SV_Target
            {
                float3 lightDir = i.lightDir;

                #ifndef USING_DIRECTIONAL_LIGHT
                lightDir = normalize(lightDir);
                #endif
                
                half d = dot (i.normal, lightDir)*0.5 + 0.5;
                half3 ramp = tex2D (_Ramp, float2(d,d)).rgb;

                float4 finalColor = 0;
                float4 c = tex2D(_MainTex, i.uv) * _Color;
                finalColor.rgb += c.rgb * ShadeSH9 (float4(i.normal,1.0));

                UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos.xyz);

                finalColor.rgb += c.rgb * _LightColor0.rgb * ramp * (atten * 2);
                finalColor.a = c.a;

                return finalColor;
            }

            ENDCG
        }

	} 
}
