//
//  BreedingSummary.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation

// MARK: - 合成汇总信息
struct BreedingSummary {
    let predictedBreed: CatBreed
    let detailedColorDescription: String
    let stepByStepChoices: [StepChoice]
    let rarityExplanation: String
    let eyeColorResult: EyeColor
    let specialFeatures: [String]
    
    // 每一步的选择记录
    struct StepChoice {
        let stepNumber: Int
        let stepName: String
        let choice: String
        let description: String
    }
    
    // 生成详细的颜色描述
    static func generateDetailedColorDescription(
        chromosomes: [BaseColor],
        dilutionLevel: Double,
        dyeingMethod: DyeingMethod,
        tabbySubtype: TabbySubtype?,
        patternCoverage: Double,
        whitePercentage: Double,
        whiteAreas: Set<WhiteArea>,
        temperatureEffect: TemperatureEffect?,
        affectedParts: Set<BodyPart>,
        temperatureIntensity: Double
    ) -> String {
        var description = ""
        
        // 基础颜色
        if chromosomes.count == 1 {
            description += "单一\(chromosomes[0].rawValue)基因"
        } else if chromosomes.count == 2 {
            let first = chromosomes[0]
            let second = chromosomes[1]
            if first == second {
                description += "双重\(first.rawValue)基因"
            } else {
                description += "\(first.rawValue)与\(second.rawValue)混合基因"
            }
        }
        
        // 稀释效果
        if dilutionLevel > 0.1 {
            let dilutionPercent = Int(dilutionLevel * 100)
            description += "，\(dilutionPercent)%稀释"
            description += "（\(ColorInterpolator.getDilutionDescription(dilutionLevel: dilutionLevel))）"
        }
        
        // 染色方法
        description += "，采用\(dyeingMethod.name)工艺"
        
        // 斑纹信息
        if let tabby = tabbySubtype, tabby != .none {
            let coveragePercent = Int(patternCoverage * 100)
            description += "，\(tabby.rawValue)纹理（\(coveragePercent)%覆盖度）"
        } else {
            description += "，无斑纹纯色"
        }
        
        // 身体白色分布
        let bodyWhiteLevel = BodyWhiteLevel.fromPercentage(whitePercentage)
        if bodyWhiteLevel != .none {
            description += "，身体\(bodyWhiteLevel.name)"
        }
        
        // 面部白斑（独立）
        if !whiteAreas.isEmpty {
            let areaNames = whiteAreas.map { $0.rawValue }.joined(separator: "、")
            if bodyWhiteLevel != .none {
                description += "，面部白斑（\(areaNames)）"
            } else {
                description += "，面部白斑分布于\(areaNames)"
            }
        }
        
        // 温度敏感效果
        if let effect = temperatureEffect, !affectedParts.isEmpty {
            let intensityPercent = Int(temperatureIntensity * 100)
            let partNames = affectedParts.map { $0.rawValue }.joined(separator: "、")
            description += "，\(effect.rawValue)（\(partNames)，\(intensityPercent)%强度）"
        }
        
        return description
    }
    
