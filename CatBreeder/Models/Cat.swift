//
//  Cat.swift
//  CatBreeder
//
//  Created by Sheldon027 on 2025/8/23.
//

import Foundation
import SwiftUI

// MARK: - 猫咪主数据模型
struct Cat: Identifiable, Codable, Hashable {
    let id: UUID
    let createdDate: Date
    let genetics: GeneticsData
    let appearance: AppearanceData
    let rarity: RarityLevel
    let generation: Int
    
    // 用户自定义属性
    var nickname: String?
    var isFavorite: Bool
    var notes: String?
    
    init(genetics: GeneticsData) {
        self.id = UUID()
        self.createdDate = Date()
        self.genetics = genetics
        self.appearance = AppearanceData(from: genetics)
        self.rarity = RarityLevel.calculate(from: genetics)
        self.generation = 1
        self.nickname = nil
        self.isFavorite = false
        self.notes = nil
    }
}

// MARK: - 稀有度等级
enum RarityLevel: String, CaseIterable, Codable {
    case common = "普通"
    case uncommon = "少见"
    case rare = "稀有"
    case epic = "史诗"
    case legendary = "传说"
    
    var color: Color {
        switch self {
        case .common: return .gray
        case .uncommon: return .green
        case .rare: return .blue
        case .epic: return .purple
        case .legendary: return .orange
        }
    }
    
    var probability: Double {
        switch self {
        case .common: return 0.45      // 45%
        case .uncommon: return 0.30    // 30%
        case .rare: return 0.15        // 15%
        case .epic: return 0.08        // 8%
        case .legendary: return 0.02   // 2%
        }
    }
    
    static func calculate(from genetics: GeneticsData) -> RarityLevel {
        // 基于遗传特征计算稀有度的简化算法
        var rarePoints = 0
        
        // 稀有颜色加分
        if genetics.dilution == .dilute { rarePoints += 1 }
        if genetics.white.distribution == .bicolor { rarePoints += 1 }
        if genetics.pattern == .pointed { rarePoints += 2 }
        
        // 特殊组合加分
        if genetics.baseColor == .chocolate || genetics.baseColor == .cinnamon {
            rarePoints += 2
        }
        
        return switch rarePoints {
        case 0...1: .common
        case 2: .uncommon
        case 3: .rare
        case 4: .epic
        default: .legendary
        }
    }
}

// MARK: - 猫咪扩展功能
extension Cat {
    // 获取显示名称
    var displayName: String {
        return nickname ?? "猫咪 #\(id.uuidString.prefix(4))"
    }
    
    // 获取主要颜色描述
    var colorDescription: String {
        return genetics.getColorDescription()
    }
    
    // 是否为特殊猫咪
    var isSpecial: Bool {
        return rarity == .epic || rarity == .legendary
    }
}
