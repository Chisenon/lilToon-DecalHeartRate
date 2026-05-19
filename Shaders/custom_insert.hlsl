static const float kColumns = 10.0;
static const float kInvColumns = 0.1;
static const float kMarginRatio = 0.05;
static const float kInsetRatio = 0.15;
static const float kTau = 6.28318530718;
static const float kAlphaThreshold = 0.5;
static const float kEmissionScale = 0.01;
static const float2 kUvCenter = float2(0.5, 0.5);
static const float3 kZeroColor = float3(0.0, 0.0, 0.0);

float roundHalfUp(float value)
{
    return floor(value + 0.5);
}

float2 rotate2D(float2 v, float angle)
{
    float s, c;
    sincos(angle, s, c);

    return float2(
        v.x * c - v.y * s,
        v.x * s + v.y * c);
}

float2 invAffineTransform(float2 uv, float2 translate, float rotAngle, float2 scale)
{
    scale = max(scale, float2(0.001, 0.001));
    return rotate2D(uv - kUvCenter - translate, -rotAngle) / scale + kUvCenter;
}

float fmodglsl(float x, float y)
{
    return x - y * floor(x / y);
}

float calcDigit(float val, float digitNum)
{
    return floor(fmodglsl(abs(val), digitNum * 10.0) / digitNum);
}

float countDigits(float val)
{
    if (val < 10.0) return 1.0;
    if (val < 100.0) return 2.0;
    if (val < 1000.0) return 3.0;
    if (val < 10000.0) return 4.0;
    if (val < 100000.0) return 5.0;
    if (val < 1000000.0) return 6.0;
    return 7.0;
}

float fastExp(float x)
{
    float x2 = x * x;
    float x3 = x2 * x;
    float numerator = 120.0 + x * (60.0 + x * (12.0 + x));
    float denominator = 120.0 + x * (-60.0 + x * (12.0 - x));
    return numerator / denominator;
}

float2 calculateSpriteUV(float localUvX, float spriteColumnIndex, float characterOffset)
{
    if (localUvX < kMarginRatio || localUvX > (1.0 - kMarginRatio))
        return float2(-1.0, 0.0);
    
    localUvX = saturate((localUvX - kMarginRatio) / (1.0 - 2.0 * kMarginRatio) + characterOffset);
    
    float charStartU = spriteColumnIndex * kInvColumns;
    float actualInset = kInvColumns * kInsetRatio;
    float sampleStartU = charStartU + actualInset;
    float sampleEndU = charStartU + kInvColumns - actualInset;
    
    return float2(lerp(sampleStartU, sampleEndU, localUvX), sampleStartU);
}

int calculateDigitSlot(float uvX, float startOffset, float newDigitSpacing, float digitWidth, float displayLength)
{
    if (newDigitSpacing <= 0.0)
        return -1;

    float slotFloat = floor((uvX - startOffset) / newDigitSpacing);
    int slot = (int)slotFloat;

    if (slot < 0 || slot > 5 || float(slot) >= displayLength)
        return -1;

    float digitStart = startOffset + float(slot) * newDigitSpacing;
    float digitEnd = digitStart + digitWidth;

    if (uvX < digitStart || uvX >= digitEnd)
        return -1;

    return slot;
}

// ZERO FILL mode (alignMode = 0.0)
float3 sampleSpriteCore_align0(float val, float2 uv, float displayLength, float characterOffset, float digitSpacing)
{
    float digitWidth = 1.0 / displayLength;
    float newDigitSpacing = digitWidth * digitSpacing;
    float startOffset = 0.0;  // Left-aligned fill

    int slot = calculateDigitSlot(uv.x, startOffset, newDigitSpacing, digitWidth, displayLength);
    if (slot < 0)
        return kZeroColor;

    float localUvX = (uv.x - (startOffset + float(slot) * newDigitSpacing)) / digitWidth;
    float powerBase = pow(10.0, displayLength - 1.0);
    static const float powerFactors[6] = {1.0, 0.1, 0.01, 0.001, 0.0001, 0.00001};

    float power = powerBase * powerFactors[slot];
    float digitToRender = calcDigit(val, power);
    float2 spriteUvData = calculateSpriteUV(localUvX, digitToRender, characterOffset);

    if (spriteUvData.x < 0.0 || digitToRender >= kColumns)
        return kZeroColor;

    float2 spriteUv = float2(spriteUvData.x, uv.y);
    float4 texSample = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
    return (texSample.a >= kAlphaThreshold) ? float3(1.0, 1.0, 1.0) : kZeroColor;
}

