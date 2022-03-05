Shader "Unlit/ex4"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Width ("Width Separate", int) = 2
        _Height ("Height Separete", int) = 2
        _Sec ("Change Sec", float) = 0.1
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue" = "Transparent"}
        Blend SrcAlpha OneMinusSrcAlpha
        BlendOp Add

        Pass
        {
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
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Width;
            float _Height;
            float _Sec;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                float2 xy = 1.0 / float2(_Width, _Height);

                // 1秒ごとに0~63の値が返ってくる
                float index = floor(_Time.y / _Sec % (_Width * _Height));
                // 最後の * xy で1マス分の大きさにしている
                // + float2() で1マスごと移動させている　
                // y方向に関しては、8秒ごとに-1したい

                // 下方向に進むようにしたいので、v軸を反転させる
                v.uv.y *= -1;
                o.uv = (TRANSFORM_TEX(v.uv, _MainTex) + float2(index % _Width, -floor(index / _Width))) * xy;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            { 
                return tex2D(_MainTex, i.uv);
            }
            ENDCG
        }
    }
}
