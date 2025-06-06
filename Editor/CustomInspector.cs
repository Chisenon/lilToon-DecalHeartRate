#if UNITY_EDITOR
using UnityEditor;
using UnityEngine;

namespace lilToon
{
    public class DHBInspector : lilToonInspector
    {
        MaterialProperty _IntHeartRate;
        MaterialProperty _ActiveDecalNumber;
        MaterialProperty _ActiveDecalTexture;
        MaterialProperty _SpriteNumberTexture;
        MaterialProperty _SpriteNumberTextureColor;
        MaterialProperty _DecalTexture;
        MaterialProperty _DecalTextureColor;
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
        MaterialProperty _SyncDecalNumberTextureScale;
        MaterialProperty _SyncDecalTextureScale;

        private static bool isShowCustomProperties;
        private const string shaderName = "ChiseNote/DecalHeartRate";

        protected override void LoadCustomProperties(MaterialProperty[] props, Material material)
        {
            isCustomShader = true;
            ReplaceToCustomShaders();
            isShowRenderMode = !material.shader.name.Contains("Optional");

            _IntHeartRate = FindProperty("_IntHeartRate", props);
            _ActiveDecalNumber = FindProperty("_ActiveDecalNumber", props);
            _ActiveDecalTexture = FindProperty("_ActiveDecalTexture", props);
            _SpriteNumberTexture = FindProperty("_SpriteNumberTexture", props);
            _SpriteNumberTextureColor = FindProperty("_SpriteNumberTextureColor", props);
            _DecalTexture = FindProperty("_DecalTexture", props);
            _DecalTextureColor = FindProperty("_DecalTextureColor", props);
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
            _SyncDecalNumberTextureScale = FindProperty("_SyncDecalNumberTextureScale", props);
            _SyncDecalTextureScale = FindProperty("_SyncDecalTextureScale", props);
        }

