# lilToon-DecalHeartRate

### lilToonベースの心拍数表示に特化したDecalShader

<img width="1174" height="758" alt="DHR_Number" src="https://github.com/user-attachments/assets/82961c4b-3a69-4c4e-bdb0-5f4c960b8aea" />

## インストール方法

### VPM (VRChat Package Manager) を使用

**[https://chisenon.github.io/chisenote_vpm/](https://chisenon.github.io/chisenote_vpm/)**


## 必要要件

- **Unity**： 2019.4以降
- **[lilToon](https://lilxyzw.github.io/lilToon/)**： v2.0.0以降
- **VRChat SDK**： 3.0以降（VRChat使用時）

## 機能

- **心拍数表示**： 数値テクスチャを使用してリアルタイムで心拍数を表示
- **デカール機能**： テクスチャやエフェクトをオブジェクト表面に重ねて表示
- **エミッション制御**： 心拍数に応じてエミッションの強度を動的に変更
- **スケール制御**： 心拍数に応じてテクスチャのスケールを動的に変更
- **位置・回転調整**： デカールの位置、回転、スケールを自由に調整可能
- **ブレンドモード**： 複数のブレンドモードに対応

## デモギャラリー

### エミッション発光
<img width="958" height="566" alt="DHR_Emission" src="https://github.com/user-attachments/assets/8a035879-e42c-428c-864f-62aeab48b459" />

### 心拍数によるスケール変化
<img width="936" height="652" alt="DHR_Scale" src="https://github.com/user-attachments/assets/8e673eae-8709-46c6-9a11-78a417f22df7" />

## 使用方法

1. マテリアルを作成し、シェーダーを「ChiseNote/DecalHeartRate」に設定
2. 心拍数表示用の数値テクスチャ（サンプルの`NumberTexture.png`など）を設定
3. 必要に応じてデカールテクスチャを設定
4. インスペクターで各種パラメータを調整

> 詳しくは下記のURLを参照してください
> [https://chisenon.github.io/ChiseDocument/ja_JP/lildhr/dhr_index.html](https://chisenon.github.io/ChiseDocument/ja_JP/lildhr/dhr_index.html)

**VRChatでの動的制御**： リアルタイムで心拍数を変更するには、OSCでShaderを適応したMaterialのParameterを動かす必要があります。

## Installer (Coming Soon)

複雑な手動設定を自動化し、最小工程で導入を完結させる専用GUIツールを開発中です！

<img width="471" height="481" alt="Installer" src="https://github.com/user-attachments/assets/f3556de0-cc60-42e1-8b1e-9b6aeae46302" />

- **One-Click Setup**：NDMFを活用し、アバターを破壊せず自動で適用
- **Modern UI**：Unity標準機能で構成しつつ、迷いのない操作体験を追求

※ 現在、有償配布に向けて最終調整中です。

設計の詳細は[先行公開ドキュメント](https://chisenon.github.io/ChiseDocument/ja_JP/dhri/dhri_index.html)をご確認ください。



## ライセンス

MIT License

このShaderは [lilToon](https://lilxyzw.github.io/lilToon/) と同じMITライセンスで提供されています。
