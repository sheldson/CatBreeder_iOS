//
//  DyeingMethod.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

// MARK: - 染色方法枚举
enum DyeingMethod: CaseIterable {
    case solid        // 单色（均匀染色）
    case tipped18     // 毛尖色（1/8）
    case shaded14     // 阴影色（1/4）
    case smoke12      // 烟色（1/2）
    case tabby        // 斑纹色（条纹挑染）
    
    var name: String {
        switch self {
        case .solid: return "单色"
        case .tipped18: return "毛尖色"
        case .shaded14: return "阴影色" 
        case .smoke12: return "烟色"
        case .tabby: return "斑纹色"
        }
    }
    
    var description: String {
        switch self {
        case .solid: return "均匀染色，整根毛发同色"
        case .tipped18: return "只染毛尖的1/8，优雅渐层"
        case .shaded14: return "只染毛尖的1/4，柔和过渡"
        case .smoke12: return "只染毛尖的1/2，烟雾效果"
        case .tabby: return "条纹挑染，斑纹效果"
        }
    }
    
    var sliderValue: Double {
        switch self {
        case .solid: return 0.0
        case .tipped18: return 0.25
        case .shaded14: return 0.5
        case .smoke12: return 0.75
        case .tabby: return 1.0
        }
    }
    
    static func fromSliderValue(_ value: Double) -> DyeingMethod {
        switch value {
        case 0.0..<0.125: return .solid
        case 0.125..<0.375: return .tipped18
        case 0.375..<0.625: return .shaded14
        case 0.625..<0.875: return .smoke12
        default: return .tabby
        }
    }
    
    // 吸附到最近的有效档位
    static func snapToNearestValue(_ value: Double) -> Double {
        let allValues = DyeingMethod.allCases.map { $0.sliderValue }
        let nearest = allValues.min { abs($0 - value) < abs($1 - value) }
        return nearest ?? 0.0
    }
}