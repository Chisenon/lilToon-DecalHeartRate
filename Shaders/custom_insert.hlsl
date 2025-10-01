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

float3 sampleSpriteWithSpacing(float val, float2 uv, float displayLength, float alignMode, float characterOffset, float digitSpacing)
{
    if (any(uv < 0.0) || any(uv >= 1.0))
        return kZeroColor;

    val = abs(val);
    float numActualDigits = max(1.0, (val < 1.0) ? 1.0 : floor(log10(val)) + 1.0);
    
    float effectiveDigits = (alignMode == 1.0 || alignMode == 2.0) ? numActualDigits : displayLength;
    float digitWidth = 1.0 / displayLength;
    
    float gapReduction = 1.0 - digitSpacing;
    float newDigitSpacing = digitWidth * digitSpacing;
    float totalWidth = effectiveDigits * digitWidth - (effectiveDigits - 1) * digitWidth * gapReduction;
    float startOffset = (1.0 - totalWidth) * 0.5;
    
    float3 finalColor = kZeroColor;
    float totalAlpha = 0.0;
    
    [unroll(6)]
    for (int i = 0; i < 6; i++)
    {
        if (float(i) >= displayLength)
            continue;
            
        float digitIndex = 0.0;
        bool isValidDigit = false;
        float currentDigitSlot = float(i);
        
        if (alignMode == 0.0)
        {
            digitIndex = float(i);
            isValidDigit = true;
        }
        else if (alignMode == 1.0)
        {
            float emptySlotsOnLeft = max(0.0, displayLength - numActualDigits);
            if (float(i) >= emptySlotsOnLeft)
            {
                digitIndex = float(i) - emptySlotsOnLeft;
                isValidDigit = true;
            }
        }
        else
        {
            if (float(i) < numActualDigits)
            {
                digitIndex = float(i);
                isValidDigit = true;
            }
        }
        
        if (isValidDigit)
        {
            float newDigitStart = startOffset + digitIndex * newDigitSpacing;
            float newDigitEnd = newDigitStart + digitWidth;
            
            if (uv.x >= newDigitStart && uv.x < newDigitEnd)
            {
                float localUvX = (uv.x - newDigitStart) / digitWidth;
                
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

                if (renderThisDigit)
                {
                    float2 spriteUvData = calculateSpriteUV(localUvX, digitToRender, characterOffset);
                    
                    if (spriteUvData.x >= 0.0 && digitToRender < kColumns)
                    {
                        float2 spriteUv = float2(spriteUvData.x, uv.y);
                        float4 texSample = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
                        
                        if (texSample.a >= kAlphaThreshold)
                        {
                            float alpha = texSample.a;
                            float3 digitColor = float3(1.0, 1.0, 1.0);
                            finalColor = lerp(finalColor, digitColor, alpha * (1.0 - totalAlpha));
                            totalAlpha = saturate(totalAlpha + alpha);
                            
                            if (totalAlpha >= 0.99)
                                break;
                        }
                    }
                }
            }
        }
    }
    
    return finalColor;
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
    
    float2 offset = float2(_TexPositionXVector.x, _TexPositionYVector.x);    float2 scale = max(float2(_TexScaleXVector.x, _TexScaleYVector.x), float2(0.001, 0.001));
    float2 numUv = invAffineTransform(fd.uvMain, offset, -_NumTexRotation, scale);
    
    float uvMask = lilIsIn0to1(numUv);
    if (uvMask <= 0.0) return;
    
    float3 numberColor = sampleSpriteWithSpacing(roundedHeartRate, numUv, _NumTexDisplaylength, float(_NumTexAlignment), _NumTexCharacterOffset, _NumTexDigitSpacing);
    
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