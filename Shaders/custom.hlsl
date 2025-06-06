//----------------------------------------------------------------------------------------------------------------------
// Macro

// URP & HDRP compatibility
#define BEFORE_INCLUDE_COMMON \
    #if !defined(LIL_PASS_FORWARD_NORMAL_INCLUDED) && !defined(LIL_PASS_FORWARD_NORMAL_INCLUDED_INCLUDED) \
        #define sampler_linear_repeat sampler_LinearRepeat \
        #define sampler_linear_clamp sampler_LinearClamp \
        #define TEXTURE2D_SAMPLER2D(tex,samp) TEXTURE2D(tex), SAMPLER(samp) \
        #define SAMPLE_TEXTURE2D(tex,samp,uv) SAMPLE_TEXTURE2D(tex, samp, uv) \
    #endif

// Custom variables
#define LIL_CUSTOM_PROPERTIES \
    bool _ActiveDecalNumber; \
    bool _ActiveDecalTexture; \
    float4 _SpriteNumberTextureColor; \
    float4 _DecalTextureColor; \
    float4 _TexPositionXVector; \
    float4 _TexPositionYVector; \
    float4 _TexScaleXVector; \
    float4 _TexScaleYVector; \
    float _NumTexRotation; \
    float _NumTexDisplaylength; \
    int _NumTexAlignment; \
    float _NumTexCharacterOffset; \
    float4 _DecalPositionXVector; \
    float4 _DecalPositionYVector; \
    float4 _DecalScaleXVector; \
    float4 _DecalScaleYVector; \
    float _DecalRotation; \
    int _IntHeartRate;

// Custom textures
#define LIL_CUSTOM_TEXTURES \
    TEXTURE2D(_SpriteNumberTexture); \
    SAMPLER(sampler_SpriteNumberTexture); \
    TEXTURE2D(_DecalTexture); \
    SAMPLER(sampler_DecalTexture);

// Add vertex shader input
//#define LIL_REQUIRE_APP_POSITION
//#define LIL_REQUIRE_APP_TEXCOORD0

// Add vertex shader output
//#define LIL_V2F_FORCE_TEXCOORD0
//#define LIL_V2F_FORCE_TEXCOORD1

// Add vertex shader output (for custom shader)
//#define LIL_V2F_CUSTOM

// Inserting a process into the vertex shader
//#define LIL_CUSTOM_VERTEX_OS
//#define LIL_CUSTOM_VERTEX_WS

// Inserting a process into pixel shader
//#define BEFORE_xx

#define BEFORE_BLEND_EMISSION \
    UNITY_BRANCH \
    if(_ActiveDecalTexture > 0.5) { \
        float2 offset = float2(_DecalPositionXVector.x, _DecalPositionYVector.x); \
        float2 scale = max(float2(_DecalScaleXVector.x, _DecalScaleYVector.x), float2(0.001, 0.001)); \
        float angle = -_DecalRotation ; \
        float2 uv2 = invAffineTransform(fd.uvMain, offset, angle, scale); \
        if (all(saturate(uv2) == uv2)) { \
            float4 decalColor = LIL_SAMPLE_2D(_DecalTexture, sampler_DecalTexture, uv2) * _DecalTextureColor; \
            fd.col.rgb = lerp(fd.col.rgb, decalColor.rgb, decalColor.a * _DecalTextureColor.a); \
        } \
    } \
    UNITY_BRANCH \
    if(_ActiveDecalNumber > 0.5) { \
        float2 offset = float2(_TexPositionXVector.x, _TexPositionYVector.x); \
        float2 scale = max(float2(_TexScaleXVector.x, _TexScaleYVector.x), float2(0.001, 0.001)); \
        float angle = -_NumTexRotation ; \
        float2 numUv = invAffineTransform(fd.uvMain, offset, angle, scale); \
        if (all(saturate(numUv) == numUv)) { \
            float heartRateValue = round(float(_IntHeartRate)); \
            float3 numberColor = sampleSprite(heartRateValue, numUv, _NumTexDisplaylength, float(_NumTexAlignment), _NumTexCharacterOffset) * _SpriteNumberTextureColor.rgb; \
            float numberAlpha = length(numberColor) > 0.01 ? _SpriteNumberTextureColor.a : 0.0; \
            fd.col.rgb = lerp(fd.col.rgb, numberColor, numberAlpha); \
        } \
    }