// SHIFT RIGHT mode (alignMode = 1.0) - Right-aligned
float3 sampleSpriteCore_align1(float val, float2 uv, float displayLength, float characterOffset, float digitSpacing, float numActualDigits)
{
    if (numActualDigits > displayLength)
    {
        val = floor(fmodglsl(val, pow(10.0, displayLength)));
        numActualDigits = displayLength;
    }

    float digitWidth = 1.0 / displayLength;
    float gapReduction = 1.0 - digitSpacing;
    float newDigitSpacing = digitWidth * digitSpacing;
    float totalWidth = numActualDigits * digitWidth - (numActualDigits - 1.0) * digitWidth * gapReduction;
    float startOffset = 1.0 - totalWidth;  // Right-aligned (move to right edge)

    int slot = calculateDigitSlot(uv.x, startOffset, newDigitSpacing, digitWidth, numActualDigits);
    if (slot < 0)
        return kZeroColor;

    float localUvX = (uv.x - (startOffset + float(slot) * newDigitSpacing)) / digitWidth;
    float powerBase = pow(10.0, numActualDigits - 1.0);
    static const float powerFactors[6] = {1.0, 0.1, 0.01, 0.001, 0.0001, 0.00001};
    if (slot > 5)
        return kZeroColor;

    float power = powerBase * powerFactors[slot];
    float digitToRender = calcDigit(val, power);
    float2 spriteUvData = calculateSpriteUV(localUvX, digitToRender, characterOffset);

    if (spriteUvData.x < 0.0 || digitToRender >= kColumns)
        return kZeroColor;

    float2 spriteUv = float2(spriteUvData.x, uv.y);
    float4 texSample = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
    return (texSample.a >= kAlphaThreshold) ? float3(1.0, 1.0, 1.0) : kZeroColor;
}

// SHIFT LEFT mode (alignMode = 2.0) - Left-aligned
float3 sampleSpriteCore_align2(float val, float2 uv, float displayLength, float characterOffset, float digitSpacing, float numActualDigits)
{
    float digitWidth = 1.0 / displayLength;
    float newDigitSpacing = digitWidth * digitSpacing;
    float startOffset = 0.0;  // Left-aligned

    int slot = calculateDigitSlot(uv.x, startOffset, newDigitSpacing, digitWidth, displayLength);
    if (slot < 0 || float(slot) >= numActualDigits)
        return kZeroColor;

    float localUvX = (uv.x - (startOffset + float(slot) * newDigitSpacing)) / digitWidth;
    float powerBase = pow(10.0, numActualDigits - 1.0);
    static const float powerFactors[6] = {1.0, 0.1, 0.01, 0.001, 0.0001, 0.00001};
    float power = powerBase * powerFactors[slot];
    float digitToRender = calcDigit(val, power);
    float2 spriteUvData = calculateSpriteUV(localUvX, digitToRender, characterOffset);

    if (spriteUvData.x < 0.0 || digitToRender >= kColumns)
        return kZeroColor;

    float2 spriteUv = float2(spriteUvData.x, uv.y);
    float4 texSample = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
    return (texSample.a >= kAlphaThreshold) ? float3(1.0, 1.0, 1.0) : kZeroColor;
}

float3 sampleSpriteWithSpacing(float val, float2 uv, float displayLength, float alignMode, float characterOffset, float digitSpacing)
{
    if (any(uv < 0.0) || any(uv >= 1.0))
        return kZeroColor;

    val = abs(val);
    float numActualDigits = max(1.0, (val < 1.0) ? 1.0 : countDigits(val));
    
    if (alignMode < 1.0)
    {
        return sampleSpriteCore_align0(val, uv, displayLength, characterOffset, digitSpacing);
    }
    else if (alignMode < 2.0)
    {
        return sampleSpriteCore_align1(val, uv, displayLength, characterOffset, digitSpacing, numActualDigits);
    }
    else
    {
        return sampleSpriteCore_align2(val, uv, displayLength, characterOffset, digitSpacing, numActualDigits);
    }
}

float3 sampleSprite(float val, float2 uv, float displayLength, float alignMode, float characterOffset)
{
    return sampleSpriteWithSpacing(val, uv, displayLength, alignMode, characterOffset, 1.0);
}

