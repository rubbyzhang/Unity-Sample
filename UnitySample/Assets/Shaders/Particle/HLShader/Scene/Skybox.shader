Shader "HL/Scene/Skybox" {
Properties {
    //_Tint ("Tint Color", Color) = (.5, .5, .5, 1)
    _FogTint ("Fog Tint", Color) = (1, 1, 1, 0.1)
    _FrontTex ("Front (+Z)", 2D) = "white" {}
    _BackTex ("Back (-Z)", 2D) = "white" {}
    _LeftTex ("Left (+X)", 2D) = "white" {}
    _RightTex ("Right (-X)", 2D) = "white" {}
    _UpTex ("Up (+Y)", 2D) = "white" {}
    _DownTex ("Down (-Y)", 2D) = "white" {}
}

SubShader {
    Tags { "Queue" = "Background-100" }
    Cull Off
	Lighting Off
	Blend Off
    Fog { Mode Off }
    Color [_Tint]
    
	Pass {
        SetTexture [_FrontTex] { constantColor[_FogTint] combine constant lerp(constant) texture }
    }
    Pass {
        SetTexture [_BackTex] { constantColor[_FogTint] combine constant lerp(constant) texture }
    }
    Pass {
        SetTexture [_LeftTex] { constantColor[_FogTint] combine constant lerp(constant) texture }
    }
    Pass {
        SetTexture [_RightTex] { constantColor[_FogTint] combine constant lerp(constant) texture }
    }
    Pass {
        SetTexture [_UpTex] { constantColor[_FogTint] combine constant lerp(constant) texture }
    }
    Pass {
        SetTexture [_DownTex] { constantColor[_FogTint] combine constant lerp(constant) texture }
    }
}

//Fallback "Mobile/Skybox"
} 