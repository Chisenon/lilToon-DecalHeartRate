static const float kColumns = 10.0;
static const float kInvColumns = 0.1;
static const float kMarginRatio = 0.05;
static const float kInsetRatio = 0.15;
static const float kTau = 6.28318530718;
static const float kAlphaThreshold = 0.5;
static const float kEmissionScale = 0.01;
static const float2 kUvCenter = float2(0.5, 0.5);
static const float3 kZeroColor = float3(0.0, 0.0, 0.0);

// 通常の四捨五入関数（0.5は常に切り上げ）
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

float3 sampleSprite(float val, float2 uv, float displayLength, float alignMode, float characterOffset)
{
    if (any(uv < 0.0) || any(uv >= 1.0))
        return kZeroColor;

    val = abs(val);
    float numActualDigits = max(1.0, (val < 1.0) ? 1.0 : floor(log10(val)) + 1.0);
    float currentDigitSlot = floor(uv.x * displayLength);

    if (currentDigitSlot < 0.0 || currentDigitSlot >= displayLength)
        return kZeroColor;

    float digitToRender;
    bool renderThisDigit = false;

    if (alignMode == 0.0)
    {
        float power = pow(10.0, displayLength - 1.0 - currentDigitSlot);
        digitToRender = calcDigit(val, power);
        renderThisDigit = true;
    }
    else if (alignMode == 1.0)
    {
        float emptySlotsOnLeft = max(0.0, displayLength - numActualDigits);
        if (currentDigitSlot >= emptySlotsOnLeft)
        {
            float effectiveDigitIndex = currentDigitSlot - emptySlotsOnLeft;
            float power = pow(10.0, numActualDigits - 1.0 - effectiveDigitIndex);
            digitToRender = calcDigit(val, power);
            renderThisDigit = true;
        }
    }
    else
    {
        if (currentDigitSlot < numActualDigits)
        {
            float power = pow(10.0, numActualDigits - 1.0 - currentDigitSlot);
            digitToRender = calcDigit(val, power);
            renderThisDigit = true;
        }
    }

    if (!renderThisDigit)
        return kZeroColor;    float localUvX = frac(uv.x * displayLength);
    float2 spriteUvData = calculateSpriteUV(localUvX, digitToRender, characterOffset);
    
    if (spriteUvData.x < 0.0)
        return kZeroColor;
    
    float2 spriteUv = float2(spriteUvData.x, uv.y);
    
    if (digitToRender >= kColumns)
        return kZeroColor;

    float4 texSample = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
    return (texSample.a < kAlphaThreshold) ? kZeroColor : texSample.rgb;
}

float3 sampleSpriteSigned(float val, float2 uv, float displayLength, float align, float characterOffset)
{
    if (any(uv < 0.0) || any(uv >= 1.0))
        return kZeroColor;

    float originalDisplayLength = displayLength;
    displayLength += 1.0;
    float singleCharDisplayWidth = 1.0 / displayLength;

    if (uv.x >= singleCharDisplayWidth) 
    { 
        float2 numberPartUv = float2(saturate((uv.x - singleCharDisplayWidth) / (1.0 - singleCharDisplayWidth)), uv.y);
        return sampleSprite(abs(val), numberPartUv, originalDisplayLength, align, characterOffset);
    } 
    else if (val < 0.0) 
    { 
        float localUvX = uv.x / singleCharDisplayWidth;
        float2 spriteUvData = calculateSpriteUV(localUvX, 10.0, characterOffset);
        
        if (spriteUvData.x < 0.0)
            return kZeroColor;
        
        float2 spriteUv = float2(spriteUvData.x, uv.y);
        float4 tex = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
        
        return (tex.a < kAlphaThreshold) ? kZeroColor : tex.rgb;
    } 
    
    return kZeroColor;
}

float calculateHeartRateEmission(float heartRate, float minIntensity, float maxIntensity)
{
    if (heartRate <= 0.0) 
        return minIntensity * kEmissionScale;
    
    float phase = frac(_Time.y * heartRate / 60.0);
    float pulse = (phase < 0.1) ? (phase * 10.0) : exp(-(phase - 0.1) * 4.167);
    
    return lerp(minIntensity, maxIntensity, saturate(pulse)) * kEmissionScale;
}

float calculateHeartRateScale(float heartRate)
{
    if (heartRate <= 0.0) 
        return 1.0;
    
    float phase = frac(_Time.y * heartRate / 60.0);
    
    static const float kDampingFactor = 5.0;
    static const float kOscillationFreq = 4.0;
    static const float kExpandThreshold = 0.05;
    static const float kAmplitudeThreshold = 0.1;
    
    if (phase < kExpandThreshold)
    {
        float expandPhase = phase / kExpandThreshold;
        return 1.0 + _HeartRateScaleIntensity * (1.0 - exp(-expandPhase * 5.0));
    }
    else
    {
        float oscillationPhase = (phase - kExpandThreshold) / (1.0 - kExpandThreshold);
        float dampedAmplitude = exp(-kDampingFactor * oscillationPhase);
        
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
        scale *= calculateHeartRateScale(roundedHeartRate);
    
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
            emissionStrength = calculateHeartRateEmission(roundedHeartRate, _HeartRateEmissionMinTexture, _HeartRateEmissionMaxTexture) * 100.0;
        }
        else
        {
            emissionStrength = _DecalTextureEmissionStrength;
        }
        
        if (emissionStrength > 0.0)
            fd.emissionColor += decalColor.rgb * (emissionStrength * kEmissionScale) * decalMask;
    }
}

void lilGetDecalNumber(inout lilFragData fd LIL_SAMP_IN_FUNC(samp))
{
    if (!_ActiveDecalNumber) return;
    
    float roundedHeartRate = roundHalfUp(_FloatHeartRateC);
    
    float2 offset = float2(_TexPositionXVector.x, _TexPositionYVector.x);    float2 scale = max(float2(_TexScaleXVector.x, _TexScaleYVector.x), float2(0.001, 0.001));
    float2 numUv = invAffineTransform(fd.uvMain, offset, -_NumTexRotation, scale);
    
    float uvMask = lilIsIn0to1(numUv);
    if (uvMask <= 0.0) return;
    
    float3 numberColor = sampleSprite(roundedHeartRate, numUv, _NumTexDisplaylength, float(_NumTexAlignment), _NumTexCharacterOffset);
    
    float numberMask = (dot(numberColor, numberColor) > 0.000001) ? uvMask : 0.0;
    
    if (numberMask > 0.001)
    {
        float3 finalNumberColor = numberColor * _SpriteNumberTextureColor.rgb;
        
        fd.col.rgb = lerp(fd.col.rgb, lilBlendColor(fd.col.rgb, finalNumberColor, numberMask, _NumberTextureBlendMode), numberMask);        
        float emissionStrength;
        if (_UseHeartRateEmission)
        {
            emissionStrength = calculateHeartRateEmission(roundedHeartRate, _HeartRateEmissionMin, _HeartRateEmissionMax) * 100.0;
        }
        else
        {
            emissionStrength = _DecalNumberEmissionStrength;
        }
        
        if (emissionStrength > 0.0)
            fd.emissionColor += finalNumberColor * (emissionStrength * kEmissionScale) * numberMask;
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