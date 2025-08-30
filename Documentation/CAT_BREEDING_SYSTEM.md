# 🧬 猫咪合成系统技术文档

## 📋 目录

1. [系统架构概览](#系统架构概览)
2. [五步骤合成流程详解](#五步骤合成流程详解)
3. [数据流转与AI生成](#数据流转与ai生成)
4. [代码实现细节](#代码实现细节)
5. [调试与优化指南](#调试与优化指南)

---

## 系统架构概览

### 核心组件关系

```
用户界面 (StepByStepBreedingView)
    ↓ 用户5步骤配置
BreedingState (状态管理)
    ↓ 生成BreedingSummary
CatDescriptionGenerator (描述生成)
    ↓ generateFocusedAIDescription()
ImageGenerator (图片生成)
    ↓ POE API调用
生成的猫咪图片
```

### 关键文件结构

```
CatBreeder/
├── Views/Components/
│   └── StepByStepBreedingView.swift    # UI与交互逻辑
├── Services/
│   ├── CatDescriptionGenerator.swift   # 遗传特征→AI关键词
│   ├── ImageGenerator.swift            # AI图片生成
│   └── PoeAPIService.swift            # API调用
└── Models/
    ├── Cat.swift                       # 猫咪数据模型
    └── Genetics.swift                  # 遗传学系统
```

---

## 五步骤合成流程详解

### 步骤1: 性别和染色体选择 🧬

#### UI交互选项
- **性别选择**: 公猫 / 母猫
- **XXY基因突变**: 万分之一概率触发（仅公猫）
- **染色体抽取**: 
  - 公猫: 1条X染色体
  - 母猫: 2条X染色体
  - XXY公猫: 2条X染色体

#### 染色体类型（ColorChromosome枚举）
```swift
enum ColorChromosome {
    case 黑色基因   // 生成黑色系
    case 巧克力基因 // 生成巧克力色系
    case 肉桂基因   // 生成肉桂色系
    case 橙色基因   // 生成橙色系
}
```

#### 数据生成格式
```swift
// BreedingState存储
selectedSex: Sex = .male / .female
chromosomes: [ColorChromosome] = [.黑色基因] // 或 [.橙色基因, .黑色基因]
isXXY: Bool = false / true

// 描述文本生成 (generateDetailedColorDescription)
"单一黑色基因"         // 1条相同染色体
"双重橙色基因"         // 2条相同染色体
"黑色与橙色混合基因"   // 2条不同染色体
```

#### AI关键词映射
```swift
// 单一或双重基因
"单一黑色基因" → "black cat"
"双重橙色基因" → "orange cat"
"双重巧克力基因" → "brown cat"
"双重肉桂基因" → "cinnamon cat"

// 混合基因（玳瑁/三花）
"黑色与橙色混合基因" → "tortoiseshell cat" + "black and orange tortoiseshell"
"巧克力与橙色混合基因" → "tortoiseshell cat" + "chocolate tortoiseshell"
"肉桂与橙色混合基因" → "tortoiseshell cat" + "cinnamon tortoiseshell"
// 如果有白色，额外添加 → "calico pattern"
```

---

### 步骤2: 稀释基因调节 💧

#### UI交互选项

##### 2.1 稀释程度滑块
- **范围**: 0% - 100% 连续调节
- **实时颜色插值**: ColorInterpolator计算中间色
- **程度分级**:
  ```swift
  0-30%:  轻度稀释 → "light dilution"
  30-70%: 中度稀释 → "medium dilution"  
  70-100%: 重度稀释 → "heavy dilution"
  ```

##### 2.2 染色方法（5档吸附式滑块）
```swift
enum DyeingMethod {
    case 单色工艺    // 0.0-0.2 → "solid coloring"
    case 毛尖色工艺  // 0.2-0.4 → "tipped fur"
    case 阴影色工艺  // 0.4-0.6 → "shaded fur"
    case 烟色工艺    // 0.6-0.8 → "smoke fur"
    case 斑纹色工艺  // 0.8-1.0 → "banded fur"
}
```

#### 颜色计算逻辑
```swift
// ColorInterpolator.interpolate()
基础色 + 稀释度 = 最终色
黑色 + 50%稀释 = 深灰色
橙色 + 70%稀释 = 奶油色
```

#### 数据生成格式
```swift
// BreedingState存储
dilutionLevel: Double = 0.65  // 65%稀释
dyeingMethodLevel: Double = 0.3  // 对应毛尖色

// 描述文本
"65%稀释（中度稀释），采用毛尖色工艺"
```

---

### 步骤3: 斑纹选择 🐅

#### UI交互选项

##### 3.1 斑纹类型（5选1）
```swift
enum TabbySubtype {
    case none      // 无斑纹 → "solid color"
    case 鲭鱼斑    // → "mackerel tabby"
    case 古典斑    // → "classic tabby"
    case 点斑      // → "spotted tabby"
    case 细斑纹    // → "ticked tabby"
}
```

##### 3.2 斑纹覆盖度滑块
- **范围**: 0% - 100%
- **覆盖度映射**:
  ```swift
  90-100%: "heavy markings"
  70-90%:  "prominent markings"
  50-70%:  "moderate markings"
  0-50%:   "subtle markings"
  ```

#### 特殊规则
```swift
// 橘猫强制斑纹检测
if (公猫有橙色 || 母猫双橙色) {
    强制显示斑纹（即使选择无斑纹）
    UI显示提示: "橘猫必须有斑纹！"
}
```

#### 数据生成格式
```swift
// BreedingState存储
selectedTabbySubtype: TabbySubtype? = .鲭鱼斑
patternCoverage: Double = 0.79  // 79%覆盖

// 描述文本
"鲭鱼斑纹理（79%覆盖度）"  // 有斑纹
"无斑纹纯色"              // 无斑纹
```

---

### 步骤4: 加白设置 ⚪

#### UI交互选项

##### 4.1 身体加白滑块
- **范围**: 0% - 100%
- **白色分布级别**:
  ```swift
  0%:     无白色 (WhiteDistribution.none)
  1-20%:  白胸 (WhiteDistribution.locket) → "white chest"
  20-40%: 双色 (WhiteDistribution.bicolor) → "bicolor"
  40-60%: 花斑 (WhiteDistribution.harlequin) → "harlequin pattern"
  60-80%: 梵色 (WhiteDistribution.van) → "van pattern"
  80-100%: 纯白 (WhiteDistribution.solid) → "white"
  ```

##### 4.2 面部白斑选择器（8个独立区域）
```swift
enum WhiteArea {
    case forehead     // 额头 → "white forehead"
    case noseBridge   // 鼻梁 → "white blaze"
    case chin         // 下巴 → "white chin"
    case leftEyeRing  // 左眼圈 → "white left eye ring"
    case rightEyeRing // 右眼圈 → "white right eye ring"
    case muzzle       // 嘴周 → "white muzzle"
    case leftCheek    // 左脸颊 → "white left cheek"
    case rightCheek   // 右脸颊 → "white right cheek"
}
```

##### 4.3 快速预设
- **随机白斑**: 随机选择2-4个面部区域
- **经典白胸**: bodyWhiteLevel=30%, 面部:下巴+嘴周
- **双色猫**: bodyWhiteLevel=50%, 面部:鼻梁+下巴+嘴周
- **清除白色**: 重置所有白色设置

#### 数据生成格式
```swift
// BreedingState存储
bodyWhiteLevel: Double = 0.0  // 身体无白色
selectedFaceWhiteAreas: Set<WhiteArea> = [.leftEyeRing, .rightEyeRing]

// 描述文本
"面部白斑分布于右眼圈、左眼圈"  // 仅面部
"30%身体白袜，面部白斑（嘴周、下巴）"  // 身体+面部
```

---

### 步骤5: 特殊调色 🌡️

#### UI交互选项

##### 5.1 温度敏感效果
```swift
enum TemperatureEffect {
    case 局部变深  // 四肢颜色加深 → "darker extremities"
    case 局部变浅  // 选定部位变浅 → "lighter [parts]"
}
```

##### 5.2 影响部位选择（多选）
```swift
enum BodyPart {
    case 面部   → "face"
    case 耳朵   → "ears"
    case 身体   → "body"
    case 腹部   → "belly"
    case 四肢   → "limbs"
    case 尾巴   → "tail"
}
```

##### AI关键词映射（温度效果）
```swift
// 局部变浅
"局部变浅（腹部）" → "lighter belly"
"局部变浅（面部）" → "lighter face"
"局部变浅（耳朵）" → "lighter ears"
"局部变浅（四肢）" → "lighter limbs"

// 局部变深
"局部变深（面部）" → "darker face"
"局部变深（耳朵）" → "darker ears"
"局部变深（四肢）" → "darker limbs"
"局部变深（尾巴）" → "darker tail"

// 强度映射
"80%强度" → "strong temperature effect"
"50%强度" → "moderate temperature effect"
"20%强度" → "subtle temperature effect"

// 特殊模式
"局部变深（面部、四肢）" → "pointed coloration" + "siamese-like pattern"
```

##### 5.3 效果强度滑块
- **范围**: 0% - 100%
- **强度描述**: 直接传递百分比

#### 数据生成格式
```swift
// BreedingState存储
selectedTemperatureEffect: TemperatureEffect? = .局部变浅
selectedBodyParts: Set<BodyPart> = [.腹部]
temperatureIntensity: Double = 0.5  // 50%强度

// 描述文本
"局部变浅（腹部，50%强度）"
```

---

## 数据流转与AI生成

### 1. 用户配置汇总流程

```swift
// StepByStepBreedingView.swift: completeBreeding()
用户完成5步骤
    ↓
BreedingSummary.create(from: breedingState)
    ↓
生成detailedColorDescription:
"单一黑色基因，65%稀释（中度稀释），采用毛尖色工艺，
无斑纹纯色，面部白斑分布于右眼圈、左眼圈"
```

### 2. AI关键词提取流程

```swift
// CatDescriptionGenerator.swift: generateFocusedAIDescription()
输入: BreedingSummary.detailedColorDescription
处理: 文本模式匹配 → AI关键词
输出: "black cat, medium dilution, tipped fur, solid color, 
       white right eye ring, white left eye ring"
```

### 3. 最终Prompt构建

```swift
// ImageGenerator.swift: buildFinalPrompt()
基础组件:
  - "Full body cat"          // 全身照
  - "standing pose"          // 站立姿势
  + focusedDescription       // 遗传特征关键词
  + "whole body visible"     // 确保全身可见
  + "complete cat from head to tail"
  + "professional photography"
  + style.modifiers          // 风格修饰符(cartoon/realistic等)
  + quality.modifiers        // 质量修饰符

最终输出:
"Full body cat, standing pose, black cat, medium dilution, 
tipped fur, solid color, white right eye ring, white left eye ring, 
whole body visible, complete cat from head to tail, 
professional photography, high quality, detailed, 
cartoon style, animated, stylized, cute, good quality, detailed"
```

### 4. POE API调用

```swift
// PoeAPIService.swift: generateImage()
请求参数:
{
    model: "GPT-Image-1",
    prompt: 最终Prompt,
    size: "1024x1024"
}

响应:
{
    url: "https://...",  // 生成的图片URL
    revisedPrompt: "..."  // AI优化后的prompt
}
```

---

## 代码实现细节

### 关键数据结构

#### BreedingState (状态管理核心)
```swift
class BreedingState: ObservableObject {
    // 步骤1
    @Published var selectedSex: Sex = .male
    @Published var chromosomes: [ColorChromosome] = []
    @Published var isXXY: Bool = false
    
    // 步骤2
    @Published var dilutionLevel: Double = 0.0
    @Published var dyeingMethodLevel: Double = 0.1
    
    // 步骤3
    @Published var selectedTabbySubtype: TabbySubtype? = nil
    @Published var patternCoverage: Double = 0.5
    
    // 步骤4
    @Published var bodyWhiteLevel: Double = 0.0
    @Published var selectedFaceWhiteAreas: Set<WhiteArea> = []
    
    // 步骤5
    @Published var selectedTemperatureEffect: TemperatureEffect? = nil
    @Published var selectedBodyParts: Set<BodyPart> = []
    @Published var temperatureIntensity: Double = 0.3
    
    // 最终结果
    @Published var finalCat: Cat?
    @Published var breedingSummary: BreedingSummary?
}
```

#### BreedingSummary (汇总信息)
```swift
struct BreedingSummary {
    let predictedBreed: CatBreed           // 预测品种
    let detailedColorDescription: String   // 详细描述（中文）
    let stepByStepChoices: [StepChoice]    // 每步选择记录
    
    static func create(from state: BreedingState) -> BreedingSummary {
        // 生成详细描述
        let description = generateDetailedColorDescription(...)
        // 预测品种
        let breed = CatBreed.predictBreed(...)
        // 记录选择
        let choices = recordStepChoices(...)
        
        return BreedingSummary(...)
    }
}
```

### 关键转换函数

#### 1. 遗传特征描述生成
```swift
// BreedingSummary.generateDetailedColorDescription()
func generateDetailedColorDescription(...) -> String {
    var description = ""
    
    // 步骤1: 基因描述
    if chromosomes.count == 1 {
        description += "单一\(chromosomes[0].rawValue)基因"
    }
    
    // 步骤2: 稀释描述
    if dilutionLevel > 0.1 {
        description += "，\(Int(dilutionLevel*100))%稀释"
    }
    
    // 步骤3: 斑纹描述
    if tabbySubtype != .none {
        description += "，\(tabbySubtype.rawValue)纹理"
    }
    
    // ... 继续其他步骤
    return description
}
```

#### 2. AI关键词提取
```swift
// CatDescriptionGenerator.generateFocusedAIDescription()
func generateFocusedAIDescription(from summary: BreedingSummary) -> String {
    var components: [String] = []
    let details = summary.detailedColorDescription
    
    // 基础颜色识别
    if details.contains("黑色基因") {
        components.append("black cat")
    }
    
    // 稀释程度识别
    if details.contains("中度稀释") {
        components.append("medium dilution")
    }
    
    // 面部白斑精确识别
    if details.contains("右眼圈") {
        components.append("white right eye ring")
    }
    
    // ... 继续其他特征
    return components.joined(separator: ", ")
}
```

---

## 调试与优化指南

### 日志追踪点

#### 1. 用户配置记录
```swift
// StepByStepBreedingView: completeBreeding()
print("🎯 [合成完成] 用户配置:")
print("  步骤1: \(breedingState.chromosomes)")
print("  步骤2: \(breedingState.dilutionLevel)")
// ...
```

#### 2. 描述生成追踪
```swift
// CatDescriptionGenerator: generateFocusedAIDescription()
print("📋 [ImageGenerator] 原始汇总: \(summary.detailedColorDescription)")
print("🎯 [ImageGenerator] 专注描述: \(focusedDescription)")
```

#### 3. 最终Prompt监控
```swift
// ImageGenerator: buildFinalPrompt()
print("🎯 [ImageGenerator] 发送给AI的最终Prompt:")
print("   \(finalPrompt)")
```

### 常见问题排查

#### 问题1: 遗传特征未正确传递
- **检查点**: `BreedingSummary.detailedColorDescription`
- **验证**: 查看控制台日志中的"原始汇总"
- **解决**: 检查`generateDetailedColorDescription()`逻辑

#### 问题2: AI关键词缺失
- **检查点**: `generateFocusedAIDescription()`的输出
- **验证**: 查看"专注描述"是否包含所有特征
- **解决**: 添加缺失的`details.contains()`条件

#### 问题3: 图片不符合配置
- **检查点**: 最终Prompt内容
- **验证**: 查看"最终Prompt"是否完整
- **解决**: 检查`buildFinalPrompt()`组装逻辑

### 性能优化建议

1. **缓存优化**: PromptCache避免重复API调用
2. **并行处理**: 多个AI请求可并发执行
3. **智能重试**: 网络错误自动重试（最多3次）
4. **渐进式渲染**: 先显示低质量预览，后台生成高质量

---

## 附录：快速定位指南

| 功能 | 文件位置 | 关键函数 |
|------|---------|----------|
| 5步骤UI | StepByStepBreedingView.swift | `currentStepView` |
| 用户配置存储 | StepByStepBreedingView.swift | `BreedingState` class |
| 汇总生成 | StepByStepBreedingView.swift | `BreedingSummary.create()` |
| 中文描述生成 | StepByStepBreedingView.swift | `generateDetailedColorDescription()` |
| AI关键词提取 | CatDescriptionGenerator.swift | `generateFocusedAIDescription()` |
| Prompt构建 | ImageGenerator.swift | `buildFinalPrompt()` |
| API调用 | PoeAPIService.swift | `generateImage()` |
| 颜色插值 | StepByStepBreedingView.swift | `ColorInterpolator` |
| 品种预测 | StepByStepBreedingView.swift | `CatBreed.predictBreed()` |

---

## 更新记录

- **2025-08-30**: 修复面部白斑精确识别
- **2025-08-30**: 增强基础颜色基因识别
- **2025-08-30**: 添加无斑纹纯色识别

---

*本文档由Claude AI助手生成，用于《猫咪合成师》项目的技术理解与维护*