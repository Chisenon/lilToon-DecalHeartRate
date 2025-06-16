/*!
 * @brief アフィン変換関数 - テクスチャUVをオフセット、回転、スケーリングする
 * @param [in] uv      変換元のUV座標
 * @param [in] offset  オフセット値 (x, y)
 * @param [in] angle   回転角度（ラジアン）
 * @param [in] scale   スケール値 (x, y)
 * @return 変換後のUV座標
 */

// Applies 2D rotation to a vector
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
    static const float2 uvCenter = float2(0.5, 0.5);
    scale = max(scale, float2(0.001, 0.001));
    return rotate2D(uv - uvCenter - translate, -rotAngle) / scale + uvCenter;
}

static const float kColumns = 10.0;

/*!
 * @brief fmod() implementation in GLSL.
 * @param [in] x  First value.
 * @param [in] y  Second value.
 * @return mod value.
 */
float fmodglsl(float x, float y)
{
    return x - y * floor(x / y);
}

/*!
 * @brief Calculate a digit to show.
 * @param [in] val  Value.
 * @param [in] digitNum  Digit position (1, 10, 100, etc.).
 * @return Digit value (0-9).
 */
float calcDigit(float val, float digitNum)
{
    return floor(fmodglsl(abs(val), digitNum * 10.0) / digitNum);
}

/*!
 * @brief Sample from sprite texture with positive value and uv coordinate.
 * @param [in] val  Value to display (Assume this value is positive)
 * @param [in] uv  UV coordinate.
 * @param [in] displayLength  Number of display digits.
 * @param [in] alignMode  Enum value of alignment (0:ZERO_FILL, 1:SHIFT_RIGHT, 2:SHIFT_LEFT).
 * @param [in] characterOffset  Character horizontal offset for sprite sheet sampling.
 * @return Sampled RGB value.
 */
float3 sampleSprite(float val, float2 uv, float displayLength, float alignMode, float characterOffset)
{
    if (uv.x < 0.0 || uv.x >= 1.0 || uv.y < 0.0 || uv.y >= 1.0)
    {
        return float3(0.0, 0.0, 0.0);
    }

    val = abs(floor(val));

    float numActualDigits = (val < 1.0) ? 1.0 : floor(log10(val)) + 1.0;
    numActualDigits = max(1.0, numActualDigits);

    float currentDigitSlot = floor(uv.x * displayLength);

    if (currentDigitSlot < 0.0 || currentDigitSlot >= displayLength)
    {
        return float3(0.0, 0.0, 0.0);
    }

    float digitToRender = 0.0;
    bool renderThisDigit = false;

    if (alignMode == 0.0)
    {
        if (currentDigitSlot >= 0 && currentDigitSlot < displayLength) {
            float power = pow(10.0, displayLength - 1.0 - currentDigitSlot);
            digitToRender = calcDigit(val, power);
            renderThisDigit = true;
        } else {
            renderThisDigit = false;
        }
    }
    else if (alignMode == 1.0)
    {
        float emptySlotsOnLeft = max(0.0, displayLength - numActualDigits);
        if (currentDigitSlot >= emptySlotsOnLeft && currentDigitSlot < displayLength)
        {
            float effectiveDigitIndexInVal = currentDigitSlot - emptySlotsOnLeft;
            float power = pow(10.0, numActualDigits - 1.0 - effectiveDigitIndexInVal);
            digitToRender = calcDigit(val, power);
            renderThisDigit = true;
        }
        else
        {
            renderThisDigit = false;
        }
    }
    else
    {
        if (currentDigitSlot >= 0 && currentDigitSlot < numActualDigits && currentDigitSlot < displayLength)
        {
            float power = pow(10.0, numActualDigits - 1.0 - currentDigitSlot);
            digitToRender = calcDigit(val, power);
            renderThisDigit = true;
        }
        else
        {
            renderThisDigit = false;
        }
    }

    if (!renderThisDigit || currentDigitSlot < 0 || currentDigitSlot >= displayLength)
    {
        return float3(0.0, 0.0, 0.0);
    }

    float spriteColumnIndex = digitToRender;
    float localUvX = frac(uv.x * displayLength);
    
    float marginRatio = 0.05;
    if (localUvX < marginRatio || localUvX > (1.0 - marginRatio))
    {
        return float3(0.0, 0.0, 0.0);
    }
    
    localUvX = (localUvX - marginRatio) / (1.0 - 2.0 * marginRatio);
    localUvX = saturate(localUvX);
    
    localUvX += characterOffset;
    
    localUvX = saturate(localUvX);
    float charWidthInAtlas = 1.0 / kColumns;
    float charStartUInAtlas = spriteColumnIndex * charWidthInAtlas;
    
    float insetRatio = 0.15;
    float actualInset = charWidthInAtlas * insetRatio;

    float sampleStartU = charStartUInAtlas + actualInset;
    float sampleEndU = charStartUInAtlas + charWidthInAtlas - actualInset;
    
    float finalSpriteU = lerp(sampleStartU, sampleEndU, localUvX);

    finalSpriteU = clamp(finalSpriteU, sampleStartU, sampleEndU);
    float2 spriteUv = float2(finalSpriteU, saturate(uv.y));

    if (spriteUv.x < sampleStartU || spriteUv.x > sampleEndU || spriteUv.y < 0.0 || spriteUv.y > 1.0)
    {
        return float3(0.0, 0.0, 0.0);
    }

    if (spriteColumnIndex < 0.0 || spriteColumnIndex >= kColumns)
    {
        return float3(0.0, 0.0, 0.0);
    }

    float4 texSample = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
    
    float alphaFromTex = 2.0 - 2.0 * texSample.a;
    float finalPixelAlpha = saturate((1.0 - alphaFromTex) / fwidth(alphaFromTex));

    return texSample.rgb * finalPixelAlpha;
}

