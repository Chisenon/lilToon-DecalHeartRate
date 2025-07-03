# lilToon-DecalHeartRate

lilToonベースの心拍数に特化したDecalShader

## インストール方法

### VPM (VRChat Package Manager) を使用

**[https://chisenon.github.io/chisenote_vpm/](https://chisenon.github.io/chisenote_vpm/)**


## 必要要件

- **Unity**： 2019.4以降
- **[lilToon](https://lilxyzw.github.io/lilToon/)**： v1.8.0以降
- **VRChat SDK**： 3.0以降（VRChat使用時）

## 機能

- **心拍数表示**： 数値テクスチャを使用してリアルタイムで心拍数を表示
- **デカール機能**： テクスチャやエフェクトをオブジェクト表面に重ねて表示
- **エミッション制御**： 心拍数に応じてエミッションの強度を動的に変更
- **スケール制御**： 心拍数に応じてテクスチャのスケールを動的に変更
- **位置・回転調整**： デカールの位置、回転、スケールを自由に調整可能
- **ブレンドモード**： 複数のブレンドモードに対応

## 使用方法

1. マテリアルを作成し、シェーダーを「ChiseNote/DecalHeartRate」に設定
2. 心拍数表示用の数値テクスチャ（サンプルの`NumberTexture.png`など）を設定
3. 必要に応じてデカールテクスチャを設定
4. インスペクターで各種パラメータを調整

**VRChatでの動的制御**: リアルタイムで心拍数を変更するには、OSCでShaderを適応したMaterialのParameterを動かす必要があります。

## ライセンス

MIT License

このShaderは [lilToon](https://lilxyzw.github.io/lilToon/) と同じMITライセンスで提供されています。