float3 sampleSpriteSignedWithSpacing(float val, float2 uv, float displayLength, float align, float characterOffset, float digitSpacing)
{
    if (any(uv < 0.0) || any(uv >= 1.0))
        return kZeroColor;

    float originalDisplayLength = displayLength;
    displayLength += 1.0;
    float singleCharDisplayWidth = 1.0 / displayLength;

    if (uv.x >= singleCharDisplayWidth) 
    { 
        float2 numberPartUv = float2(saturate((uv.x - singleCharDisplayWidth) / (1.0 - singleCharDisplayWidth)), uv.y);
        return sampleSpriteWithSpacing(abs(val), numberPartUv, originalDisplayLength, align, characterOffset, digitSpacing);
    } 
    else if (val < 0.0) 
    { 
        float localUvX = uv.x / singleCharDisplayWidth;
        float2 spriteUvData = calculateSpriteUV(localUvX, 10.0, characterOffset);
        
        if (spriteUvData.x < 0.0)
            return kZeroColor;
        
        float2 spriteUv = float2(spriteUvData.x, uv.y);
        float4 tex = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
        
        return (tex.a < kAlphaThreshold) ? kZeroColor : float3(1.0, 1.0, 1.0);
    } 
    
    return kZeroColor;
}

float3 sampleSpriteSigned(float val, float2 uv, float displayLength, float align, float characterOffset)
{
    return sampleSpriteSignedWithSpacing(val, uv, displayLength, align, characterOffset, 1.0);
}

float calculateHeartRateEmission(float heartRate, float phase, float minIntensity, float maxIntensity)
{
    if (heartRate <= 0.0) 
        return minIntensity * kEmissionScale;
    
    float pulse = (phase < 0.1) ? (phase * 10.0) : fastExp(-(phase - 0.1) * 4.167);
    
    return lerp(minIntensity, maxIntensity, saturate(pulse)) * kEmissionScale;
}

float calculateHeartRateEmissionSmooth(float heartRate, float phase, float minIntensity, float maxIntensity)
{
    if (heartRate <= 0.0) 
        return minIntensity * kEmissionScale;
    
    float Smooth = sin(phase * kTau);
    float normalized = (Smooth + 1.0) * 0.5;
    
    return lerp(minIntensity, maxIntensity, normalized) * kEmissionScale;
}

float calculateHeartRateEmissionByPattern(float heartRate, float minIntensity, float maxIntensity, uint pattern)
{
    if (heartRate <= 0.0) 
        return minIntensity * kEmissionScale;
    
    float phase = frac(_Time.y * heartRate / 60.0); 

    if (pattern == 1)
    {
        return calculateHeartRateEmissionSmooth(heartRate, phase, minIntensity, maxIntensity);
    }
    else
    {
        return calculateHeartRateEmission(heartRate, phase, minIntensity, maxIntensity);
    }
}

float calculateHeartRateScale(float heartRate, float phase)
{
    if (heartRate <= 0.0) 
        return 1.0;
    
    static const float kDampingFactor = 5.0;
    static const float kOscillationFreq = 4.0;
    static const float kExpandThreshold = 0.05;
    static const float kAmplitudeThreshold = 0.1;
    
    if (phase < kExpandThreshold)
    {
        float expandPhase = phase / kExpandThreshold;
        return 1.0 + _HeartRateScaleIntensity * (1.0 - fastExp(-expandPhase * 5.0));
    }
    else
    {
        float oscillationPhase = (phase - kExpandThreshold) / (1.0 - kExpandThreshold);
        float dampedAmplitude = fastExp(-kDampingFactor * oscillationPhase);
        
        if (dampedAmplitude < kAmplitudeThreshold) 
            return 1.0;
        
        float oscillation = sin(kOscillationFreq * oscillationPhase * kTau);
        return max(1.0 + _HeartRateScaleIntensity * dampedAmplitude * (1.0 + 0.5 * oscillation), 0.5);
    }
}