/*!
 * @brief Sample from sprite texture with signed value and uv coordinate.
 * @param [in] val  Value to display (can be negative).
 * @param [in] uv  UV coordinate.
 * @param [in] displayLength  Number of display digits.
 * @param [in] align  Enum value of alignment.
 * @param [in] characterOffset  Character horizontal offset for sprite sheet sampling.
 * @return Sampled RGB value.
 */
float3 sampleSpriteSigned(float val, float2 uv, float displayLength, float align, float characterOffset)
{
    if (uv.x < 0.0 || uv.x >= 1.0 || uv.y < 0.0 || uv.y >= 1.0)
    {
        return float3(0.0, 0.0, 0.0);
    }

    float originalDisplayLength = displayLength;
    displayLength += 1.0;
    
    float singleCharDisplayWidth = 1.0 / displayLength;

    if (uv.x >= singleCharDisplayWidth) { 
        float2 numberPartUv = uv;
        numberPartUv.x = (uv.x - singleCharDisplayWidth) / (1.0 - singleCharDisplayWidth);
        numberPartUv.x = saturate(numberPartUv.x); 

        return sampleSprite(abs(val), numberPartUv, originalDisplayLength, align, characterOffset);
    } else if (val < 0.0) { 
        float spriteColumnIndex = 10.0;

        float localUvX = uv.x / singleCharDisplayWidth;
        
        float marginRatio = 0.05;
        if (localUvX < marginRatio || localUvX > (1.0 - marginRatio))
        {
            return float3(0.0, 0.0, 0.0);
        }
        
        localUvX = (localUvX - marginRatio) / (1.0 - 2.0 * marginRatio);
        localUvX = saturate(localUvX);
        
        localUvX += characterOffset; 
        localUvX = saturate(localUvX);

        float charWidthInAtlas = 1.0 / kColumns;
        float charStartUInAtlas = spriteColumnIndex * charWidthInAtlas;
        
        float insetRatio = 0.15;
        float actualInset = charWidthInAtlas * insetRatio;

        float sampleStartU = charStartUInAtlas + actualInset;
        float sampleEndU = charStartUInAtlas + charWidthInAtlas - actualInset;
        
        float finalSpriteU = lerp(sampleStartU, sampleEndU, localUvX);

        finalSpriteU = clamp(finalSpriteU, sampleStartU, sampleEndU);

        const float2 spriteUv = float2(finalSpriteU, saturate(uv.y));

        if (spriteUv.x < sampleStartU || spriteUv.x > sampleEndU || spriteUv.y < 0.0 || spriteUv.y > 1.0)
        {
            return float3(0.0, 0.0, 0.0);
        }

        if (spriteColumnIndex < 0.0 || spriteColumnIndex >= kColumns)
        {
            return float3(0.0, 0.0, 0.0);
        }

        const float4 tex = LIL_SAMPLE_2D(_SpriteNumberTexture, sampler_SpriteNumberTexture, spriteUv);
        
        const float alphaFromTex = 2.0 - 2.0 * tex.a;
        const float colAlpha = saturate((1.0 - alphaFromTex) / fwidth(alphaFromTex));
        return tex.rgb * colAlpha;
    } else {
        return float3(0.0, 0.0, 0.0);
    }
}

