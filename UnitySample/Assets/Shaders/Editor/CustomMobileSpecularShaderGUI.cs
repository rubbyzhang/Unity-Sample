using System;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering;

public class CustomMobileSpecularShaderGUI : MaterialEditor {
    private void ShaderPropertyImpl(Shader shader, int propertyIndex) {
        int i = propertyIndex;
        string label = ShaderUtil.GetPropertyDescription(shader, i);
        MaterialProperty prop = GetMaterialProperty(targets, i);
        switch (ShaderUtil.GetPropertyType(shader, i)) {
            case ShaderUtil.ShaderPropertyType.Range: // 浮点数范围
            {
                if (prop.name == "_Cutoff") {
                    Material targetMat = target as Material;
                    bool alphaTestOn = targetMat.shaderKeywords.Contains("_ALPHATEST_ON");

                    EditorGUI.BeginChangeCheck();
                    EditorGUI.showMixedValue = prop.hasMixedValue;

                        // Show the toggle control
                    alphaTestOn = EditorGUILayout.Toggle("Use Cut Off?", alphaTestOn);

                    EditorGUI.showMixedValue = false;
                    if (EditorGUI.EndChangeCheck()) {
                        if (!alphaTestOn) {
                            targetMat.SetOverrideTag("RenderType", "Transparent");
                            targetMat.SetFloat("_SrcBlend", (int)BlendMode.SrcAlpha);
                            targetMat.SetFloat("_DstBlend", (int)BlendMode.OneMinusSrcAlpha);
                            targetMat.SetFloat("_ZWrite", 0);
                            targetMat.renderQueue = (int)RenderQueue.Transparent;

                            SetKeyword(targetMat, "_ALPHABLEND_ON", true);
                            SetKeyword(targetMat, "_ALPHATEST_ON", false);
                        } else {
                            targetMat.SetFloat("_SrcBlend", 1);
                            targetMat.SetFloat("_DstBlend", 0);
                            targetMat.SetFloat("_ZWrite", 1);
                            targetMat.renderQueue = (int)RenderQueue.AlphaTest;

                            SetKeyword(targetMat, "_ALPHABLEND_ON", false);
                            SetKeyword(targetMat, "_ALPHATEST_ON", true);
                        }
                    }
                }
                RangeProperty(prop, label);
                break;
            }
            case ShaderUtil.ShaderPropertyType.Float: // 浮点数
            {
                if (prop.name == "_Cull") {
                    EditorGUILayout.BeginHorizontal();
                    EditorGUI.BeginChangeCheck();
                    float labelWidth = EditorGUIUtility.labelWidth;
                    EditorGUIUtility.labelWidth = 0.0f;
                    EditorGUILayout.LabelField(label);
                    CullMode cullMode = (CullMode)EditorGUILayout.EnumPopup((CullMode)prop.floatValue, GUILayout.Width(60));
                    EditorGUIUtility.labelWidth = labelWidth;
                    if (EditorGUI.EndChangeCheck())
                        prop.floatValue = (float)cullMode;

                    EditorGUILayout.EndHorizontal();
                    GUILayout.Space(6f);
                    break;
                }
                if (prop.name == "_SrcBlend" || prop.name == "_DstBlend" || prop.name == "_ZWrite")
                    break;
                FloatProperty(prop, label);
                break;
            }
            case ShaderUtil.ShaderPropertyType.Color: // 颜色
            {
                ColorProperty(prop, label);
                break;
            }
            case ShaderUtil.ShaderPropertyType.TexEnv: // 材质
            {
                TextureProperty(prop, prop.displayName, true);
                break;
            }
            case ShaderUtil.ShaderPropertyType.Vector: // 向量
            {
                VectorProperty(prop, label);
                break;
            }
            default: {
                GUILayout.Label("ARGH" + label + " : " + ShaderUtil.GetPropertyType(shader, i));
                break;
            }
        }
    }

    public override void OnInspectorGUI() {
        serializedObject.Update();
        SerializedProperty theShader = serializedObject.FindProperty("m_Shader");
        if (isVisible && !theShader.hasMultipleDifferentValues && theShader.objectReferenceValue != null) {
            float controlSize = 64;

            EditorGUIUtility.labelWidth = Screen.width - controlSize - 40;
            EditorGUIUtility.fieldWidth = controlSize;

            EditorGUI.BeginChangeCheck();
            Shader shader = theShader.objectReferenceValue as Shader;

            for (int i = 0; i < ShaderUtil.GetPropertyCount(shader); i++) {
                if (CheckHasBasedTexture(shader, i)) continue;
                if (CheckBasedTextureHasAlpha(shader, i)) continue;

                ShaderPropertyImpl(shader, i);
            }

            Material targetMat = target as Material;
            string[] keyWords = targetMat.shaderKeywords;
            bool usePointLight1 = keyWords.Contains("POINT_LIGHT_COLOR1");
            bool usePointLight2 = keyWords.Contains("POINT_LIGHT_COLOR2");

            int PointLightIndex = 0;
            if (usePointLight1) PointLightIndex = 1;
            if (usePointLight2) PointLightIndex = 2;

            int CurPointLightIndex = EditorGUILayout.Popup("POINT_LIGHT_COLOR", PointLightIndex, new[] { "Default", "First", "Second" });

            if (PointLightIndex != CurPointLightIndex) {
                SetKeyword(targetMat, "POINT_LIGHT_COLOR1", CurPointLightIndex == 1);
                SetKeyword(targetMat, "POINT_LIGHT_COLOR2", CurPointLightIndex == 2);
            }

            if (EditorGUI.EndChangeCheck())
                PropertiesChanged();
        }
    }

