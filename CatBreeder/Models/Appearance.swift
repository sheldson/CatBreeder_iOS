//
//  Appearance.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import Foundation
import SwiftUI

// MARK: - 外观数据结构
struct AppearanceData: Codable, Hashable {
    let primaryColor: ColorInfo
    let secondaryColor: ColorInfo?
    let whiteAreas: WhiteAreas
    let patternOverlay: PatternOverlay
    let specialEffects: [VisualEffect]
    let eyeColor: EyeColor
    let noseColor: NoseColor
    
    // 从遗传数据生成外观
    init(from genetics: GeneticsData) {
        // 计算主要颜色
        self.primaryColor = ColorInfo.fromGenetics(
            baseColor: genetics.baseColor,
            dilution: genetics.dilution,
            modifiers: genetics.modifiers
        )
        
        // 计算次要颜色（用于双色猫咪）
        self.secondaryColor = AppearanceData.calculateSecondaryColor(from: genetics)
        
        // 白色区域分布
        self.whiteAreas = WhiteAreas.fromGenetics(genetics.white)
        
        // 花纹叠加
        self.patternOverlay = PatternOverlay.fromGenetics(genetics.pattern)
        
        // 特殊视觉效果
        self.specialEffects = VisualEffect.fromGenetics(genetics.modifiers)
        
        // 眼睛颜色
        self.eyeColor = EyeColor.fromGenetics(genetics)
        
        // 鼻子颜色
        self.noseColor = NoseColor.fromGenetics(genetics.baseColor, genetics.dilution)
    }
}

// MARK: - 颜色信息
struct ColorInfo: Codable, Hashable {
    let hexValue: String
    let name: String
    let intensity: Double  // 0.0-1.0 颜色强度
    let saturation: Double // 0.0-1.0 饱和度
    
    var swiftUIColor: Color {
        return Color(hex: hexValue)
    }
    
    static func fromGenetics(
        baseColor: BaseColor,
        dilution: Dilution,
        modifiers: [GeneticModifier]
    ) -> ColorInfo {
        // 获取基础颜色
        var hexValue = dilution.apply(to: baseColor)
        var intensity = dilution == .dense ? 1.0 : 0.7
        var saturation = 1.0
        
        // 应用修饰符效果
        for modifier in modifiers {
            switch modifier {
            case .silver:
                saturation *= 0.3
                intensity *= 0.8
            case .golden:
                hexValue = ColorInfo.addGoldenTint(to: hexValue)
                saturation *= 0.9
            case .smoke:
                intensity *= 0.6
                saturation *= 0.7
            case .shaded:
                intensity *= 0.4
                saturation *= 0.5
            }
        }
        
        let name = ColorInfo.generateColorName(
            baseColor: baseColor,
            dilution: dilution,
            modifiers: modifiers
        )
        
        return ColorInfo(
            hexValue: hexValue,
            name: name,
            intensity: intensity,
            saturation: saturation
        )
    }
    
    private static func addGoldenTint(to hexColor: String) -> String {
        // 简化的金色色调添加逻辑
        return hexColor // 实际实现会更复杂
    }
    
    private static func generateColorName(
        baseColor: BaseColor,
        dilution: Dilution,
        modifiers: [GeneticModifier]
    ) -> String {
        var name = baseColor.rawValue
        
        if dilution == .dilute {
            name = "淡" + name
        }
        
        for modifier in modifiers {
            name = modifier.rawValue + name
        }
        
        return name
    }
}

// MARK: - 白色区域分布
struct WhiteAreas: Codable, Hashable {
    let percentage: Double      // 白色覆盖百分比
    let distribution: [WhiteSpot] // 白色区域位置
    let pattern: WhiteDistribution
    
    static func fromGenetics(_ whitePattern: WhitePattern) -> WhiteAreas {
        let spots = WhiteAreas.generateWhiteSpots(
            distribution: whitePattern.distribution,
            percentage: whitePattern.percentage
        )
        
        return WhiteAreas(
            percentage: whitePattern.percentage,
            distribution: spots,
            pattern: whitePattern.distribution
        )
    }
    