//------------------------------------------------------------------------------------------------------------------------------
// Decal Heart Rate Functions

/*!
 * @brief Apply decal texture to the fragment data.
 * @param [in,out] fd Fragment data to be modified.
 * @param [in] samp Sampler for texture sampling.
 */
void lilGetDecalTexture(inout lilFragData fd LIL_SAMP_IN_FUNC(samp))
{
    if(!_ActiveDecalTexture) return;
    
    float2 offset = float2(_DecalPositionXVector.x, _DecalPositionYVector.x);
    float2 scale = max(float2(_DecalScaleXVector.x, _DecalScaleYVector.x), float2(0.001, 0.001));
    float angle = -_DecalRotation;
    float2 uv2 = invAffineTransform(fd.uvMain, offset, angle, scale);
    
    float4 decalColor = LIL_SAMPLE_2D(_DecalTexture, sampler_DecalTexture, uv2) * _DecalTextureColor;
    decalColor.a *= lilIsIn0to1(uv2);
    
    if(decalColor.a > 0.0)
    {
        float blendAlpha = decalColor.a;
        
        #if LIL_RENDER != 0
            // Handle alpha modes if needed for different render modes
        #endif
        
        fd.col.rgb = lerp(fd.col.rgb, lilBlendColor(fd.col.rgb, decalColor.rgb, blendAlpha, _DecalTextureBlendMode), decalColor.a);
    }
}

/*!
 * @brief Apply numeric display decal to the fragment data.
 * @param [in,out] fd Fragment data to be modified.
 * @param [in] samp Sampler for texture sampling.
 */
void lilGetDecalNumber(inout lilFragData fd LIL_SAMP_IN_FUNC(samp))
{
    if(!_ActiveDecalNumber) return;
    
    float2 offset = float2(_TexPositionXVector.x, _TexPositionYVector.x);
    float2 scale = max(float2(_TexScaleXVector.x, _TexScaleYVector.x), float2(0.001, 0.001));
    float angle = -_NumTexRotation;
    float2 numUv = invAffineTransform(fd.uvMain, offset, angle, scale);
    
    float heartRateValue = round(float(_IntHeartRate));
    float3 numberColor = sampleSprite(heartRateValue, numUv, _NumTexDisplaylength, float(_NumTexAlignment), _NumTexCharacterOffset);
    float numberAlpha = length(numberColor) > 0.01 ? 1.0 : 0.0;
    numberAlpha *= lilIsIn0to1(numUv);
    
    if(numberAlpha > 0.0)
    {
        float4 colorNumber = float4(numberColor * _SpriteNumberTextureColor.rgb, numberAlpha * _SpriteNumberTextureColor.a);
        float blendAlpha = colorNumber.a;
            #if LIL_RENDER != 0
            // Handle alpha modes if needed for different render modes
        #endif
        
        fd.col.rgb = lerp(fd.col.rgb, lilBlendColor(fd.col.rgb, colorNumber.rgb, blendAlpha, _NumberTextureBlendMode), colorNumber.a);
    }
}

//------------------------------------------------------------------------------------------------------------------------------
/*!
 * @brief Alpha mask override for decal processing.
 * This macro is used to inject decal processing into the shader pipeline
 * while maintaining proper lighting and transparency handling.
 */
#if !defined(OVERRIDE_ALPHAMASK)
    #define OVERRIDE_ALPHAMASK \
        /* Apply decal texture first, then numeric overlay */ \
        lilGetDecalTexture(fd LIL_SAMP_IN(sampler_MainTex)); \
        lilGetDecalNumber(fd LIL_SAMP_IN(sampler_MainTex));
#endif