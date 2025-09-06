//
//  TabbySubtype.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

// MARK: - 虎斑细分类型枚举
enum TabbySubtype: String, CaseIterable {
    case mackerel = "鲭鱼斑"     // 细密平行条纹
    case classic = "古典斑"      // 宽螺旋条纹  
    case spotted = "点斑"        // 点状斑纹
    case ticked = "细斑纹"       // 每根毛发有色带
    case none = "无斑纹"         // 纯色
    
    var description: String {
        switch self {
        case .mackerel: return "细密平行条纹"
        case .classic: return "宽螺旋条纹"
        case .spotted: return "点状斑纹"
        case .ticked: return "毛发色带"
        case .none: return "纯色无纹"
        }
    }
    
    var emoji: String {
        switch self {
        case .mackerel: return "🐟"
        case .classic: return "🐅"
        case .spotted: return "🐆"
        case .ticked: return "🎋"
        case .none: return "⚪"
        }
    }
    
    static func random() -> TabbySubtype {
        return TabbySubtype.allCases.randomElement() ?? .none
    }
}