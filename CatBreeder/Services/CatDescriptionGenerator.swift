//
//  CatDescriptionGenerator.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import Foundation

// MARK: - String扩展：正则表达式支持
extension String {
    func matches(for regex: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))
            return results.map {
                String(self[Range($0.range, in: self)!])
            }
        } catch let error {
            print("无效的正则表达式: \(error.localizedDescription)")
            return []
        }
    }
}

// MARK: - 猫咪描述生成器
class CatDescriptionGenerator {
    static let shared = CatDescriptionGenerator()
    
    private init() {}
    
    // MARK: - 主要生成方法
    
    /// 生成猫咪的自然语言描述
    func generateDescription(for cat: Cat) -> String {
        var description = ""
        
        // 基础信息
        description += generateBasicInfo(cat)
        
        // 外观描述
        description += generateAppearanceDescription(cat)
        
        // 遗传特征
        description += generateGeneticFeatures(cat)
        
        // 特殊特征
        description += generateSpecialFeatures(cat)
        
        return description.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 基于合成汇总生成详细的AI绘画描述
    func generateDetailedAIDescription(from summary: BreedingSummary) -> String {
        return summary.detailedColorDescription
    }
    
    /// 基于合成汇总生成简化但完整的AI描述（包含所有遗传细节）
    func generateFocusedAIDescription(from summary: BreedingSummary) -> String {
        var components: [String] = []
        
        // 从详细描述中提取关键信息
        let details = summary.detailedColorDescription
        
        // 基础颜色基因信息
        if details.contains("单一") || details.contains("基因") {
            if details.contains("橙色基因") {
                components.append("orange cat")
            } else if details.contains("黑色基因") {
                components.append("black cat")
            } else if details.contains("巧克力基因") {
                components.append("brown cat")
            } else if details.contains("肉桂基因") {
                components.append("cinnamon cat")
            }
        }
        
        // 稀释程度
        if details.contains("稀释") {
            if details.contains("轻度稀释") {
                components.append("light dilution")
            } else if details.contains("中度稀释") {
                components.append("medium dilution")  
            } else if details.contains("重度稀释") {
                components.append("heavy dilution")
            }
        }
        
        // 染色工艺
        if details.contains("毛尖色工艺") {
            components.append("tipped fur")
        } else if details.contains("阴影色工艺") {
            components.append("shaded fur")
        } else if details.contains("烟色工艺") {
            components.append("smoke fur")
        }
        
        // 斑纹类型
        if details.contains("鲭鱼斑纹理") {
            components.append("mackerel tabby")
        } else if details.contains("古典斑纹理") {
            components.append("classic tabby")
        } else if details.contains("点斑纹理") {
            components.append("spotted tabby")
        } else if details.contains("细斑纹理") {
            components.append("ticked tabby")
        }
        
        // 覆盖度信息
        let coverageMatches = details.matches(for: #"\d+%覆盖度"#)
        if !coverageMatches.isEmpty {
            let coverageText = coverageMatches.first ?? ""
            let numberString = coverageText.replacingOccurrences(of: "%覆盖度", with: "")
            if let coverageValue = Int(numberString) {
                if coverageValue > 90 {
                    components.append("heavy markings")
                } else if coverageValue > 70 {
                    components.append("prominent markings")
                } else if coverageValue > 50 {
                    components.append("moderate markings")
                } else {
                    components.append("subtle markings")
                }
            }
        }
        
        // 白色分布 - 更详细的识别
        if details.contains("白斑") || details.contains("白袜") {
            if details.contains("身体白袜") {
                components.append("white socks")
            }
            if details.contains("面部白斑") {
                components.append("white facial markings")
            }
            if details.contains("嘴周") {
                components.append("white muzzle")
            }
            if details.contains("下巴") {
                components.append("white chin")
            }
            if details.contains("鼻梁") {
                components.append("white blaze")
            }
            if details.contains("胸部") {
                components.append("white chest")
            }
        }
        
        // 温度敏感效果
        if details.contains("局部变浅") {
            if details.contains("腹部") {
                components.append("lighter belly")
            } else {
                components.append("temperature sensitive coloring")
            }
        }
        
        return components.joined(separator: ", ")
    }
    
    /// 生成简化的外观描述（用于prompt）
    func generateSimpleDescription(for cat: Cat) -> String {
        var parts: [String] = []
        
        // 性别
        parts.append(cat.genetics.sex.rawValue)
        
        // 主要颜色
        let colorDesc = generateColorDescription(cat.genetics, cat.appearance)
        parts.append(colorDesc)
        
        // 花纹
        if cat.genetics.pattern != .solid {
            parts.append(cat.genetics.pattern.rawValue)
        }
        
        // 白色分布
        if cat.genetics.white.distribution != .none {
            parts.append(cat.genetics.white.distribution.rawValue)
        }
        
        // 眼睛颜色
        parts.append("\(cat.appearance.eyeColor.rawValue)眼睛")
        
        return parts.joined(separator: "")
    }
    
    // MARK: - 私有辅助方法
    
    private func generateBasicInfo(_ cat: Cat) -> String {
        var info = ""
        
        info += "这是一只\(cat.genetics.sex.rawValue)，"
        info += "稀有度为\(cat.rarity.rawValue)。"
        
        return info
    }
    
    private func generateAppearanceDescription(_ cat: Cat) -> String {
        var desc = ""
        
        // 主要颜色描述
        let colorDesc = generateDetailedColorDescription(cat.genetics, cat.appearance)
        desc += "毛色为\(colorDesc)。"
        
        // 眼睛描述
        desc += "眼睛是\(cat.appearance.eyeColor.rawValue)的，"
        
        // 鼻子颜色
        desc += "鼻子呈\(cat.appearance.noseColor.rawValue)。"
        
        return desc
    }
    
    private func generateGeneticFeatures(_ cat: Cat) -> String {
        var features = ""
        
        // 花纹描述
        switch cat.genetics.pattern {
        case .solid:
            features += "纯色毛发，没有明显花纹。"
        case .tabby:
            features += "身上有美丽的虎斑花纹。"
        case .pointed:
            features += "具有重点色特征，四肢和面部颜色较深。"
        case .tortoiseshell:
            features += "拥有玳瑁色花纹，多种颜色交织。"
        case .calico:
            features += "三花色花纹，白色、橙色和黑色相间。"
        }
        
        // 稀释基因效果
        if cat.genetics.dilution == .dilute {
            features += "毛色经过稀释基因淡化，呈现柔和色调。"
        }
        
        // 白色分布
        switch cat.genetics.white.distribution {
        case .none:
            break
        case .locket:
            features += "胸前有小块白色毛发。"
        case .bicolor:
            features += "身上有双色分布，白色与主色相间。"
        case .harlequin:
            features += "具有丑角式白色分布模式。"
        case .van:
            features += "主要为白色，仅头部和尾部保留原色。"
        case .solid:
            features += "全身纯白色毛发。"
        }
        
        return features
    }
    
    private func generateSpecialFeatures(_ cat: Cat) -> String {
        var special = ""
        
        // 特殊视觉效果
        if cat.appearance.hasSpecialEffects {
            let effects = cat.appearance.specialEffects.map { $0.rawValue }
            special += "毛发具有\(effects.joined(separator: "和"))。"
        }
        
        // 遗传修饰符
        if !cat.genetics.modifiers.isEmpty {
            let modifiers = cat.genetics.modifiers.map { $0.rawValue }
            special += "携带\(modifiers.joined(separator: "、"))等特殊基因。"
        }
        
        return special
    }
    
    private func generateColorDescription(_ genetics: GeneticsData, _ appearance: AppearanceData) -> String {
        var color = genetics.baseColor.rawValue
        
        // 稀释效果
        if genetics.dilution == .dilute {
            color = "淡" + color
        }
        
        // 修饰符效果
        for modifier in genetics.modifiers {
            switch modifier {
            case .silver:
                color = "银" + color
            case .golden:
                color = "金" + color
            case .smoke:
                color = "烟" + color
            case .shaded:
                color = "阴影" + color
            }
        }
        
        return color
    }
    
    private func generateDetailedColorDescription(_ genetics: GeneticsData, _ appearance: AppearanceData) -> String {
        let basicColor = generateColorDescription(genetics, appearance)
        
        // 如果有次要颜色（玳瑁、三花）
        if let secondaryColor = appearance.secondaryColor {
            return "\(basicColor)与\(secondaryColor.name)相间"
        }
        
        return basicColor
    }
}

// MARK: - 扩展：支持不同描述风格
extension CatDescriptionGenerator {
    
    /// 生成适合AI绘画的关键词描述
    func generateAIPromptKeywords(for cat: Cat) -> [String] {
        var keywords: [String] = []
        
        // 动物类型
        keywords.append("cat")
        keywords.append("cute cat")
        
        // 性别（如果需要）
        if cat.genetics.sex == .male {
            keywords.append("male cat")
        } else {
            keywords.append("female cat")
        }
        
        // 主要颜色
        let colorKeyword = generateColorKeyword(cat.genetics, cat.appearance)
        keywords.append("\(colorKeyword) fur")
        
        // 花纹
        let patternKeyword = generatePatternKeyword(cat.genetics.pattern)
        if !patternKeyword.isEmpty {
            keywords.append(patternKeyword)
        }
        
        // 眼睛颜色
        let eyeKeyword = generateEyeColorKeyword(cat.appearance.eyeColor)
        keywords.append("\(eyeKeyword) eyes")
        
        // 白色分布
        if cat.genetics.white.distribution != .none {
            let whiteKeyword = generateWhitePatternKeyword(cat.genetics.white.distribution)
            keywords.append(whiteKeyword)
        }
        
        // 品质描述
        keywords.append("beautiful")
        keywords.append("detailed")
        keywords.append("high quality")
        
        return keywords
    }
    
    private func generateColorKeyword(_ genetics: GeneticsData, _ appearance: AppearanceData) -> String {
        switch genetics.baseColor {
        case .black:
            return genetics.dilution == .dilute ? "gray" : "black"
        case .chocolate:
            return genetics.dilution == .dilute ? "lilac" : "brown"
        case .cinnamon:
            return genetics.dilution == .dilute ? "fawn" : "cinnamon"
        case .red:
            return genetics.dilution == .dilute ? "cream" : "orange"
        }
    }
    
    private func generatePatternKeyword(_ pattern: Pattern) -> String {
        switch pattern {
        case .solid:
            return "solid color"
        case .tabby:
            return "tabby stripes"
        case .pointed:
            return "pointed coloration"
        case .tortoiseshell:
            return "tortoiseshell pattern"
        case .calico:
            return "calico pattern"
        }
    }
    
    private func generateEyeColorKeyword(_ eyeColor: EyeColor) -> String {
        switch eyeColor {
        case .copper:
            return "copper"
        case .gold:
            return "golden"
        case .green:
            return "green"
        case .blue:
            return "blue"
        case .odd:
            return "heterochromia"
        }
    }
    
    private func generateWhitePatternKeyword(_ white: WhiteDistribution) -> String {
        switch white {
        case .none:
            return ""
        case .locket:
            return "white chest"
        case .bicolor:
            return "bicolor"
        case .harlequin:
            return "harlequin pattern"
        case .van:
            return "van pattern"
        case .solid:
            return "white"
        }
    }
}