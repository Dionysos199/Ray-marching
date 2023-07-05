Shader "Custom/CloudShader"
{
    Properties
    {
        _MainTex ("Texture", 3D) = "white" {}
        _CloudDensity ("Cloud Density", Range(0.1, 1.0)) = 0.5
        _CloudSpeed ("Cloud Speed", Range(0.1, 10.0)) = 1.0
        _CloudScale ("Cloud Scale", Range(1.0, 100.0)) = 10.0
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
            
            float _CloudDensity;
            float _CloudSpeed;
            float _CloudScale;
            sampler3D _MainTex;
            
            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;
                return o;
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                float2 uv = i.uv * _CloudScale;
                float2 p = uv;
                float cloudDensity = _CloudDensity;
                float cloudSpeed = _CloudSpeed;
                float cloudHeight = 0.5;
                
                float3 col = float3(0.0, 0.0, 0.0);
                float t = 0.0;
                
                // Raymarching loop
                for (int j = 0; j < 50; j++)
                {
                    float3 ray = float3(p, cloudHeight);
                    float3 pos = ray * t;
                    
                    // Sample density from 3D noise texture
                    float density = tex3D(_MainTex, pos).r;
                    
                    // Accumulate color based on density
                    col += density * float3(1.0, 1.0, 1.0);
                    
                    // Increment time and raymarch distance
                    t += 0.01;
                    
                    // Exit the loop if we're inside the cloud
                    if (density > cloudDensity)
                        break;
                }
                
                // Apply lighting and return final color
                col *= 0.2;
                
                return fixed4(col, 1.0);
            }
            
            ENDCG
        }
    }
}
