# 🗺️ 猫咪合成设置与AI提示词完整映射表

> 本文档详细列出了5步骤合成系统中每个设置选项对应的AI提示词

---

## 📊 步骤1：性别和染色体选择

### 基础颜色基因映射（基于真实遗传学）

| 中文设置 | AI提示词 | 遗传学含义 |
|---------|----------|-----------|
| **单一黑色(B)基因** | `black cat` | B等位基因（显性） |
| **双重黑色(B)基因** | `black cat` | BB纯合子 |
| **单一橙色(O)基因** | `orange cat` | O基因（X连锁） |
| **双重橙色(O)基因** | `orange cat` | OO纯合子（母猫） |
| **单一巧克力色(b)基因** | `brown cat` | b等位基因（隐性） |
| **双重巧克力色(b)基因** | `brown cat` | bb纯合子 |
| **单一肉桂色(b')基因** | `cinnamon cat` | b'等位基因（更隐性） |
| **双重肉桂色(b')基因** | `cinnamon cat` | b'b'纯合子 |

### 混合基因映射（玳瑁/三花） - O基因与B系基因互作

| 中文设置 | AI提示词 | 遗传学解释 |
|---------|----------|-----------|
| **黑色(B)与橙色(O)混合** | `tortoiseshell cat`<br>`black and orange tortoiseshell` | X^O X^B（O与B共显性） |
| **橙色(O)与黑色(B)混合** | `tortoiseshell cat`<br>`black and orange tortoiseshell` | X^O X^B（O与B共显性） |
| **巧克力色(b)与橙色(O)混合** | `tortoiseshell cat`<br>`chocolate tortoiseshell` | X^O X^b（O与b共显性） |
| **橙色(O)与巧克力色(b)混合** | `tortoiseshell cat`<br>`chocolate tortoiseshell` | X^O X^b（O与b共显性） |
| **肉桂色(b')与橙色(O)混合** | `tortoiseshell cat`<br>`cinnamon tortoiseshell` | X^O X^b'（O与b'共显性） |
| **橙色(O)与肉桂色(b')混合** | `tortoiseshell cat`<br>`cinnamon tortoiseshell` | X^O X^b'（O与b'共显性） |
| *+ 有白色时额外添加* | `calico pattern` | S基因表达（白斑基因） |

---

## 💧 步骤2：稀释基因调节

### 稀释程度映射

| 中文设置 | AI提示词 | 范围 |
|---------|----------|------|
| **轻度稀释** | `light dilution` | 0-30% |
| **中度稀释** | `medium dilution` | 30-70% |
| **重度稀释** | `heavy dilution` | 70-100% |

### 染色方法映射

| 中文设置 | AI提示词 | 滑块值 |
|---------|----------|--------|
| **单色工艺** | 无特殊标记 | 0.0-0.2 |
| **毛尖色工艺** | `tipped fur` | 0.2-0.4 |
| **阴影色工艺** | `shaded fur` | 0.4-0.6 |
| **烟色工艺** | `smoke fur` | 0.6-0.8 |
| **斑纹色工艺** | `banded fur` | 0.8-1.0 |

---

## 🐅 步骤3：斑纹选择

### 斑纹类型映射

| 中文设置 | AI提示词 | 说明 |
|---------|----------|------|
| **无斑纹纯色** | `solid color` | 纯色无花纹 |
| **鲭鱼斑纹理** | `mackerel tabby` | 鱼骨状条纹 |
| **古典斑纹理** | `classic tabby` | 大理石纹 |
| **点斑纹理** | `spotted tabby` | 豹点斑纹 |
| **细斑纹理** | `ticked tabby` | 刺鼠斑纹 |

### 斑纹覆盖度映射

| 中文设置 | AI提示词 | 范围 |
|---------|----------|------|
| **低覆盖度** | `subtle markings` | 0-50% |
| **中覆盖度** | `moderate markings` | 50-70% |
| **高覆盖度** | `prominent markings` | 70-90% |
| **完全覆盖** | `heavy markings` | 90-100% |

---

## ⚪ 步骤4：加白设置

### 身体白色分布映射

| 中文设置 | AI提示词 | 范围 |
|---------|----------|------|
| **无白色** | 无标记 | 0% |
| **白胸** | `white chest` | 1-20% |
| **白袜** | `white socks` | 10-30% |
| **双色** | `bicolor` | 20-40% |
| **花斑** | `harlequin pattern` | 40-60% |
| **梵色** | `van pattern` | 60-80% |
| **纯白** | `white` | 80-100% |

### 面部白斑区域映射

| 中文设置 | AI提示词 | 位置 |
|---------|----------|------|
| **额头** | `white forehead` | 额头区域 |
| **鼻梁** | `white blaze` | 鼻梁中线 |
| **下巴** | `white chin` | 下巴区域 |
| **左眼圈** | `white left eye ring` | 左眼周围 |
| **右眼圈** | `white right eye ring` | 右眼周围 |
| **嘴周** | `white muzzle` | 嘴巴周围 |
| **左脸颊** | `white left cheek` | 左侧脸颊 |
| **右脸颊** | `white right cheek` | 右侧脸颊 |

### 快速预设映射

| 预设名称 | 身体白色 | 面部白斑 | AI提示词组合 |
|---------|---------|---------|-------------|
| **随机白斑** | 0% | 随机2-4个区域 | 根据选中区域生成 |
| **经典白胸** | 30% | 下巴+嘴周 | `white chest, white chin, white muzzle` |
| **双色猫** | 50% | 鼻梁+下巴+嘴周 | `bicolor, white blaze, white chin, white muzzle` |
| **清除白色** | 0% | 无 | 无白色相关标记 |

---

## 🌡️ 步骤5：特殊调色（温度敏感）

### 温度效果类型映射

| 中文设置 | 基础前缀 | 说明 |
|---------|----------|------|
| **局部变浅** | `lighter` | 高温区域变浅 |
| **局部变深** | `darker` | 低温区域变深 |

### 影响部位映射

| 中文部位 | 变浅时 | 变深时 |
|---------|--------|--------|
| **面部** | `lighter face` | `darker face` |
| **耳朵** | `lighter ears` | `darker ears` |
| **身体** | `lighter body` | `darker body` |
| **腹部** | `lighter belly` | `darker belly` |
| **四肢** | `lighter limbs` | `darker limbs` |
| **尾巴** | `lighter tail` | `darker tail` |

### 效果强度映射

| 强度范围 | AI提示词 | 说明 |
|---------|----------|------|
| **0-40%** | `subtle temperature effect` | 轻微效果 |
| **40-70%** | `moderate temperature effect` | 中等效果 |
| **70-100%** | `strong temperature effect` | 强烈效果 |

### 特殊模式识别

| 特殊组合 | 额外AI提示词 | 说明 |
|---------|-------------|------|
| **局部变深（面部+四肢）** | `pointed coloration`<br>`siamese-like pattern` | 暹罗猫重点色 |

---

## 🎯 完整示例

### 示例1：黑色玳瑁猫

**用户配置**：
- 步骤1: 黑色与橙色混合基因
- 步骤2: 50%稀释，毛尖色工艺
- 步骤3: 鲭鱼斑纹理，75%覆盖度
- 步骤4: 面部白斑（右眼圈、左眼圈）
- 步骤5: 无

**生成的AI提示词**：
```
Full body cat, standing pose, 
tortoiseshell cat, black and orange tortoiseshell,
medium dilution, tipped fur,
mackerel tabby, prominent markings,
white right eye ring, white left eye ring,
whole body visible, complete cat from head to tail,
professional photography, high quality, detailed
```

### 示例2：暹罗风格猫

**用户配置**：
- 步骤1: 单一巧克力基因
- 步骤2: 0%稀释，单色工艺
- 步骤3: 无斑纹纯色
- 步骤4: 无白色
- 步骤5: 局部变深（面部、耳朵、四肢、尾巴，85%强度）

**生成的AI提示词**：
```
Full body cat, standing pose,
brown cat,
solid color,
darker face, darker ears, darker limbs, darker tail,
strong temperature effect, pointed coloration, siamese-like pattern,
whole body visible, complete cat from head to tail,
professional photography, high quality, detailed
```

### 示例3：三花猫

**用户配置**：
- 步骤1: 黑色与橙色混合基因
- 步骤2: 30%稀释，阴影色工艺
- 步骤3: 无斑纹纯色
- 步骤4: 35%身体白袜，面部白斑（下巴、嘴周、鼻梁）
- 步骤5: 无

**生成的AI提示词**：
```
Full body cat, standing pose,
tortoiseshell cat, black and orange tortoiseshell, calico pattern,
light dilution, shaded fur,
solid color,
bicolor, white socks, white chin, white muzzle, white blaze,
whole body visible, complete cat from head to tail,
professional photography, high quality, detailed
```

---

## 📝 特殊规则说明

1. **橘猫强制斑纹**：
   - 公猫有橙色基因 或 母猫双橙色基因时
   - 即使选择"无斑纹"也会强制显示斑纹
   - UI会提示："橘猫必须有斑纹！"

2. **玳瑁/三花判定**：
   - 任何颜色与橙色混合 = 玳瑁
   - 玳瑁 + 白色 = 三花

3. **重点色识别**：
   - 局部变深 + 包含面部和四肢 = 自动添加暹罗猫模式

4. **叠加规则**：
   - 所有特征都是叠加的，不会互相覆盖
   - 例如：可以同时有斑纹、白色、温度效果

---

## 🔧 调试提示

在控制台查看关键日志：
- `🎯 [ImageGenerator] 专注描述:` - 查看提取的AI关键词
- `📋 [ImageGenerator] 原始汇总:` - 查看中文描述
- `🎯 [ImageGenerator] 发送给AI的最终Prompt:` - 查看完整提示词

---

*最后更新：2025-08-30*