    // 创建完整的合成汇总
    static func create(from state: BreedingState) -> BreedingSummary {
        // 预测品种
        let predictedBreed = CatBreed.predictBreed(
            sex: state.selectedSex,
            chromosomes: state.chromosomes,
            dilutionLevel: state.dilutionLevel,
            tabbySubtype: state.selectedTabbySubtype,
            whitePercentage: state.bodyWhiteLevel,
            temperatureEffect: state.selectedTemperatureEffect
        )
        
        // 生成详细颜色描述
        let detailedColorDescription = generateDetailedColorDescription(
            chromosomes: state.chromosomes,
            dilutionLevel: state.dilutionLevel,
            dyeingMethod: DyeingMethod.fromSliderValue(state.dyeingMethodLevel),
            tabbySubtype: state.selectedTabbySubtype,
            patternCoverage: state.patternCoverage,
            whitePercentage: state.bodyWhiteLevel,
            whiteAreas: state.selectedFaceWhiteAreas,
            temperatureEffect: state.selectedTemperatureEffect,
            affectedParts: state.selectedBodyParts,
            temperatureIntensity: state.temperatureIntensity
        )
        
        // 记录每一步的选择
        var stepChoices: [StepChoice] = []
        
        // 步骤1
        if let sex = state.selectedSex {
            let chromosomeDesc = state.chromosomes.map { $0.rawValue }.joined(separator: "+")
            stepChoices.append(StepChoice(
                stepNumber: 1,
                stepName: "性别与染色体",
                choice: "\(sex.rawValue)\(state.isXXY ? "(XXY)" : "")",
                description: "抽取到\(chromosomeDesc)染色体"
            ))
        }
        
        // 步骤2
        let dyeingMethod = DyeingMethod.fromSliderValue(state.dyeingMethodLevel)
        stepChoices.append(StepChoice(
            stepNumber: 2,
            stepName: "稀释与染色",
            choice: "\(Int(state.dilutionLevel * 100))%稀释 + \(dyeingMethod.name)",
            description: "\(ColorInterpolator.getDilutionDescription(dilutionLevel: state.dilutionLevel))，\(dyeingMethod.description)"
        ))
        
        // 步骤3
        if let tabby = state.selectedTabbySubtype {
            stepChoices.append(StepChoice(
                stepNumber: 3,
                stepName: "斑纹选择",
                choice: tabby.rawValue,
                description: "\(tabby.description)，\(Int(state.patternCoverage * 100))%覆盖度"
            ))
        }
        
        // 步骤4
        let bodyLevel = BodyWhiteLevel.fromPercentage(state.bodyWhiteLevel)
        let faceAreasDesc = state.selectedFaceWhiteAreas.map { $0.rawValue }.joined(separator: "、")
        var step4Description = "身体：\(bodyLevel.name)"
        if !state.selectedFaceWhiteAreas.isEmpty {
            step4Description += "，面部：\(faceAreasDesc)"
        }
        stepChoices.append(StepChoice(
            stepNumber: 4,
            stepName: "加白设置",
            choice: bodyLevel == .none && state.selectedFaceWhiteAreas.isEmpty ? "无白色" : "复合白色",
            description: step4Description
        ))
        
        // 步骤5（如果有）
        if let effect = state.selectedTemperatureEffect {
            let partNames = state.selectedBodyParts.map { $0.rawValue }.joined(separator: "、")
            stepChoices.append(StepChoice(
                stepNumber: 5,
                stepName: "温度敏感调色",
                choice: effect.rawValue,
                description: "\(partNames)，\(Int(state.temperatureIntensity * 100))%强度"
            ))
        }
        
        // 随机生成眼睛颜色
        let eyeColorResult = EyeColor.allCases.randomElement() ?? .copper
        
        // 生成稀有度解释
        let rarityExplanation = generateRarityExplanation(from: state)
        
        // 生成特殊特征
        let specialFeatures = generateSpecialFeatures(from: state)
        
        return BreedingSummary(
            predictedBreed: predictedBreed,
            detailedColorDescription: detailedColorDescription,
            stepByStepChoices: stepChoices,
            rarityExplanation: rarityExplanation,
            eyeColorResult: eyeColorResult,
            specialFeatures: specialFeatures
        )
    }
    
    // 生成稀有度解释
    private static func generateRarityExplanation(from state: BreedingState) -> String {
        var factors: [String] = []
        
        if state.dilutionLevel > 0.5 {
            factors.append("稀释基因变异")
        }
        
        if let tabby = state.selectedTabbySubtype, tabby != .none && tabby != .mackerel {
            factors.append("特殊斑纹类型")
        }
        
        if state.bodyWhiteLevel > 0.6 {
            factors.append("高身体白色分布")
        }
        
        if state.selectedTemperatureEffect != nil {
            factors.append("温度敏感基因")
        }
        
        if state.isXXY {
            factors.append("XXY染色体异常")
        }
        
        if factors.isEmpty {
            return "标准基因组合，常见特征"
        } else {
            return "稀有因素：" + factors.joined(separator: "、")
        }
    }
    
    // 生成特殊特征
    private static func generateSpecialFeatures(from state: BreedingState) -> [String] {
        var features: [String] = []
        
        if state.isXXY {
            features.append("🧬 XXY超稀有染色体")
        }
        
        if state.isOrangeCat() {
            features.append("🍊 橘猫基因（必带斑纹）")
        }
        
        if state.dilutionLevel > 0.8 {
            features.append("💧 极度稀释变异")
        }
        
        if state.bodyWhiteLevel > 0.8 {
            features.append("⚪ 近乎全白基因")
        }
        
        if let tabby = state.selectedTabbySubtype, tabby == .ticked {
            features.append("🎋 野生型斑纹基因")
        }
        
        if state.selectedTemperatureEffect == .darken {
            features.append("❄️ 重点色温敏基因")
        }
        
        return features
    }
}