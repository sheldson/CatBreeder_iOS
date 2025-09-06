//
//  BodyPart.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

enum BodyPart: String, CaseIterable {
    case face = "面部"
    case ears = "耳朵"
    case body = "身体"      // 除了面部、耳朵、四肢、尾巴以外的区域
    case belly = "腹部"     // 腹部区域
    case limbs = "四肢"
    case tail = "尾巴"
    
    var emoji: String {
        switch self {
        case .face: return "😺"
        case .ears: return "👂"
        case .body: return "🫸"
        case .belly: return "🤱"
        case .limbs: return "🦵"
        case .tail: return "↗️"
        }
    }
    
    var description: String {
        switch self {
        case .face: return "面部区域"
        case .ears: return "耳朵区域"
        case .body: return "身体主干（胸背部）"
        case .belly: return "腹部区域"
        case .limbs: return "四肢"
        case .tail: return "尾巴"
        }
    }
    
    // 体温等级（影响颜色变化程度）
    var temperatureLevel: Double {
        switch self {
        case .belly, .body: return 1.0      // 高体温区域
        case .face: return 0.7              // 中等体温
        case .ears, .limbs, .tail: return 0.3  // 低体温区域
        }
    }
}