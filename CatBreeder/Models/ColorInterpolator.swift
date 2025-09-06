//
//  ColorInterpolator.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

// MARK: - 颜色插值工具
struct ColorInterpolator {
    // 在原色和稀释色之间进行线性插值
    static func interpolateColor(baseColor: BaseColor, dilutionLevel: Double) -> String {
        let clampedLevel = max(0.0, min(1.0, dilutionLevel))
        
        let originalHex = baseColor.hexColor
        let dilutedHex = Dilution.dilute.apply(to: baseColor)
        
        return interpolateHexColors(from: originalHex, to: dilutedHex, ratio: clampedLevel)
    }
    
    // 十六进制颜色插值
    private static func interpolateHexColors(from: String, to: String, ratio: Double) -> String {
        let fromRGB = hexToRGB(from)
        let toRGB = hexToRGB(to)
        
        let r = Int(Double(fromRGB.r) + (Double(toRGB.r - fromRGB.r) * ratio))
        let g = Int(Double(fromRGB.g) + (Double(toRGB.g - fromRGB.g) * ratio))
        let b = Int(Double(fromRGB.b) + (Double(toRGB.b - fromRGB.b) * ratio))
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    // 十六进制转RGB
    private static func hexToRGB(_ hex: String) -> (r: Int, g: Int, b: Int) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        
        let r = Int((int >> 16) & 0xFF)
        let g = Int((int >> 8) & 0xFF)
        let b = Int(int & 0xFF)
        
        return (r, g, b)
    }
    
    // 获取稀释程度描述
    static func getDilutionDescription(dilutionLevel: Double) -> String {
        switch dilutionLevel {
        case 0.0..<0.1: return "原色浓郁"
        case 0.1..<0.3: return "轻微稀释"
        case 0.3..<0.7: return "中度稀释"
        case 0.7..<0.9: return "高度稀释"
        default: return "完全稀释"
        }
    }
    
    // 获取颜色名称
    static func getColorName(baseColor: BaseColor, dilutionLevel: Double) -> String {
        if dilutionLevel < 0.1 {
            return baseColor.rawValue
        } else {
            switch baseColor {
            case .black: return "蓝灰"
            case .chocolate: return "淡紫"
            case .cinnamon: return "米色"
            case .red: return "奶油"
            }
        }
    }
}