# 🐱 猫咪合成师 (Cat Breeder)

一款基于遗传学算法的iOS猫咪合成游戏，让玩家通过科学的遗传学原理培育出各种稀有的虚拟猫咪。

## 🎮 游戏特色

- **5步骤交互式合成**：性别选择 → 稀释基因 → 斑纹设置 → 加白调节 → 特殊调色
- **真实遗传学系统**：基于现实猫咪遗传学原理的基因算法
- **AI图片生成**：根据用户配置动态生成逼真的猫咪图片
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
├── Services/              # 服务层
│   ├── CatDescriptionGenerator.swift  # 猫咪描述生成器
│   ├── ImageGenerator.swift          # AI图片生成服务
│   ├── PromptOptimizer.swift         # 提示词优化器
│   ├── PoeAPIService.swift           # POE API集成
│   └── PromptCache.swift             # 提示词缓存
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

## 🤖 AI图片生成系统

### 核心特性
- **动态特征提取**：自动将用户5步骤配置转换为AI关键词
- **全身照生成**：强制显示猫咪完整身体，展示所有遗传特征
- **精确映射**：每个用户选择都对应特定的英文AI关键词
- **性能优化**：减少不必要的API调用，直接生成关键词

### 技术实现
- **CatDescriptionGenerator**: 动态遗传特征提取引擎
- **ImageGenerator**: AI图片生成服务，集成POE API
- **PromptOptimizer**: 智能提示词优化，专注核心特征

### 特征映射示例
| 用户配置 | AI关键词 | 说明 |
|---------|----------|------|
| 94%覆盖度 | `heavy markings` | 动态覆盖度映射 |
| 阴影色工艺 | `shaded fur` | 染色工艺翻译 |
| 面部白斑(嘴周、下巴) | `white muzzle, white chin` | 精确白斑识别 |
| 腹部变浅50% | `lighter belly` | 温度敏感效果 |

## 🚀 开发进度

### ✅ 已完成
- [x] 基础架构搭建
- [x] 遗传学算法核心
- [x] 猫咪外观渲染系统
- [x] 5步骤交互式合成流程
- [x] 猫舍收集管理系统
- [x] 数据持久化存储
- [x] 基础UI组件库
- [x] **AI图片生成系统** ✨
  - [x] 动态遗传特征提取
  - [x] 全身照强制生成
  - [x] POE API集成
  - [x] 智能提示词优化

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

#### 1. 克隆和基础设置
```bash
# 克隆项目
git clone git@github.com:sheldson/CatBreeder_iOS.git
cd CatBreeder_iOS
```

#### 2. 配置API Key（必需）

**方式1：使用自动化脚本（推荐）**
```bash
# 运行API Key设置向导
./setup-api-key.sh
```

**方式2：手动设置环境变量**
```bash
# 在你的shell配置文件中添加（~/.zshrc 或 ~/.bash_profile）
echo 'export POE_API_KEY="your_actual_poe_api_key"' >> ~/.zshrc
source ~/.zshrc
```

#### 3. 验证配置
```bash
# 检查环境变量是否设置正确
echo $POE_API_KEY
```

#### 4. 构建项目
```bash
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
- [x] AI图片生成系统
- [ ] 基础游戏机制
- [ ] 用户引导

### 版本 1.1
- [ ] 社交分享
- [ ] 成就系统
- [ ] 音效优化
- [ ] AI图片风格扩展

### 版本 2.0
- [ ] 多人对战
- [ ] 猫咪繁育
- [ ] 云同步
- [ ] AI图片质量提升

---

> 🐾 让我们一起创造最可爱的虚拟猫咪世界！