//
//  CatBreed.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

enum CatBreed: String, CaseIterable {
    case britishShorthair = "英国短毛猫"
    case americanShorthair = "美国短毛猫"
    case persianCat = "波斯猫"
    case siameseCat = "暹罗猫"
    case maineCoon = "缅因猫"
    case ragdoll = "布偶猫"
    case russianBlue = "俄罗斯蓝猫"
    case norwegianForest = "挪威森林猫"
    case scottishFold = "苏格兰折耳猫"
    case abyssinian = "阿比西尼亚猫"
    case mixedBreed = "混血猫"
    
    var description: String {
        switch self {
        case .britishShorthair: return "圆脸短毛，温和性格"
        case .americanShorthair: return "活泼健康，适应力强"
        case .persianCat: return "长毛优雅，温柔安静"
        case .siameseCat: return "重点色系，聪明活跃"
        case .maineCoon: return "大型长毛，友善温顺"
        case .ragdoll: return "蓝眼长毛，性格温和"
        case .russianBlue: return "蓝灰短毛，安静优雅"
        case .norwegianForest: return "厚毛御寒，独立坚强"
        case .scottishFold: return "折耳圆脸，性格甜美"
        case .abyssinian: return "野性外观，活泼好奇"
        case .mixedBreed: return "血统混合，特征多样"
        }
    }
    
    var emoji: String {
        switch self {
        case .britishShorthair: return "🇬🇧"
        case .americanShorthair: return "🇺🇸"
        case .persianCat: return "🇮🇷"
        case .siameseCat: return "🇹🇭"
        case .maineCoon: return "🦁"
        case .ragdoll: return "🧸"
        case .russianBlue: return "🇷🇺"
        case .norwegianForest: return "🇳🇴"
        case .scottishFold: return "🏴󠁧󠁢󠁳󠁣󠁴󠁿"
        case .abyssinian: return "🇪🇹"
        case .mixedBreed: return "🌍"
        }
    }
    
    // 根据基因特征推测品种
    static func predictBreed(
        sex: Sex?,
        chromosomes: [BaseColor],
        dilutionLevel: Double,
        tabbySubtype: TabbySubtype?,
        whitePercentage: Double,
        temperatureEffect: TemperatureEffect?
    ) -> CatBreed {
        
        // 暹罗猫特征：重点色（温度敏感变深）
        if let effect = temperatureEffect, effect == .darken {
            return .siameseCat
        }
        
        // 俄罗斯蓝猫：稀释的黑色，无斑纹
        if chromosomes.contains(.black) && dilutionLevel > 0.7 && tabbySubtype == TabbySubtype.none {
            return .russianBlue
        }
        
        // 布偶猫：高白色比例，蓝眼基因
        if whitePercentage > 0.6 {
            return .ragdoll
        }
        
        // 缅因猫：虎斑纹，大体型特征
        if let tabby = tabbySubtype, tabby == .mackerel || tabby == .classic {
            return .maineCoon
        }
        
        // 波斯猫：纯色，优雅特征
        if tabbySubtype == TabbySubtype.none && dilutionLevel < 0.3 {
            return .persianCat
        }
        
        // 阿比西尼亚猫：细斑纹特征
        if tabbySubtype == .ticked {
            return .abyssinian
        }
        
        // 美国短毛猫：经典斑纹
        if tabbySubtype == .classic {
            return .americanShorthair
        }
        
        // 英国短毛猫：纯色或轻微斑纹
        if chromosomes.contains(.black) && dilutionLevel < 0.5 {
            return .britishShorthair
        }
        
        // 挪威森林猫：复杂特征组合
        if whitePercentage > 0.3 && whitePercentage < 0.6 {
            return .norwegianForest
        }
        
        // 默认为混血猫
        return .mixedBreed
    }
}