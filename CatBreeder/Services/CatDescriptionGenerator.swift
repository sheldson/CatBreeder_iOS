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
        
        // 基础颜色基因信息（基于真实遗传学）
        // 特殊处理：O基因与非O基因混合 = 玳瑁/三花
        if (details.contains("橙色(O)") && (details.contains("黑色(B)") || details.contains("巧克力色(b)") || details.contains("肉桂色(b')"))) ||
           ((details.contains("黑色(B)") || details.contains("巧克力色(b)") || details.contains("肉桂色(b')")) && details.contains("橙色(O)")) {
            // O基因与B系基因混合产生玳瑁效果
            components.append("tortoiseshell cat")
            
            // 判断具体的B系基因类型
            if details.contains("黑色(B)") {
                components.append("black and orange tortoiseshell")
            } else if details.contains("巧克力色(b)") {
                components.append("chocolate tortoiseshell")
            } else if details.contains("肉桂色(b')") {
                components.append("cinnamon tortoiseshell")
            }
            
            // 如果有较多白色，添加三花标记
            if details.contains("白斑") || details.contains("白袜") {
                components.append("calico pattern")
            }
        } else if details.contains("单一") || details.contains("双重") || details.contains("混合基因") {
            // 其他单一或双重基因情况
            if details.contains("橙色(O)") {
                components.append("orange cat")
            } else if details.contains("黑色(B)") {
                components.append("black cat")
            } else if details.contains("巧克力色(b)") {
                components.append("brown cat")
            } else if details.contains("肉桂色(b')") {
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
        
        // 斑纹类型 - 支持多种文本格式
        if details.contains("鲭鱼斑纹理") || details.contains("鲭鱼斑纹纹理") {
            components.append("mackerel tabby")
        } else if details.contains("古典斑纹理") || details.contains("古典斑纹纹理") {
            components.append("classic tabby")
        } else if details.contains("点斑纹理") || details.contains("点斑纹纹理") {
            components.append("spotted tabby")
        } else if details.contains("细斑纹理") || details.contains("细斑纹纹理") {
            components.append("ticked tabby")
        } else if details.contains("无斑纹纯色") {
            components.append("solid color")
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
        
        // 白色分布 - 精确识别面部区域
        if details.contains("白斑") || details.contains("白袜") || details.contains("白腿") || details.contains("白胸") || details.contains("白腹") {
            // 身体白色部位
            if details.contains("身体白袜") {
                components.append("white socks")
            }
            if details.contains("身体白腿") {
                components.append("white legs")
            }
            if details.contains("身体白胸") || details.contains("白胸") {
                components.append("white chest")
            }
            if details.contains("身体白腹") || details.contains("白腹") {
                components.append("white belly")
            }
            
            // 精确的面部白斑区域识别
            var specificFacialMarkings: [String] = []
            
            if details.contains("右眼圈") {
                specificFacialMarkings.append("white right eye ring")
            }
            if details.contains("左眼圈") {
                specificFacialMarkings.append("white left eye ring")
            }
            if details.contains("额头") {
                specificFacialMarkings.append("white forehead")
            }
            if details.contains("鼻梁") {
                specificFacialMarkings.append("white blaze")
            }
            if details.contains("下巴") {
                specificFacialMarkings.append("white chin")
            }
            if details.contains("嘴周") {
                specificFacialMarkings.append("white muzzle")
            }
            if details.contains("左脸颊") {
                specificFacialMarkings.append("white left cheek")
            }
            if details.contains("右脸颊") {
                specificFacialMarkings.append("white right cheek")
            }
            
            // 如果有具体的面部区域，使用具体描述；否则使用通用描述
            if !specificFacialMarkings.isEmpty {
                components.append(contentsOf: specificFacialMarkings)
            } else if details.contains("面部白斑") {
                components.append("white facial markings")
            }
            
            // 其他部位
            if details.contains("胸部") {
                components.append("white chest")
            }
        }
        
        // 温度敏感效果 - 完整识别所有部位和强度
        if details.contains("局部变浅") || details.contains("局部变深") {
            var temperatureComponents: [String] = []
            
            // 判断是变深还是变浅
            let isDarken = details.contains("局部变深")
            let effectPrefix = isDarken ? "darker" : "lighter"
            
            // 识别具体部位
            if details.contains("面部") {
                temperatureComponents.append("\(effectPrefix) face")
            }
            if details.contains("耳朵") {
                temperatureComponents.append("\(effectPrefix) ears")
            }
            if details.contains("身体") {
                temperatureComponents.append("\(effectPrefix) body")
            }
            if details.contains("腹部") {
                temperatureComponents.append("\(effectPrefix) belly")
            }
            if details.contains("四肢") {
                temperatureComponents.append("\(effectPrefix) limbs")
            }
            if details.contains("尾巴") {
                temperatureComponents.append("\(effectPrefix) tail")
            }
            
            // 提取强度百分比
            let intensityMatches = details.matches(for: #"\d+%强度"#)
            if !intensityMatches.isEmpty {
                let intensityText = intensityMatches.first ?? ""
                let numberString = intensityText.replacingOccurrences(of: "%强度", with: "")
                if let intensityValue = Int(numberString) {
                    if intensityValue > 70 {
                        temperatureComponents.append("strong temperature effect")
                    } else if intensityValue > 40 {
                        temperatureComponents.append("moderate temperature effect")
                    } else {
                        temperatureComponents.append("subtle temperature effect")
                    }
                }
            }
            
            // 如果是暹罗猫样式的重点色（变深在四肢）
            if isDarken && details.contains("四肢") && details.contains("面部") {
                temperatureComponents.append("pointed coloration")
                temperatureComponents.append("siamese-like pattern")
            }
            
            // 添加所有温度相关的组件
            components.append(contentsOf: temperatureComponents)
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