    private static readonly Dictionary<string, string> m_OptMap = new Dictionary<string, string> {
        {"_NoiseMap", "_BumpMapTex"},
        {"_AlphaPower", "_BumpMapTex"},
        {"_BumpTiling", "_NoiseMap"},
        {"_BumpDirection", "_NoiseMap"},
        {"_NoiseScale", "_NoiseMap"},
        {"_NoiseFactor", "_NoiseMap"},
        {"_EmissionColor", "_EmissionMap"}
    };

    private bool CheckHasBasedTexture(Shader shader, int propertyIndex) {
        Material material = target as Material;
        if (material == null) return false;
        string propertyName = ShaderUtil.GetPropertyName(shader, propertyIndex);
        if (m_OptMap.ContainsKey(propertyName)) return material.GetTexture(m_OptMap[propertyName]) == null;

        return false;
    }

    private bool CheckBasedTextureHasAlpha(Shader shader, int propertyIndex) {
        Material material = target as Material;
        if (material == null) return false;
        string propertyName = ShaderUtil.GetPropertyName(shader, propertyIndex);
        if (propertyName == "_Cutoff") {
#if UNITY_EDITOR_WIN
            Texture tex = material.GetTexture("_MainTex");
            return tex == null || !HasAlpha(tex as Texture2D);
#endif
        }

        return false;
    }

    private new void PropertiesChanged() {
        Material targetMat = target as Material;

        // clear standard render type
        targetMat.SetOverrideTag("RenderType", string.Empty);

#if UNITY_EDITOR_WIN
        Texture tex = targetMat.GetTexture("_MainTex");
        bool alphaTestOn = tex != null && HasAlpha(tex as Texture2D);
        
        if (!alphaTestOn) {
            SetKeyword(targetMat, "_ALPHATEST_ON", false);
            SetKeyword(targetMat, "_ALPHABLEND_ON", false);
        }
        else if(!targetMat.shaderKeywords.Contains("_ALPHATEST_ON") && !targetMat.shaderKeywords.Contains("_ALPHABLEND_ON")) {
            SetKeyword(targetMat, "_ALPHATEST_ON", true);
        }
#endif

        SetKeyword(targetMat, "_NOISEMAP_ON", targetMat.GetTexture("_NoiseMap") != null);
        SetKeyword(targetMat, "_EMISSION", targetMat.GetTexture("_EmissionMap") != null);
        SetKeyword(targetMat, "_NORMALMAP_ON", targetMat.GetTexture("_BumpMapTex") != null);
    }

    private static void SetKeyword(Material m, string keyword, bool state) {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }

    public static bool HasAlpha(Texture2D texture) {
        return texture.format == TextureFormat.Alpha8 || texture.format == TextureFormat.ARGB4444
               || texture.format == TextureFormat.RGBA32 || texture.format == TextureFormat.ARGB32
               || texture.format == TextureFormat.DXT5 || texture.format == TextureFormat.RGBA4444
               || texture.format == TextureFormat.BGRA32 || texture.format == TextureFormat.RGBAHalf
               || texture.format == TextureFormat.RGBAFloat || texture.format == TextureFormat.PVRTC_RGBA2
               || texture.format == TextureFormat.PVRTC_RGBA4 || texture.format == TextureFormat.ATC_RGBA8
               || texture.format == TextureFormat.ETC2_RGBA1 || texture.format == TextureFormat.ETC2_RGBA8
               || texture.format == TextureFormat.ASTC_RGBA_4x4 || texture.format == TextureFormat.ASTC_RGBA_5x5
               || texture.format == TextureFormat.ASTC_RGBA_6x6 || texture.format == TextureFormat.ASTC_RGBA_8x8
               || texture.format == TextureFormat.ASTC_RGBA_10x10 || texture.format == TextureFormat.ASTC_RGBA_12x12
               || texture.format == TextureFormat.ETC_RGBA8_3DS;
    }
}
