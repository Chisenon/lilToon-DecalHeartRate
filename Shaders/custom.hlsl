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
    uint _DecalTextureBlendMode; \
    uint _NumberTextureBlendMode; \
    float4 _TexPositionXVector; \
    float4 _TexPositionYVector; \
    float4 _TexScaleXVector; \
    float4 _TexScaleYVector; \
    float _NumTexRotation; \
    float _NumTexDisplaylength; \
    int _NumTexAlignment; \
    float _NumTexCharacterOffset; \
    float _NumTexDigitSpacing; \
    float4 _DecalPositionXVector; \
    float4 _DecalPositionYVector; \
    float4 _DecalScaleXVector; \
    float4 _DecalScaleYVector; \
    float _DecalRotation; \
    float _FloatHeartRateC; \
    float _DecalNumberEmissionStrength; \
    float _DecalTextureEmissionStrength; \
    float4 _DecalNumberEmissionColor; \
    float _DecalNumberMainColorPower; \
    float4 _DecalTextureEmissionColor; \
    float _DecalTextureMainColorPower; \
    bool _UseHeartRateEmission; \
    float _HeartRateEmissionMin; \
    float _HeartRateEmissionMax; \
    bool _UseHeartRateEmissionTexture; \
    float _HeartRateEmissionMinTexture; \
    float _HeartRateEmissionMaxTexture; \
    bool _UseHeartRateScaleTexture; \
    float _HeartRateScaleIntensity;

// Custom textures
#define LIL_CUSTOM_TEXTURES \
    TEXTURE2D(_SpriteNumberTexture); \
    SAMPLER(sampler_SpriteNumberTexture); \
    TEXTURE2D(_DecalTexture); \
    SAMPLER(sampler_DecalTexture); \
    TEXTURE2D(_DecalNumberEmissionMask); \
    SAMPLER(sampler_DecalNumberEmissionMask); \
    TEXTURE2D(_DecalTextureEmissionMask); \
    SAMPLER(sampler_DecalTextureEmissionMask);

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

// Use custom_insert.hlsl for decal processing instead of BEFORE_OUTPUT
// The decal functions are now handled in the OVERRIDE_ALPHAMASK section of custom_insert.hlsl