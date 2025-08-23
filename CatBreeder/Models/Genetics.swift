//
//  Genetics.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import Foundation
import SwiftUI

// MARK: - 遗传学数据结构
struct GeneticsData: Codable, Hashable {
    let sex: Sex
    let baseColor: BaseColor
    let dilution: Dilution
    let pattern: Pattern
    let white: WhitePattern
    let modifiers: [GeneticModifier]
    
    init(
        sex: Sex = Sex.random(),
        baseColor: BaseColor = BaseColor.random(),
        dilution: Dilution = Dilution.random(),
        pattern: Pattern = Pattern.random(),
        white: WhitePattern = WhitePattern.random(),
        modifiers: [GeneticModifier] = []
    ) {
        self.sex = sex
        self.baseColor = baseColor
        self.dilution = dilution
        self.pattern = pattern
        self.white = white
        self.modifiers = modifiers
    }
}

// MARK: - 性别
enum Sex: String, CaseIterable, Codable {
    case male = "公猫"
    case female = "母猫"
    
    static func random() -> Sex {
        return Bool.random() ? .male : .female
    }
}

// MARK: - 基础颜色基因
enum BaseColor: String, CaseIterable, Codable {
    case black = "黑色"
    case chocolate = "巧克力色"
    case cinnamon = "肉桂色"
    case red = "橙色"
    
    var hexColor: String {
        switch self {
        case .black: return "#2C2C2C"
        case .chocolate: return "#7B3F00"
        case .cinnamon: return "#D2691E"
        case .red: return "#FF6B35"
        }
    }
    
    var probability: Double {
        switch self {
        case .black: return 0.50      // 50% - 最常见
        case .red: return 0.35        // 35% - 常见
        case .chocolate: return 0.10  // 10% - 少见
        case .cinnamon: return 0.05   // 5% - 稀有
        }
    }
    
    static func random() -> BaseColor {
        let rand = Double.random(in: 0...1)
        var cumulative = 0.0
        
        for color in BaseColor.allCases {
            cumulative += color.probability
            if rand <= cumulative {
                return color
            }
        }
        return .black // 默认值
    }
}

// MARK: - 稀释基因
enum Dilution: String, CaseIterable, Codable {
    case dense = "浓郁"
    case dilute = "淡化"
    
    var probability: Double {
        switch self {
        case .dense: return 0.75   // 75%
        case .dilute: return 0.25  // 25%
        }
    }
    
    static func random() -> Dilution {
        return Double.random(in: 0...1) < 0.25 ? .dilute : .dense
    }
    
    // 稀释后的颜色效果
    func apply(to baseColor: BaseColor) -> String {
        switch self {
        case .dense:
            return baseColor.hexColor
        case .dilute:
            switch baseColor {
            case .black: return "#8C8C8C"      // 蓝灰色
            case .chocolate: return "#D2B48C"  // 淡紫色
            case .cinnamon: return "#FAEBD7"   // 米色
            case .red: return "#FFB6C1"        // 奶油色
            }
        }
    }
}

// MARK: - 花纹基因
enum Pattern: String, CaseIterable, Codable {
    case solid = "纯色"
    case tabby = "虎斑"
    case pointed = "重点色"
    case tortoiseshell = "玳瑁"
    case calico = "三花"
    
    var probability: Double {
        switch self {
        case .solid: return 0.30      // 30%
        case .tabby: return 0.35      // 35%
        case .pointed: return 0.15    // 15%
        case .tortoiseshell: return 0.12 // 12%
        case .calico: return 0.08     // 8%
        }
    }
    
    static func random() -> Pattern {
        let rand = Double.random(in: 0...1)
        var cumulative = 0.0
        
        for pattern in Pattern.allCases {
            cumulative += pattern.probability
            if rand <= cumulative {
                return pattern
            }
        }
        return .solid
    }
    
    var emoji: String {
        switch self {
        case .solid: return "⚪"
        case .tabby: return "🐅"
        case .pointed: return "🎯"
        case .tortoiseshell: return "🟤"
        case .calico: return "🌈"
        }
    }
}

// MARK: - 白色基因
struct WhitePattern: Codable, Hashable {
    let distribution: WhiteDistribution
    let percentage: Double  // 0-100, 白色覆盖的百分比
    
    init(distribution: WhiteDistribution = WhiteDistribution.random(),
         percentage: Double = Double.random(in: 0...100)) {
        self.distribution = distribution
        self.percentage = min(100, max(0, percentage))
    }
    
    static func random() -> WhitePattern {
        return WhitePattern()
    }
}

enum WhiteDistribution: String, CaseIterable, Codable {
    case none = "无白色"
    case locket = "白胸"
    case bicolor = "双色"
    case harlequin = "丑角"
    case van = "梵猫"
    case solid = "全白"
    
    var probability: Double {
        switch self {
        case .none: return 0.40      // 40%
        case .locket: return 0.25    // 25%
        case .bicolor: return 0.15   // 15%
        case .harlequin: return 0.10 // 10%
        case .van: return 0.07       // 7%
        case .solid: return 0.03     // 3%
        }
    }
    
    static func random() -> WhiteDistribution {
        let rand = Double.random(in: 0...1)
        var cumulative = 0.0
        
        for distribution in WhiteDistribution.allCases {
            cumulative += distribution.probability
            if rand <= cumulative {
                return distribution
            }
        }
        return .none
    }
}

// MARK: - 基因修饰符
enum GeneticModifier: String, CaseIterable, Codable {
    case silver = "银色基因"
    case golden = "金色基因"
    case smoke = "烟色基因"
    case shaded = "阴影基因"
    
    var rarity: Double {
        switch self {
        case .silver: return 0.05
        case .golden: return 0.03
        case .smoke: return 0.04
        case .shaded: return 0.02
        }
    }
}

// MARK: - 遗传学扩展功能
extension GeneticsData {
    // 获取完整的颜色描述
    func getColorDescription() -> String {
        var description = ""
        
        // 基础颜色
        description += baseColor.rawValue
        
        // 稀释效果
        if dilution == .dilute {
            description += "(淡化)"
        }
        
        // 花纹
        if pattern != .solid {
            description += " " + pattern.rawValue
        }
        
        // 白色分布
        if white.distribution != .none {
            description += " " + white.distribution.rawValue
        }
        
        return description
    }
    
    // 计算遗传复杂度（影响稀有度）
    func getComplexityScore() -> Int {
        var score = 0
        
        // 稀有基础颜色加分
        if baseColor == .chocolate || baseColor == .cinnamon { score += 2 }
        
        // 稀释基因加分
        if dilution == .dilute { score += 1 }
        
        // 复杂花纹加分
        if pattern == .pointed || pattern == .calico { score += 2 }
        else if pattern == .tortoiseshell { score += 1 }
        
        // 白色分布加分
        switch white.distribution {
        case .van, .solid: score += 3
        case .harlequin: score += 2
        case .bicolor: score += 1
        default: break
        }
        
        // 修饰符加分
        score += modifiers.count * 2
        
        return score
    }
    
    // 生成随机遗传数据
    static func random() -> GeneticsData {
        var modifiers: [GeneticModifier] = []
        
        // 5% 概率获得修饰符
        for modifier in GeneticModifier.allCases {
            if Double.random(in: 0...1) < modifier.rarity {
                modifiers.append(modifier)
            }
        }
        
        return GeneticsData(
            sex: Sex.random(),
            baseColor: BaseColor.random(),
            dilution: Dilution.random(),
            pattern: Pattern.random(),
            white: WhitePattern.random(),
            modifiers: modifiers
        )
    }
}
