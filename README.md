# Apex Inspired Single Player FPS (Godot 4.3)

Apex Legendsの操作感にインスパイアされた、**シングルプレイヤーFPSプロトタイプ**です。

## 特徴
- 高速移動（Walk / Sprint / Slide / Slide Jump）
- Coyote Time (0.15s)
- 武器4種（R301 / Wingman / Mastiff / ChargeRifle）
- Hitscan射撃 (`intersect_ray()`)
- 敵AI（PATROL / ALERT / ATTACK / DEAD）
- HUD（HP, Shield, Weapon, Ammo, Crosshair, Kill feed）
- Procedural audio（`AudioStreamGenerator`、音声ファイル不使用）

## 実行方法
1. Godot 4.3 をインストール
2. プロジェクトを開いて `scenes/Main.tscn` を実行

またはエクスポート後:
- Windows: `setup.bat`
- Linux/macOS(WSL含む): `setup.sh`

## ビルド（Windows exe）
```bash
chmod +x export.sh
./export.sh
```
Godotの実行ファイル名が異なる場合:
```bash
GODOT_BIN=godot4.3 ./export.sh
```

## 操作
- WASD: 移動
- Shift: Sprint
- Ctrl: Slide
- Space: Jump
- LMB: Fire
- RMB: ADS
- R: Reload
- 1-4: 武器切替
- Esc: マウスキャプチャ切替

## 注意
このリポジトリは**テキストのみ**で構成されます。`.wav/.ogg/.png/.fbx/.glb` などのバイナリアセットは含みません。
