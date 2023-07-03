Shader "Unlit/SunShaftEffect"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Albedo("Albedo", Color) = (1,1,1)
        _Step("Luminance Step", Float) = 1
        _Step2("Luminance Step 2", Float) = 0
        _BlurRadius("Blur Radius", Float) = 0
        _BlurStep("Blur Step", Integer) = 1
        _ShaftAlpha("Shaft Alpha", Range( 0 , 5)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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

            uniform float4 _SunPos;
            fixed4 _Albedo;
            float _BlurRadius;
            float _Step;
            float _Step2;
            float _ShaftAlpha;
            int _BlurStep;
            float _SunVisible;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            UNITY_DECLARE_DEPTH_TEXTURE(_CameraDepthTexture);
			uniform float4 _CameraDepthTexture_TexelSize;

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                float2 blurVector = (_SunPos.xy - i.uv.xy) * _BlurRadius.xx;
                fixed4 col = tex2D(_MainTex, i.uv);

                if(_SunVisible == 0) return col;
                
                fixed4 color = half4(0,0,0,0);
                for (int j = 0; j < _BlurStep; j++)
                {
                    fixed4 tmpColor = UNITY_SAMPLE_SCREENSPACE_TEXTURE(_MainTex, i.uv.xy);
                    float ray = smoothstep(_Step, _Step2, dot(tmpColor.rgb, float3(0.2126, 0.7152, 0.0722)));
                    tmpColor *= ray;
                    color += tmpColor * 0.01;
                    i.uv.xy += blurVector;
                }
                return col + saturate(color * _ShaftAlpha) * _Albedo * _SunVisible;
            }
            ENDCG
        }
    }
}
