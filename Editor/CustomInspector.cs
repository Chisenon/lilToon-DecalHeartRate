#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace lilToon
{    public class DHBInspector : lilToonInspector
    {
        MaterialProperty _FloatHeartRateC;
        MaterialProperty _ActiveDecalNumber;
        MaterialProperty _ActiveDecalTexture;
        MaterialProperty _HideDecalNumberWhenZero;
        MaterialProperty _SpriteNumberTexture;
        MaterialProperty _SpriteNumberTextureColor;
        MaterialProperty _NumberTextureBlendMode;
        MaterialProperty _DecalTexture;
        MaterialProperty _DecalTextureColor;
        MaterialProperty _DecalTextureBlendMode;
        MaterialProperty _DecalPositionXVector;
        MaterialProperty _DecalPositionYVector;
        MaterialProperty _DecalScaleXVector;
        MaterialProperty _DecalScaleYVector;
        MaterialProperty _DecalRotation;
        MaterialProperty _TexPositionXVector;
        MaterialProperty _TexPositionYVector;
        MaterialProperty _TexScaleXVector;
        MaterialProperty _TexScaleYVector;
        MaterialProperty _NumTexRotation;
        MaterialProperty _NumTexDisplaylength;
        MaterialProperty _NumTexAlignment;
        MaterialProperty _NumTexCharacterOffset;
        MaterialProperty _NumTexDigitSpacing;
        MaterialProperty _SyncDecalNumberTextureScale;
        MaterialProperty _SyncDecalTextureScale;
        MaterialProperty _DecalNumberEmissionStrength;
        MaterialProperty _DecalTextureEmissionStrength;
        MaterialProperty _UseHeartRateEmission;
        MaterialProperty _HeartRateEmissionMin;
        MaterialProperty _HeartRateEmissionMax;
        MaterialProperty _UseHeartRateEmissionTexture;
        MaterialProperty _HeartRateEmissionMinTexture;
        MaterialProperty _HeartRateEmissionMaxTexture;
        MaterialProperty _UseHeartRateScaleTexture;
        MaterialProperty _HeartRateScaleIntensity;
        
        // Number Decal Emission Mask and Color
        MaterialProperty _DecalNumberEmissionMask;
        MaterialProperty _DecalNumberEmissionColor;
        MaterialProperty _DecalNumberMainColorPower;
        
        // Texture Decal Emission Mask and Color
        MaterialProperty _DecalTextureEmissionMask;
        MaterialProperty _DecalTextureEmissionColor;
        MaterialProperty _DecalTextureMainColorPower;

        private static bool isShowCustomProperties;
        private const string shaderName = "ChiseNote/DecalHeartRate";


        protected override void LoadCustomProperties(MaterialProperty[] props, Material material)
        {
            isCustomShader = true;
            ReplaceToCustomShaders();
            isShowRenderMode = !material.shader.name.Contains("Optional");
            _FloatHeartRateC = FindProperty("_FloatHeartRateC", props);
            _ActiveDecalNumber = FindProperty("_ActiveDecalNumber", props);
            _ActiveDecalTexture = FindProperty("_ActiveDecalTexture", props);
            _HideDecalNumberWhenZero = FindProperty("_HideDecalNumberWhenZero", props);
            _SpriteNumberTexture = FindProperty("_SpriteNumberTexture", props);
            _SpriteNumberTextureColor = FindProperty("_SpriteNumberTextureColor", props);
            _NumberTextureBlendMode = FindProperty("_NumberTextureBlendMode", props);
            _DecalTexture = FindProperty("_DecalTexture", props);
            _DecalTextureColor = FindProperty("_DecalTextureColor", props);
            _DecalTextureBlendMode = FindProperty("_DecalTextureBlendMode", props);
            _DecalPositionXVector = FindProperty("_DecalPositionXVector", props);
            _DecalPositionYVector = FindProperty("_DecalPositionYVector", props);
            _DecalScaleXVector = FindProperty("_DecalScaleXVector", props);
            _DecalScaleYVector = FindProperty("_DecalScaleYVector", props);
            _DecalRotation = FindProperty("_DecalRotation", props);
            _TexPositionXVector = FindProperty("_TexPositionXVector", props);
            _TexPositionYVector = FindProperty("_TexPositionYVector", props);
            _TexScaleXVector = FindProperty("_TexScaleXVector", props);
            _TexScaleYVector = FindProperty("_TexScaleYVector", props);
            _NumTexRotation = FindProperty("_NumTexRotation", props);
            _NumTexDisplaylength = FindProperty("_NumTexDisplaylength", props);
            _NumTexAlignment = FindProperty("_NumTexAlignment", props);
            _NumTexCharacterOffset = FindProperty("_NumTexCharacterOffset", props);
            _NumTexDigitSpacing = FindProperty("_NumTexDigitSpacing", props);
            _SyncDecalNumberTextureScale = FindProperty("_SyncDecalNumberTextureScale", props);
            _SyncDecalTextureScale = FindProperty("_SyncDecalTextureScale", props);
            _DecalNumberEmissionStrength = FindProperty("_DecalNumberEmissionStrength", props);
            _DecalTextureEmissionStrength = FindProperty("_DecalTextureEmissionStrength", props);
            _UseHeartRateEmission = FindProperty("_UseHeartRateEmission", props);
            _HeartRateEmissionMin = FindProperty("_HeartRateEmissionMin", props);
            _HeartRateEmissionMax = FindProperty("_HeartRateEmissionMax", props);
            _UseHeartRateEmissionTexture = FindProperty("_UseHeartRateEmissionTexture", props);
            _HeartRateEmissionMinTexture = FindProperty("_HeartRateEmissionMinTexture", props);
            _HeartRateEmissionMaxTexture = FindProperty("_HeartRateEmissionMaxTexture", props);
            _UseHeartRateScaleTexture = FindProperty("_UseHeartRateScaleTexture", props);
            _HeartRateScaleIntensity = FindProperty("_HeartRateScaleIntensity", props);
            
            // Load new emission properties
            _DecalNumberEmissionMask = FindProperty("_DecalNumberEmissionMask", props);
            _DecalNumberEmissionColor = FindProperty("_DecalNumberEmissionColor", props);
            _DecalNumberMainColorPower = FindProperty("_DecalNumberMainColorPower", props);
            _DecalTextureEmissionMask = FindProperty("_DecalTextureEmissionMask", props);
            _DecalTextureEmissionColor = FindProperty("_DecalTextureEmissionColor", props);
            _DecalTextureMainColorPower = FindProperty("_DecalTextureMainColorPower", props);
        }
        protected override void DrawCustomProperties(Material material)
        {
            isShowCustomProperties = Foldout("Decal Heart Rate", "Decal Menu", isShowCustomProperties);
            if(isShowCustomProperties)
            {
                // ===== OSC SETTINGS =====
                EditorGUILayout.BeginVertical(boxOuter);
                EditorGUILayout.LabelField("Heart Rate Settings", customToggleFont);
                EditorGUILayout.BeginVertical(boxInnerHalf);
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(_FloatHeartRateC, "Heart Rate (OSC)");
                EditorGUILayout.HelpBox("Connect heart rate value via OSC for dynamic effects.", MessageType.Info);
                EditorGUI.indentLevel--;
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();

                EditorGUILayout.Space();

                // ===== NUMBER DECAL =====
                EditorGUILayout.BeginVertical(boxOuter);
                m_MaterialEditor.ShaderProperty(_ActiveDecalNumber, "Number Decal");

                if(_ActiveDecalNumber.floatValue == 1)
                {
                    EditorGUILayout.BeginVertical(boxInnerHalf);

                    EditorGUILayout.LabelField("Texture", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Number Texture"), _SpriteNumberTexture, _SpriteNumberTextureColor);

                    m_MaterialEditor.ShaderProperty(_NumberTextureBlendMode, "Blend Mode");

                    string[] samplePaths = new string[] {
                        "Packages\\net.chisenon.liltoon-decalheartrate\\Texture\\NumberTexture.png",
                        "Assets\\ChiseNote\\lilToon-DecalHeartRate\\Texture\\NumberTexture.png"
                    };
                    Texture2D sampleTexFound = null;
                    string sampleFoundPath = null;
                    foreach (var p in samplePaths)
                    {
                        var t = AssetDatabase.LoadAssetAtPath<Texture2D>(p);
                        if (t != null)
                        {
                            sampleTexFound = t;
                            sampleFoundPath = p;
                            break;
                        }
                    }

                    EditorGUILayout.BeginVertical();
                    if (sampleTexFound != null)
                    {
                        if (GUILayout.Button("Set Sample Texture"))
                        {
                            foreach (var obj in m_MaterialEditor.targets)
                            {
                                var mat = obj as Material;
                                if (mat != null)
                                {
                                    Undo.RecordObject(mat, "Assign Sample Number Texture");
                                    mat.SetTexture("_SpriteNumberTexture", sampleTexFound);
                                    EditorUtility.SetDirty(mat);
                                }
                            }
                        }
                    }
                    else
                    {
                        EditorGUI.BeginDisabledGroup(true);
                        GUILayout.Button("Sample Texture Not Found");
                        EditorGUI.EndDisabledGroup();
                    }

                    string[] prefabPaths = new string[] {
                        "Packages\\net.chisenon.font2tex\\Font2Tex.prefab",
                        "Assets\\ChiseNote\\Font2Texture\\Font2Tex.prefab"
                    };
                    GameObject prefab = null;
                    string prefabFoundPath = null;
                    foreach (var pp in prefabPaths)
                    {
                        prefab = AssetDatabase.LoadAssetAtPath<GameObject>(pp);
                        if (prefab != null)
                        {
                            prefabFoundPath = pp;
                            break;
                        }
                    }

                    if (prefab != null)
                    {
                        if (GUILayout.Button("Spawn Texture Generator"))
                        {
                            GameObject existingInstance = null;
                            for (int si = 0; si < UnityEngine.SceneManagement.SceneManager.sceneCount; si++)
                            {
                                var scene = UnityEngine.SceneManagement.SceneManager.GetSceneAt(si);
                                if (!scene.isLoaded) continue;
                                var roots = scene.GetRootGameObjects();
                                foreach (var root in roots)
                                {
                                    var transforms = root.GetComponentsInChildren<Transform>(true);
                                    foreach (var t in transforms)
                                    {
                                        var src = PrefabUtility.GetCorrespondingObjectFromSource(t.gameObject);
                                        if (src == prefab)
                                        {
                                            existingInstance = t.gameObject;
                                            break;
                                        }
                                    }
                                    if (existingInstance != null) break;
                                }
                                if (existingInstance != null) break;
                            }

                            if (existingInstance != null)
                            {
                                Selection.activeGameObject = existingInstance;
                                EditorGUIUtility.PingObject(existingInstance);
                                EditorUtility.DisplayDialog("Already exists", "A Font2Tex prefab instance already exists in the hierarchy. Selecting existing instance.", "OK");
                            }
                            else
                            {
                                var instance = PrefabUtility.InstantiatePrefab(prefab) as GameObject;
                                if (instance != null)
                                {
                                    Undo.RegisterCreatedObjectUndo(instance, "Spawn Texture Generator");
                                    Selection.activeGameObject = instance;
                                }
                            }
                        }
                    }
                    else
                    {
                        EditorGUI.BeginDisabledGroup(true);
                        GUILayout.Button("Texture Generator Not Found");
                        EditorGUI.EndDisabledGroup();
                    }
                    EditorGUILayout.EndVertical();
                    EditorGUI.indentLevel--;

                    DrawLine();

                    EditorGUILayout.LabelField("Visibility", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.ShaderProperty(_HideDecalNumberWhenZero, "Visibility Mode");
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Transform Settings
                    EditorGUILayout.LabelField("Transform", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    
                    // Position
                    EditorGUI.BeginChangeCheck();
                    Vector4 positionXVector = _TexPositionXVector.vectorValue;
                    Vector4 positionYVector = _TexPositionYVector.vectorValue;
                    positionXVector.x = EditorGUILayout.Slider("Position X", positionXVector.x, -1.0f, 1.0f);
                    positionYVector.x = EditorGUILayout.Slider("Position Y", positionYVector.x, -1.0f, 1.0f);
                    if(EditorGUI.EndChangeCheck())
                    {
                        _TexPositionXVector.vectorValue = positionXVector;
                        _TexPositionYVector.vectorValue = positionYVector;
                    }

                    // Scale
                    m_MaterialEditor.ShaderProperty(_SyncDecalNumberTextureScale, "Sync Scale X/Y");
                    EditorGUI.BeginChangeCheck();
                    Vector4 scaleXVector = _TexScaleXVector.vectorValue;
                    Vector4 scaleYVector = _TexScaleYVector.vectorValue;
                    if(_SyncDecalNumberTextureScale.floatValue == 1)
                    {
                        float syncedScale = EditorGUILayout.Slider("Scale", scaleXVector.x, 0.0f, 1.0f);
                        scaleXVector.x = syncedScale;
                        scaleYVector.x = syncedScale;
                    }
                    else
                    {
                        scaleXVector.x = EditorGUILayout.Slider("Scale X", scaleXVector.x, 0.0f, 1.0f);
                        scaleYVector.x = EditorGUILayout.Slider("Scale Y", scaleYVector.x, 0.0f, 1.0f);
                    }
                    if(EditorGUI.EndChangeCheck())
                    {
                        _TexScaleXVector.vectorValue = scaleXVector;
                        _TexScaleYVector.vectorValue = scaleYVector;
                    }

                    // Rotation
                    m_MaterialEditor.ShaderProperty(_NumTexRotation, "Rotation");
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Display Settings
                    EditorGUILayout.LabelField("Display", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.ShaderProperty(_NumTexDisplaylength, "Display Length");
                    m_MaterialEditor.ShaderProperty(_NumTexAlignment, "Alignment");
                    m_MaterialEditor.ShaderProperty(_NumTexCharacterOffset, "Character Offset");
                    m_MaterialEditor.ShaderProperty(_NumTexDigitSpacing, "Digit Spacing");
                    EditorGUI.indentLevel--;
                    DrawLine();

                    // Emission Settings
                    EditorGUILayout.LabelField("Emission", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    // Emission Mask and Color
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Color / Mask", "Controls which areas emit light"), _DecalNumberEmissionMask, _DecalNumberEmissionColor);
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.ShaderProperty(_DecalNumberEmissionStrength, "Basic Emission Power");
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.ShaderProperty(_DecalNumberMainColorPower, "Main Color Power");
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.ShaderProperty(_UseHeartRateEmission, "Heart Rate Emission");
                    if(_UseHeartRateEmission.floatValue == 1)
                    {
                        _DecalNumberEmissionStrength.floatValue = 0;
                        EditorGUI.indentLevel++;
                        m_MaterialEditor.ShaderProperty(_HeartRateEmissionMin, "Min Intensity");
                        m_MaterialEditor.ShaderProperty(_HeartRateEmissionMax, "Max Intensity");
                        EditorGUILayout.HelpBox("Numbers will pulse with heart rate rhythm.", MessageType.Info);
                        EditorGUI.indentLevel--;
                    }
                    EditorGUI.indentLevel--;

                    EditorGUILayout.EndVertical();
                }
                
                EditorGUILayout.EndVertical();

                EditorGUILayout.Space();

                // ===== TEXTURE DECAL =====
                EditorGUILayout.BeginVertical(boxOuter);
                m_MaterialEditor.ShaderProperty(_ActiveDecalTexture, "Texture Decal");
                
                if(_ActiveDecalTexture.floatValue == 1)
                {
                    EditorGUILayout.BeginVertical(boxInnerHalf);
                    
                    // Texture Settings
                    EditorGUILayout.LabelField("Texture", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Decal Texture"), _DecalTexture, _DecalTextureColor);
                    m_MaterialEditor.ShaderProperty(_DecalTextureBlendMode, "Blend Mode");
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Transform Settings
                    EditorGUILayout.LabelField("Transform", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    
                    // Position
                    EditorGUI.BeginChangeCheck();
                    Vector4 decalPositionXVector = _DecalPositionXVector.vectorValue;
                    Vector4 decalPositionYVector = _DecalPositionYVector.vectorValue;
                    decalPositionXVector.x = EditorGUILayout.Slider("Position X", decalPositionXVector.x, -1.0f, 1.0f);
                    decalPositionYVector.x = EditorGUILayout.Slider("Position Y", decalPositionYVector.x, -1.0f, 1.0f);
                    if(EditorGUI.EndChangeCheck())
                    {
                        _DecalPositionXVector.vectorValue = decalPositionXVector;
                        _DecalPositionYVector.vectorValue = decalPositionYVector;
                    }

                    // Scale
                    m_MaterialEditor.ShaderProperty(_SyncDecalTextureScale, "Sync Scale X/Y");
                    EditorGUI.BeginChangeCheck();
                    Vector4 decalScaleXVector = _DecalScaleXVector.vectorValue;
                    Vector4 decalScaleYVector = _DecalScaleYVector.vectorValue;
                    if(_SyncDecalTextureScale.floatValue == 1)
                    {
                        float syncedScale = EditorGUILayout.Slider("Scale", decalScaleXVector.x, 0.0f, 1.0f);
                        decalScaleXVector.x = syncedScale;
                        decalScaleYVector.x = syncedScale;
                    }
                    else
                    {
                        decalScaleXVector.x = EditorGUILayout.Slider("Scale X", decalScaleXVector.x, 0.0f, 1.0f);
                        decalScaleYVector.x = EditorGUILayout.Slider("Scale Y", decalScaleYVector.x, 0.0f, 1.0f);
                    }
                    if(EditorGUI.EndChangeCheck())
                    {
                        _DecalScaleXVector.vectorValue = decalScaleXVector;
                        _DecalScaleYVector.vectorValue = decalScaleYVector;
                    }

                    // Rotation
                    m_MaterialEditor.ShaderProperty(_DecalRotation, "Rotation Angle");
                    EditorGUI.indentLevel--;                    DrawLine();

                    // Emission Settings
                    EditorGUILayout.LabelField("Emission", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    // Emission Mask and Color
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent("Color / Mask", "Controls which areas emit light"), _DecalTextureEmissionMask, _DecalTextureEmissionColor);
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.ShaderProperty(_DecalTextureEmissionStrength, "Basic Emission Power");
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.ShaderProperty(_DecalTextureMainColorPower, "Main Color Power");
                    EditorGUILayout.Space(3);
                    m_MaterialEditor.ShaderProperty(_UseHeartRateEmissionTexture, "Heart Rate Emission");
                    if(_UseHeartRateEmissionTexture.floatValue == 1)
                    {
                        _DecalTextureEmissionStrength.floatValue = 0;
                        EditorGUI.indentLevel++;
                        m_MaterialEditor.ShaderProperty(_HeartRateEmissionMinTexture, "Min Intensity");
                        m_MaterialEditor.ShaderProperty(_HeartRateEmissionMaxTexture, "Max Intensity");
                        EditorGUILayout.HelpBox("Numbers will pulse with heart rate rhythm.", MessageType.Info);
                        EditorGUI.indentLevel--;
                    }
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Heart Rate Scale Effects
                    EditorGUILayout.LabelField("Heart Rate Scale", EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.ShaderProperty(_UseHeartRateScaleTexture, "Enable Heart Rate Scale");
                    if(_UseHeartRateScaleTexture.floatValue == 1)
                    {
                        EditorGUI.indentLevel++;
                        
                        EditorGUI.BeginChangeCheck();
                        float currentValue = _HeartRateScaleIntensity.floatValue;
                        float displayValue = currentValue + 1.0f;
                        float newDisplayValue = EditorGUILayout.Slider("Heart Rate Scale", displayValue, 1.0f, 2.0f);
                        if(EditorGUI.EndChangeCheck())
                        {
                            _HeartRateScaleIntensity.floatValue = newDisplayValue - 1.0f;
                        }
                        
                        EditorGUILayout.HelpBox("Texture will pulse and bounce with heart rate using damped oscillation.", MessageType.Info);
                        EditorGUI.indentLevel--;
                    }
                    EditorGUI.indentLevel--;
                    
                    EditorGUILayout.EndVertical();
                }
                EditorGUILayout.EndVertical();
            }
        }

        protected override void ReplaceToCustomShaders()
        {
            lts         = Shader.Find(shaderName + "/lilToon");
            ltsc        = Shader.Find("Hidden/" + shaderName + "/Cutout");
            ltst        = Shader.Find("Hidden/" + shaderName + "/Transparent");
            ltsot       = Shader.Find("Hidden/" + shaderName + "/OnePassTransparent");
            ltstt       = Shader.Find("Hidden/" + shaderName + "/TwoPassTransparent");

            ltso        = Shader.Find("Hidden/" + shaderName + "/OpaqueOutline");
            ltsco       = Shader.Find("Hidden/" + shaderName + "/CutoutOutline");
            ltsto       = Shader.Find("Hidden/" + shaderName + "/TransparentOutline");
            ltsoto      = Shader.Find("Hidden/" + shaderName + "/OnePassTransparentOutline");
            ltstto      = Shader.Find("Hidden/" + shaderName + "/TwoPassTransparentOutline");

            ltsoo       = Shader.Find(shaderName + "/[Optional] OutlineOnly/Opaque");
            ltscoo      = Shader.Find(shaderName + "/[Optional] OutlineOnly/Cutout");
            ltstoo      = Shader.Find(shaderName + "/[Optional] OutlineOnly/Transparent");

            ltstess     = Shader.Find("Hidden/" + shaderName + "/Tessellation/Opaque");
            ltstessc    = Shader.Find("Hidden/" + shaderName + "/Tessellation/Cutout");
            ltstesst    = Shader.Find("Hidden/" + shaderName + "/Tessellation/Transparent");
            ltstessot   = Shader.Find("Hidden/" + shaderName + "/Tessellation/OnePassTransparent");
            ltstesstt   = Shader.Find("Hidden/" + shaderName + "/Tessellation/TwoPassTransparent");

            ltstesso    = Shader.Find("Hidden/" + shaderName + "/Tessellation/OpaqueOutline");
            ltstessco   = Shader.Find("Hidden/" + shaderName + "/Tessellation/CutoutOutline");
            ltstessto   = Shader.Find("Hidden/" + shaderName + "/Tessellation/TransparentOutline");
            ltstessoto  = Shader.Find("Hidden/" + shaderName + "/Tessellation/OnePassTransparentOutline");
            ltstesstto  = Shader.Find("Hidden/" + shaderName + "/Tessellation/TwoPassTransparentOutline");

            ltsl        = Shader.Find(shaderName + "/lilToonLite");
            ltslc       = Shader.Find("Hidden/" + shaderName + "/Lite/Cutout");
            ltslt       = Shader.Find("Hidden/" + shaderName + "/Lite/Transparent");
            ltslot      = Shader.Find("Hidden/" + shaderName + "/Lite/OnePassTransparent");
            ltsltt      = Shader.Find("Hidden/" + shaderName + "/Lite/TwoPassTransparent");

            ltslo       = Shader.Find("Hidden/" + shaderName + "/Lite/OpaqueOutline");
            ltslco      = Shader.Find("Hidden/" + shaderName + "/Lite/CutoutOutline");
            ltslto      = Shader.Find("Hidden/" + shaderName + "/Lite/TransparentOutline");
            ltsloto     = Shader.Find("Hidden/" + shaderName + "/Lite/OnePassTransparentOutline");
            ltsltto     = Shader.Find("Hidden/" + shaderName + "/Lite/TwoPassTransparentOutline");

            ltsref      = Shader.Find("Hidden/" + shaderName + "/Refraction");
            ltsrefb     = Shader.Find("Hidden/" + shaderName + "/RefractionBlur");
            ltsfur      = Shader.Find("Hidden/" + shaderName + "/Fur");
            ltsfurc     = Shader.Find("Hidden/" + shaderName + "/FurCutout");
            ltsfurtwo   = Shader.Find("Hidden/" + shaderName + "/FurTwoPass");
            ltsfuro     = Shader.Find(shaderName + "/[Optional] FurOnly/Transparent");
            ltsfuroc    = Shader.Find(shaderName + "/[Optional] FurOnly/Cutout");
            ltsfurotwo  = Shader.Find(shaderName + "/[Optional] FurOnly/TwoPass");
            ltsgem      = Shader.Find("Hidden/" + shaderName + "/Gem");
            ltsfs       = Shader.Find(shaderName + "/[Optional] FakeShadow");

            ltsover     = Shader.Find(shaderName + "/[Optional] Overlay");
            ltsoover    = Shader.Find(shaderName + "/[Optional] OverlayOnePass");
            ltslover    = Shader.Find(shaderName + "/[Optional] LiteOverlay");
            ltsloover   = Shader.Find(shaderName + "/[Optional] LiteOverlayOnePass");

            ltsm        = Shader.Find(shaderName + "/lilToonMulti");
            ltsmo       = Shader.Find("Hidden/" + shaderName + "/MultiOutline");
            ltsmref     = Shader.Find("Hidden/" + shaderName + "/MultiRefraction");
            ltsmfur     = Shader.Find("Hidden/" + shaderName + "/MultiFur");
            ltsmgem     = Shader.Find("Hidden/" + shaderName + "/MultiGem");
        }

        // You can create a menu like this
        /*
        [MenuItem("Assets/TemplateFull/Convert material to custom shader", false, 1100)]
        private static void ConvertMaterialToCustomShaderMenu()
        {
            if(Selection.objects.Length == 0) return;
            TemplateFullInspector inspector = new TemplateFullInspector();
            for(int i = 0; i < Selection.objects.Length; i++)
            {
                if(Selection.objects[i] is Material)
                {
                    inspector.ConvertMaterialToCustomShader((Material)Selection.objects[i]);
                }
            }
        }
        */
    }
}
#endif