    private static func generateWhiteSpots(
        distribution: WhiteDistribution,
        percentage: Double
    ) -> [WhiteSpot] {
        switch distribution {
        case .none:
            return []
        case .locket:
            return [WhiteSpot(area: .chest, coverage: min(percentage, 15))]
        case .bicolor:
            return [
                WhiteSpot(area: .chest, coverage: percentage * 0.4),
                WhiteSpot(area: .belly, coverage: percentage * 0.3),
                WhiteSpot(area: .paws, coverage: percentage * 0.3)
            ]
        case .harlequin:
            return [
                WhiteSpot(area: .chest, coverage: percentage * 0.3),
                WhiteSpot(area: .belly, coverage: percentage * 0.3),
                WhiteSpot(area: .face, coverage: percentage * 0.2),
                WhiteSpot(area: .paws, coverage: percentage * 0.2)
            ]
        case .van:
            return [
                WhiteSpot(area: .body, coverage: percentage * 0.8),
                WhiteSpot(area: .head, coverage: percentage * 0.1),
                WhiteSpot(area: .tail, coverage: percentage * 0.1)
            ]
        case .solid:
            return [WhiteSpot(area: .fullBody, coverage: 100)]
        }
    }
}

// MARK: - 白色斑点
struct WhiteSpot: Codable, Hashable {
    let area: BodyArea
    let coverage: Double // 该区域的白色覆盖百分比
}

enum BodyArea: String, CaseIterable, Codable {
    case head = "头部"
    case face = "面部"
    case chest = "胸部"
    case belly = "腹部"
    case back = "背部"
    case paws = "爪子"
    case tail = "尾巴"
    case body = "身体"
    case fullBody = "全身"
}

// MARK: - 花纹叠加
struct PatternOverlay: Codable, Hashable {
    let type: Pattern
    let intensity: Double    // 花纹强度
    let contrast: Double     // 花纹对比度
    let details: PatternDetails
    
    static func fromGenetics(_ pattern: Pattern) -> PatternOverlay {
        let details = PatternDetails.generate(for: pattern)
        
        return PatternOverlay(
            type: pattern,
            intensity: Double.random(in: 0.6...1.0),
            contrast: Double.random(in: 0.5...0.9),
            details: details
        )
    }
}

// MARK: - 花纹细节
struct PatternDetails: Codable, Hashable {
    let stripeWidth: Double?     // 条纹宽度（虎斑用）
    let stripeSpacing: Double?   // 条纹间距（虎斑用）
    let spotSize: Double?        // 斑点大小
    let marbleIntensity: Double? // 大理石花纹强度
    
    static func generate(for pattern: Pattern) -> PatternDetails {
        switch pattern {
        case .solid:
            return PatternDetails(
                stripeWidth: nil,
                stripeSpacing: nil,
                spotSize: nil,
                marbleIntensity: nil
            )
        case .tabby:
            return PatternDetails(
                stripeWidth: Double.random(in: 2...8),
                stripeSpacing: Double.random(in: 5...15),
                spotSize: nil,
                marbleIntensity: nil
            )
        case .pointed:
            return PatternDetails(
                stripeWidth: nil,
                stripeSpacing: nil,
                spotSize: nil,
                marbleIntensity: Double.random(in: 0.3...0.7)
            )
        case .tortoiseshell, .calico:
            return PatternDetails(
                stripeWidth: nil,
                stripeSpacing: nil,
                spotSize: Double.random(in: 10...30),
                marbleIntensity: Double.random(in: 0.4...0.8)
            )
        }
    }
}

// MARK: - 视觉效果
enum VisualEffect: String, CaseIterable, Codable {
    case shimmer = "闪光效果"
    case metallic = "金属光泽"
    case pearl = "珍珠光泽"
    case rainbow = "彩虹反光"
    case glow = "发光效果"
    
