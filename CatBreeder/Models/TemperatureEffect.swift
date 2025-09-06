//
//  TemperatureEffect.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

// MARK: - 温度敏感调色枚举
enum TemperatureEffect: String, CaseIterable {
    case lighten = "局部变浅"  // 高体温区域变浅
    case darken = "局部变深"   // 低体温区域变深
    
    var description: String {
        switch self {
        case .lighten: return "高体温区域颜色变浅，减少热量吸收"
        case .darken: return "低体温区域颜色变深，增加热量吸收"
        }
    }
    
    var emoji: String {
        switch self {
        case .lighten: return "☀️"
        case .darken: return "❄️" 
        }
    }
    
    var availableBodyParts: [BodyPart] {
        switch self {
        case .lighten:
            return [.belly, .body]  // 腹部和身体（高体温区域）
        case .darken:
            return [.face, .ears, .limbs, .tail]  // 面部、耳朵、四肢、尾巴（低体温区域）
        }
    }
}