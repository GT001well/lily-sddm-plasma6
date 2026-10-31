# Lily SDDM 设计构思

`prototype/` 是本项目的视觉设计构思。HTML 原型用于快速调整毛玻璃登录界面的
布局、层级和色彩，根目录的 `Main.qml` 负责最终 SDDM 界面与真实登录交互。

## 预览

```bash
make prototype
```

预览使用真实项目壁纸 `assets/wallpaper.webp`。

## 检查

```bash
./scripts/check-prototype.sh
```

## 与 QML 的边界

HTML 的 `backdrop-filter` 只用于布局预览。SDDM QML 使用 `QtQuick.Effects`
实时模糊左侧壁纸，并在启动时采样壁纸生成主题色。HTML 原型使用固定设计
token，不执行运行时取色。

