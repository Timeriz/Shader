Shader "Unlit/Shader"{
    Properties{
        _Color ("Color", Color) = (1,1,1,1)
        _Amplitude("Amplitude", Float) = 1
        _Speed ("Speed", Float) = 1
    }
    SubShader{
        Tags { "RenderType"="Opaque" }

        Pass{
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            float4 _Color;
            float _Amplitude;
            float _Speed;


            struct MeshData{//Per vertex
                float4 vertex : POSITION; //Vertex position
                float2 uv : TEXCOORD0; //uv coords
            };

            struct Interpolators{ //data that gets passed from vertex shader to fragment shader
                float4 vertex : SV_POSITION; //Clip space position for each vertex
                //float2 uv : TEXCOORD0; 
            };

            Interpolators vert (MeshData v){
                Interpolators o;
                v.vertex.y += tan(_Time.y * _Speed + v.vertex.y * _Amplitude) ;
                o.vertex = UnityObjectToClipPos(v.vertex); //Localspace to clipspace
                return o;
            }

            fixed4 frag (Interpolators i) : SV_Target{
                return _Color;
            }
            ENDCG
        }
        //Shadow casting pass
        Pass{
            Tags{"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"
            float4 _Color;
            float _Amplitude;
            float _Speed;

            struct Interpolators{
                V2F_SHADOW_CASTER;
            };
            Interpolators vert(appdata_base v)
            {
                Interpolators o;
                v.vertex.y += tan(_Time.y * _Speed + v.vertex.y * _Amplitude) ;
                TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                return o;
            }
            float4 frag(Interpolators i) : SV_Target{
                SHADOW_CASTER_FRAGMENT(i)
            }
            ENDCG

        }

    }
}