    static func fromGenetics(_ modifiers: [GeneticModifier]) -> [VisualEffect] {
        var effects: [VisualEffect] = []
        
        for modifier in modifiers {
            switch modifier {
            case .silver:
                effects.append(.metallic)
                if Double.random(in: 0...1) < 0.3 {
                    effects.append(.shimmer)
                }
            case .golden:
                effects.append(.metallic)
                if Double.random(in: 0...1) < 0.2 {
                    effects.append(.glow)
                }
            case .smoke:
                effects.append(.pearl)
            case .shaded:
                if Double.random(in: 0...1) < 0.1 {
                    effects.append(.rainbow)
                }
            }
        }
        
        return effects
    }
}

// MARK: - 眼睛颜色
enum EyeColor: String, CaseIterable, Codable {
    case copper = "铜色"
    case gold = "金色"
    case green = "绿色"
    case blue = "蓝色"
    case odd = "鸳鸯眼"
    
    var hexValue: String {
        switch self {
        case .copper: return "#B87333"
        case .gold: return "#FFD700"
        case .green: return "#50C878"
        case .blue: return "#4169E1"
        case .odd: return "#4169E1" // 默认显示蓝色
        }
    }
    
    var swiftUIColor: Color {
        return Color(hex: hexValue)
    }
    
    static func fromGenetics(_ genetics: GeneticsData) -> EyeColor {
        // 简化的眼色遗传逻辑
        if genetics.white.distribution == .solid {
            // 全白猫容易有蓝眼或鸳鸯眼
            return Double.random(in: 0...1) < 0.6 ? .blue : .odd
        }
        
        if genetics.pattern == .pointed {
            // 重点色猫通常是蓝眼
            return .blue
        }
        
        // 其他情况的随机分布
        let rand = Double.random(in: 0...1)
        switch rand {
        case 0...0.4: return .copper
        case 0.4...0.7: return .gold
        case 0.7...0.9: return .green
        case 0.9...0.95: return .blue
        default: return .odd
        }
    }
}

// MARK: - 鼻子颜色
enum NoseColor: String, CaseIterable, Codable {
    case black = "黑色"
    case pink = "粉色"
    case brown = "棕色"
    case brick = "砖红色"
    case blue = "蓝灰色"
    
    var hexValue: String {
        switch self {
        case .black: return "#2C2C2C"
        case .pink: return "#FFB6C1"
        case .brown: return "#8B4513"
        case .brick: return "#CB4154"
        case .blue: return "#6A5ACD"
        }
    }
    
    static func fromGenetics(_ baseColor: BaseColor, _ dilution: Dilution) -> NoseColor {
        switch (baseColor, dilution) {
        case (.black, .dense): return .black
        case (.black, .dilute): return .blue
        case (.chocolate, .dense): return .brown
        case (.chocolate, .dilute): return .pink
        case (.cinnamon, _): return .brick
        case (.red, _): return .pink
        }
    }
}

// MARK: - 辅助功能扩展
extension AppearanceData {
    // 获取主要显示颜色
    var mainDisplayColor: Color {
        return primaryColor.swiftUIColor
    }
    
    // 是否有特殊效果
    var hasSpecialEffects: Bool {
        return !specialEffects.isEmpty
    }
    
    // 获取完整外观描述
    func getAppearanceDescription() -> String {
        var description = primaryColor.name
        
        if let secondary = secondaryColor {
            description += " 配 " + secondary.name
        }
        
        if whiteAreas.percentage > 0 {
            description += " (" + whiteAreas.pattern.rawValue + ")"
        }
        
        if !specialEffects.isEmpty {
            let effectNames = specialEffects.map { $0.rawValue }.joined(separator: "、")
            description += " 具有" + effectNames
        }
        
        return description
    }
    
    // 计算次要颜色
    private static func calculateSecondaryColor(from genetics: GeneticsData) -> ColorInfo? {
        // 玳瑁和三花猫有次要颜色
        if genetics.pattern == .tortoiseshell || genetics.pattern == .calico {
            // 如果主色是黑系，次色是红系，反之亦然
            let secondaryBase: BaseColor = genetics.baseColor == .red ? .black : .red
            return ColorInfo.fromGenetics(
                baseColor: secondaryBase,
                dilution: genetics.dilution,
                modifiers: genetics.modifiers
            )
        }
        return nil
    }
}

// MARK: - Color扩展支持
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
