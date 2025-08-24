# 🐱 猫咪合成师 (Cat Breeder)

一款基于遗传学算法的iOS猫咪合成游戏，让玩家通过科学的遗传学原理培育出各种稀有的虚拟猫咪。

## 🎮 游戏特色

- **5步骤交互式合成**：性别选择 → 稀释基因 → 斑纹设置 → 加白调节 → 特殊调色
- **真实遗传学系统**：基于现实猫咪遗传学原理的基因算法
- **稀有度收集**：普通、少见、稀有、史诗、传说五个等级
- **猫舍管理**：收集和管理你的猫咪收藏
- **科学教育**：寓教于乐的遗传学科普

## 📱 技术栈

- **平台**：iOS 15.0+
- **语言**：Swift 5.0+
- **框架**：SwiftUI + Core Data
- **架构**：MVVM模式
- **数据存储**：Core Data + UserDefaults

## 🏗️ 项目结构

```
CatBreeder/
├── Models/                 # 数据模型层
│   ├── Cat.swift          # 猫咪核心数据模型
│   ├── Genetics.swift     # 遗传学算法实现  
│   ├── Appearance.swift   # 外观渲染系统
│   └── GameData.swift     # 游戏数据管理
├── Views/                 # 视图层
│   ├── BreedingView.swift       # 合成界面
│   ├── CollectionView.swift     # 猫舍管理
│   ├── EncyclopediaView.swift   # 图鉴系统
│   ├── SettingsView.swift       # 设置界面
│   └── Components/              # 可复用组件
│       ├── CatCardView.swift
│       ├── CatResultView.swift
│       ├── StatusBar.swift
│       └── StepByStepBreedingView.swift
├── Assets.xcassets/       # 图片资源
├── CatBreeder.xcdatamodeld/  # Core Data模型
└── Persistence.swift     # 数据持久化
```

## 🧬 遗传学系统

### 基因类型
- **基础颜色**：黑色、巧克力色、肉桂色、橙色
- **稀释基因**：浓郁/淡化效果 (0-100%连续调节)
- **斑纹模式**：鲭鱼斑、古典斑、点斑、细斑纹、无斑纹
- **白色分布**：8个精确白斑区域可选
- **特殊基因**：银色、金色、烟色、阴影等修饰基因

### 稀有度计算
基于遗传复杂度的概率分布：
- 🟢 普通 (45%)
- 🔵 少见 (30%) 
- 🟡 稀有 (15%)
- 🟣 史诗 (8%)
- 🔴 传说 (2%)

## 🚀 开发进度

### ✅ 已完成
- [x] 基础架构搭建
- [x] 遗传学算法核心
- [x] 猫咪外观渲染系统
- [x] 5步骤交互式合成流程
- [x] 猫舍收集管理系统
- [x] 数据持久化存储
- [x] 基础UI组件库

### 🔄 开发中
- [ ] 步骤5：特殊调色系统
- [ ] 体力机制实现
- [ ] 动画效果优化

### 📋 待实现
- [ ] 社交分享功能
- [ ] 图鉴系统完善
- [ ] 成就系统
- [ ] 科普教育气泡
- [ ] 音效系统

## 💻 开发环境

### 系统要求
- macOS 12.0+
- Xcode 14.0+
- iOS 15.0+ (目标设备)

### 构建步骤
```bash
# 克隆项目
git clone git@github.com:sheldson/CatBreeder_iOS.git
cd CatBreeder_iOS

# 在Xcode中打开
open CatBreeder.xcodeproj

# 或使用命令行构建
xcodebuild -project CatBreeder.xcodeproj -scheme CatBreeder build
```

### 常用命令
- **构建项目**: `⌘+B`
- **运行项目**: `⌘+R`
- **运行测试**: `⌘+U`
- **清理构建**: `Product > Clean Build Folder`

## 🧪 测试

项目包含完整的测试套件：

- **单元测试**: `CatBreederTests/`
- **UI测试**: `CatBreederUITests/`

```bash
# 运行所有测试
xcodebuild test -project CatBreeder.xcodeproj -scheme CatBreeder
```

## 📖 文档

- [架构设计方案](Documentation/《猫咪合成师》iOS应用架构设计方案.md)
- [产品需求文档](Documentation/《猫咪合成师》产品需求文档%20V1.0.md)
- [美术资源制作指南](Documentation/美术资源制作完整指南（小白版）.md)
- [开发者指南](CLAUDE.md)

## 🎨 设计资源

设计文件位于 `Design/` 目录：
- UI设计稿
- 猫咪素材库
- 参考资料

## 🤝 贡献指南

1. Fork 本项目
2. 创建特性分支 (`git checkout -b feature/AmazingFeature`)
3. 提交更改 (`git commit -m 'Add some AmazingFeature'`)
4. 推送分支 (`git push origin feature/AmazingFeature`)
5. 创建 Pull Request

### 代码规范
- 使用Swift官方代码风格
- 遵循SwiftUI最佳实践
- 添加适当的中文注释
- 保持良好的模块化结构

## 📄 许可证

本项目采用 MIT 许可证 - 查看 [LICENSE](LICENSE) 文件了解详情

## 📞 联系方式

- **开发者**: Sheldon
- **GitHub**: [@sheldson](https://github.com/sheldson)

## 🎯 路线图

### 版本 1.0 (MVP)
- [x] 核心合成系统
- [ ] 基础游戏机制
- [ ] 用户引导

### 版本 1.1
- [ ] 社交分享
- [ ] 成就系统
- [ ] 音效优化

### 版本 2.0
- [ ] 多人对战
- [ ] 猫咪繁育
- [ ] 云同步

---

> 🐾 让我们一起创造最可爱的虚拟猫咪世界！