        protected override void DrawCustomProperties(Material material)
        {
            // GUIStyles Name   Description
            // ---------------- ------------------------------------
            // boxOuter         outer box
            // boxInnerHalf     inner box
            // boxInner         inner box without label
            // customBox        box (similar to unity default box)
            // customToggleFont label for box

            isShowCustomProperties = Foldout(GetLoc("Decal Heart Rate"), GetLoc("Decal Menu"), isShowCustomProperties);
            if(isShowCustomProperties)
            {
                // OSC Settings Section
                EditorGUILayout.BeginVertical(boxOuter);
                EditorGUILayout.LabelField(GetLoc("OSC setting"), customToggleFont);
                EditorGUILayout.BeginVertical(boxInnerHalf);
                EditorGUI.indentLevel++;
                m_MaterialEditor.ShaderProperty(_IntHeartRate, GetLoc("HeartRate (OSC)"));
                EditorGUI.indentLevel--;
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();

                // Decal Number Section
                EditorGUILayout.BeginVertical(boxOuter);
                m_MaterialEditor.ShaderProperty(_ActiveDecalNumber, GetLoc("Decal Number"));
                EditorGUILayout.BeginVertical(boxInnerHalf);

                if(_ActiveDecalNumber.floatValue == 1)
                {                   
                    // Texture Settings
                    EditorGUILayout.LabelField(GetLoc("Texture Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent(GetLoc("Number Texture")), _SpriteNumberTexture, _SpriteNumberTextureColor);
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Position Settings
                    EditorGUILayout.LabelField(GetLoc("Position Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    EditorGUI.BeginChangeCheck();
                    Vector4 positionXVector = _TexPositionXVector.vectorValue;
                    Vector4 positionYVector = _TexPositionYVector.vectorValue;

                    positionXVector.x = EditorGUILayout.Slider(GetLoc("Position X"), positionXVector.x, -1.0f, 1.0f);
                    positionYVector.x = EditorGUILayout.Slider(GetLoc("Position Y"), positionYVector.x, -1.0f, 1.0f);

                    if(EditorGUI.EndChangeCheck())
                    {
                        _TexPositionXVector.vectorValue = positionXVector;
                        _TexPositionYVector.vectorValue = positionYVector;
                    }
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Scale Settings
                    EditorGUILayout.LabelField(GetLoc("Scale Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    
                    // Sync toggle for number texture
                    m_MaterialEditor.ShaderProperty(_SyncDecalNumberTextureScale, GetLoc("Sync Scale"));
                    
                    EditorGUI.BeginChangeCheck();
                    Vector4 scaleXVector = _TexScaleXVector.vectorValue;
                    Vector4 scaleYVector = _TexScaleYVector.vectorValue;

                    if(_SyncDecalNumberTextureScale.floatValue == 1)
                    {
                        // Synchronized scale control
                        float syncedScale = EditorGUILayout.Slider(GetLoc("Scale"), scaleXVector.x, 0.0f, 1.0f);
                        scaleXVector.x = syncedScale;
                        scaleYVector.x = syncedScale;
                    }
                    else
                    {
                        // Individual scale controls
                        scaleXVector.x = EditorGUILayout.Slider(GetLoc("Scale X"), scaleXVector.x, 0.0f, 1.0f);
                        scaleYVector.x = EditorGUILayout.Slider(GetLoc("Scale Y"), scaleYVector.x, 0.0f, 1.0f);
                    }

                    if(EditorGUI.EndChangeCheck())
                    {
                        _TexScaleXVector.vectorValue = scaleXVector;
                        _TexScaleYVector.vectorValue = scaleYVector;
                    }
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Rotation & Display Settings
                    EditorGUILayout.LabelField(GetLoc("Additional Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.ShaderProperty(_NumTexRotation, GetLoc("Rotation"));
                    m_MaterialEditor.ShaderProperty(_NumTexDisplaylength, GetLoc("Display Length"));
                    m_MaterialEditor.ShaderProperty(_NumTexAlignment, GetLoc("Alignment"));
                    m_MaterialEditor.ShaderProperty(_NumTexCharacterOffset, GetLoc("Character Offset"));
                    EditorGUI.indentLevel--;
                }
                
                EditorGUILayout.EndVertical();
                EditorGUILayout.EndVertical();

                // Decal Texture Section
                EditorGUILayout.BeginVertical(boxOuter);
                m_MaterialEditor.ShaderProperty(_ActiveDecalTexture, GetLoc("Decal Texture"));
                EditorGUILayout.BeginVertical(boxInnerHalf);
                if(_ActiveDecalTexture.floatValue == 1)
                {
                    EditorGUILayout.Space();
                    
                    // Texture Settings
                    EditorGUILayout.LabelField(GetLoc("Texture Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.TexturePropertySingleLine(new GUIContent(GetLoc("Decal Texture")), _DecalTexture, _DecalTextureColor);
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Position Settings
                    EditorGUILayout.LabelField(GetLoc("Position Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    EditorGUI.BeginChangeCheck();
                    Vector4 decalPositionXVector = _DecalPositionXVector.vectorValue;
                    Vector4 decalPositionYVector = _DecalPositionYVector.vectorValue;

                    decalPositionXVector.x = EditorGUILayout.Slider(GetLoc("Position X"), decalPositionXVector.x, -1.0f, 1.0f);
                    decalPositionYVector.x = EditorGUILayout.Slider(GetLoc("Position Y"), decalPositionYVector.x, -1.0f, 1.0f);

                    if(EditorGUI.EndChangeCheck())
                    {
                        _DecalPositionXVector.vectorValue = decalPositionXVector;
                        _DecalPositionYVector.vectorValue = decalPositionYVector;
                    }
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Scale Settings
                    EditorGUILayout.LabelField(GetLoc("Scale Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    
                    // Sync toggle for decal texture
                    m_MaterialEditor.ShaderProperty(_SyncDecalTextureScale, GetLoc("Sync Scale"));
                    
                    EditorGUI.BeginChangeCheck();
                    Vector4 decalScaleXVector = _DecalScaleXVector.vectorValue;
                    Vector4 decalScaleYVector = _DecalScaleYVector.vectorValue;

                    if(_SyncDecalTextureScale.floatValue == 1)
                    {
                        // Synchronized scale control
                        float syncedScale = EditorGUILayout.Slider(GetLoc("Scale"), decalScaleXVector.x, 0.0f, 1.0f);
                        decalScaleXVector.x = syncedScale;
                        decalScaleYVector.x = syncedScale;
                    }
                    else
                    {
                        // Individual scale controls
                        decalScaleXVector.x = EditorGUILayout.Slider(GetLoc("Scale X"), decalScaleXVector.x, 0.0f, 1.0f);
                        decalScaleYVector.x = EditorGUILayout.Slider(GetLoc("Scale Y"), decalScaleYVector.x, 0.0f, 1.0f);
                    }

                    if(EditorGUI.EndChangeCheck())
                    {
                        _DecalScaleXVector.vectorValue = decalScaleXVector;
                        _DecalScaleYVector.vectorValue = decalScaleYVector;
                    }
                    EditorGUI.indentLevel--;

                    DrawLine();

                    // Rotation Settings
                    EditorGUILayout.LabelField(GetLoc("Rotation Settings"), EditorStyles.boldLabel);
                    EditorGUI.indentLevel++;
                    m_MaterialEditor.ShaderProperty(_DecalRotation, GetLoc("Rotation Angle"));
                    EditorGUI.indentLevel--;
                }

                EditorGUILayout.EndVertical();
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