void lilGetDecalTexture(inout lilFragData fd LIL_SAMP_IN_FUNC(samp))
{
    if (!_ActiveDecalTexture) return;
    
    float roundedHeartRate = roundHalfUp(_FloatHeartRateC);
    
    float2 offset = float2(_DecalPositionXVector.x, _DecalPositionYVector.x);    float2 scale = max(float2(_DecalScaleXVector.x, _DecalScaleYVector.x), float2(0.001, 0.001));
    
    if (_UseHeartRateScaleTexture && roundedHeartRate > 0)
    {
        float phase = frac(_Time.y * roundedHeartRate / 60.0);
        scale *= calculateHeartRateScale(roundedHeartRate, phase);
    }
    
    float2 uv2 = invAffineTransform(fd.uvMain, offset, -_DecalRotation, scale);
    
    float uvMask = lilIsIn0to1(uv2);
    if (uvMask <= 0.0) return;
      float4 decalColor = LIL_SAMPLE_2D(_DecalTexture, sampler_DecalTexture, uv2) * _DecalTextureColor;
    
    float decalMask = decalColor.a * uvMask;
    if (decalMask > 0.001)
    {
        fd.col.rgb = lerp(fd.col.rgb, lilBlendColor(fd.col.rgb, decalColor.rgb, decalMask, _DecalTextureBlendMode), decalMask);        
        float emissionStrength;
        if (_UseHeartRateEmissionTexture)
        {
            emissionStrength = calculateHeartRateEmissionByPattern(roundedHeartRate, _HeartRateEmissionMinTexture, _HeartRateEmissionMaxTexture, _DecalTextureEmissionPattern) * 100.0;
        }
        else
        {
            emissionStrength = _DecalTextureEmissionStrength;
        }
        
        if (emissionStrength > 0.0)
        {
            float4 maskSample = LIL_SAMPLE_2D(_DecalTextureEmissionMask, sampler_DecalTextureEmissionMask, uv2);
            float maskValue = maskSample.r; 
            float3 emissionCol = _DecalTextureEmissionColor.rgb;
            emissionCol = lerp(emissionCol, _DecalTextureColor.rgb, _DecalTextureMainColorPower);
            emissionCol *= maskSample.rgb;
            float finalMask = decalMask * maskValue;
            fd.emissionColor += emissionCol * (emissionStrength * kEmissionScale) * finalMask;
        }
    }
}

void lilGetDecalNumber(inout lilFragData fd LIL_SAMP_IN_FUNC(samp))
{
    if (!_ActiveDecalNumber) return;
    
    float roundedHeartRate = roundHalfUp(_FloatHeartRateC);
    
    if (_HideDecalNumberWhenZero == 1 && roundedHeartRate <= 0.0) return;
    
    float2 offset = float2(_TexPositionXVector.x, _TexPositionYVector.x);    float2 scale = max(float2(_TexScaleXVector.x, _TexScaleYVector.x), float2(0.001, 0.001));
    float2 numUv = invAffineTransform(fd.uvMain, offset, -_NumTexRotation, scale);
    
    float uvMask = lilIsIn0to1(numUv);
    if (uvMask <= 0.0) return;
    
    float3 numberColor = sampleSpriteWithSpacing(roundedHeartRate, numUv, _NumTexDisplaylength, float(_NumTexAlignment), _NumTexCharacterOffset, _NumTexDigitSpacing);
    
    float colorMagnitudeSq = numberColor.x*numberColor.x + numberColor.y*numberColor.y + numberColor.z*numberColor.z;
    float numberMask = (colorMagnitudeSq > 0.000001) ? uvMask : 0.0;
    
    if (numberMask > 0.001)
    {
        float3 finalNumberColor = numberColor * _SpriteNumberTextureColor.rgb;
        
        fd.col.rgb = lerp(fd.col.rgb, lilBlendColor(fd.col.rgb, finalNumberColor, numberMask, _NumberTextureBlendMode), numberMask);        
        float emissionStrength;
        if (_UseHeartRateEmission)
        {
            emissionStrength = calculateHeartRateEmissionByPattern(roundedHeartRate, _HeartRateEmissionMin, _HeartRateEmissionMax, _DecalNumberEmissionPattern) * 100.0;
        }
        else
        {
            emissionStrength = _DecalNumberEmissionStrength;
        }
        
        if (emissionStrength > 0.0)
        {
            float4 maskSample = LIL_SAMPLE_2D(_DecalNumberEmissionMask, sampler_DecalNumberEmissionMask, numUv);
            float maskValue = maskSample.r;
            float3 emissionCol = _DecalNumberEmissionColor.rgb;
            emissionCol = lerp(emissionCol, _SpriteNumberTextureColor.rgb, _DecalNumberMainColorPower);
            emissionCol *= maskSample.rgb;
            float finalMask = numberMask * maskValue;
            fd.emissionColor += emissionCol * (emissionStrength * kEmissionScale) * finalMask;
        }
    }
}

#if !defined(BEFORE_MAIN3RD)
    #define BEFORE_MAIN3RD \
        lilGetDecalTexture(fd LIL_SAMP_IN(sampler_MainTex)); \
        lilGetDecalNumber(fd LIL_SAMP_IN(sampler_MainTex));
#endif

#if !defined(OVERRIDE_ALPHAMASK)
    #define OVERRIDE_ALPHAMASK \
        lilGetDecalTexture(fd LIL_SAMP_IN(sampler_MainTex)); \
        lilGetDecalNumber(fd LIL_SAMP_IN(sampler_MainTex));
#endif
