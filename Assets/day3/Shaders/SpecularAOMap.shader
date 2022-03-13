Shader "Custom/SpecularAOMap"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _Specular ("Specular", 2D) = "white" {}
        _AO ("Ambient Occlusion",2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType" = "Opaque" }
        LOD 100

        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _Specular;
            float4 _Specular_ST;
            sampler2D _AO;
            float4 _AO_ST;

            v2f vert(appdata v)
            {
                v2f o;

                o.vertex = UnityObjectToClipPos(v.vertex);
                o.worldPos = mul(unity_ObjectToWorld, v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                // ディレクションライトのデータを作成する
                float3 ligDirection = normalize(_WorldSpaceLightPos0.xyz);
                // ピクセルが受けているライトの光を求める
                fixed3 ligColor = _LightColor0.xyz; // #include "Lighting.cginc" にて定義

                /*** 拡散反射 ***/

                float t = dot(i.normal, ligDirection);
                t = max(0.0f, t);

                fixed3 diffuseLig = ligColor * t;

                /*** 鏡面反射 ***/

                float3 refVec = reflect(ligDirection, i.normal);
                float3 toEye = normalize(_WorldSpaceCameraPos - i.worldPos);

                t = dot(refVec, toEye);
                t = max(0.0f, t);

                t = pow(t, 5.0f);

                float3 specularLig = ligColor * t;

                half specPower = tex2D(_Specular, i.uv).r;
                specularLig *= specPower;

                // 拡散反射光と鏡面反射光を足し算して、最終的な光を求める
                float3 lig = diffuseLig + specularLig;
                
                /*** 環境光 ***/
                half ambient = 0.3;
                half ambientPower = tex2D(_AO, i.uv).r;

                ambient *= ambientPower;

                lig += ambient;

                float4 finalColor = tex2D(_MainTex, i.uv);

                // 最終出力カラーに光を乗算する
                finalColor.xyz *= lig;

                return finalColor;
            }
            ENDCG
        }
    }
}
