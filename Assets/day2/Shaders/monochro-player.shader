Shader "Unlit/monochro-player"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="opaque" "Queue"="Geometry+1" }
        LOD 100
       // Blend SrcAlpha OneMinusSrcAlpha

        GrabPass {}

        
        Pass
        {
            ZTest Always
            Stencil
            {
                Ref 1
                Comp Always
                Pass IncrSat
            }
            ColorMask 0
            ZWrite off
        }

        Pass
        {
            ZTest Always
            Stencil
            {
                Ref 2
                Comp Equal
            }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 screenPos : TEXCOORD1;
            };
            sampler2D _GrabTexture;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.screenPos = ComputeGrabScreenPos(o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                half2 grabUV = (i.screenPos.xy / i.screenPos.w);
                fixed4 color = tex2D(_GrabTexture, grabUV);
                // NTSC加重平均法
                fixed gray = dot(color.rgb, fixed3(0.299, 0.587, 0.114));
                
                return float4(gray, gray, gray, color.a);
            }
            ENDCG
        }
    }
}
