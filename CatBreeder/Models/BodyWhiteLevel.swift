//
//  BodyWhiteLevel.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

// MARK: - 身体白色等级枚举
enum BodyWhiteLevel: CaseIterable {
    case none        // 0% - 无白色
    case paws        // 20% - 足底白袜
    case legs        // 40% - 腿部白色
    case belly       // 60% - 腹部白色
    case chest       // 80% - 胸部白色
    case full        // 100% - 接近全白
    
    var percentage: Double {
        switch self {
        case .none: return 0.0
        case .paws: return 0.2
        case .legs: return 0.4
        case .belly: return 0.6
        case .chest: return 0.8
        case .full: return 1.0
        }
    }
    
    var name: String {
        switch self {
        case .none: return "无白色"
        case .paws: return "白袜"
        case .legs: return "白腿"
        case .belly: return "白腹"
        case .chest: return "白胸"
        case .full: return "近全白"
        }
    }
    
    var description: String {
        switch self {
        case .none: return "保持原色"
        case .paws: return "足底白袜，优雅点缀"
        case .legs: return "腿部白色，活泼可爱"
        case .belly: return "腹部白色，温和亲近"
        case .chest: return "胸部白色，高贵典雅"
        case .full: return "大面积白色，纯洁美丽"
        }
    }
    
    static func fromPercentage(_ value: Double) -> BodyWhiteLevel {
        switch value {
        case 0.0..<0.1: return .none
        case 0.1..<0.3: return .paws
        case 0.3..<0.5: return .legs
        case 0.5..<0.7: return .belly
        case 0.7..<0.9: return .chest
        default: return .full
        }
    }
}