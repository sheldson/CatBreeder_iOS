//
//  PerformanceAnalyzer.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/29.
//

import Foundation

// MARK: - 性能分析器
class PerformanceAnalyzer: ObservableObject {
    static let shared = PerformanceAnalyzer()
    
    private init() {}
    
    // MARK: - 分析完整AI流程性能
    
    func analyzeFullAIWorkflow(cat: Cat) async -> PerformanceAnalysisReport {
        let totalStartTime = Date()
        var stepResults: [StepAnalysisResult] = []
        
        print("🔬 [PerformanceAnalyzer] 开始AI流程性能分析")
        print("🐱 [PerformanceAnalyzer] 测试猫咪: \(cat.genetics.baseColor.rawValue) \(cat.genetics.sex.rawValue)")
        print("🎯 [PerformanceAnalyzer] 稀有度: \(cat.rarity.rawValue)")
        
        // 步骤1: 描述生成分析
        let step1Result = await analyzeDescriptionGeneration(cat: cat)
        stepResults.append(step1Result)
        
        // 步骤2: Prompt优化分析
        let step2Result = await analyzePromptOptimization(cat: cat)
        stepResults.append(step2Result)
        
        // 步骤3: 图片生成分析 (模拟)
        let step3Result = await analyzeImageGeneration(cat: cat)
        stepResults.append(step3Result)
        
        let totalDuration = Date().timeIntervalSince(totalStartTime)
        
        // 生成分析报告
        let report = generateAnalysisReport(
            totalDuration: totalDuration,
            steps: stepResults,
            cat: cat
        )
        
        print("🎯 [PerformanceAnalyzer] === 性能分析完成 ===")
        print("📊 [PerformanceAnalyzer] 总耗时: \(String(format: "%.2f", totalDuration))秒")
        
        return report
    }
    
    // MARK: - 单步骤分析
    
    private func analyzeDescriptionGeneration(cat: Cat) -> StepAnalysisResult {
        let stepStartTime = Date()
        print("📝 [PerformanceAnalyzer] 步骤1: 分析描述生成性能")
        
        let descGen = CatDescriptionGenerator.shared
        
        // 测试基础描述生成
        let desc1Start = Date()
        let fullDescription = descGen.generateDescription(for: cat)
        let desc1Time = Date().timeIntervalSince(desc1Start)
        
        // 测试简化描述生成
        let desc2Start = Date()
        let simpleDescription = descGen.generateSimpleDescription(for: cat)
        let desc2Time = Date().timeIntervalSince(desc2Start)
        
        // 测试关键词生成
        let keywords1Start = Date()
        let aiKeywords = descGen.generateAIPromptKeywords(for: cat)
        let keywords1Time = Date().timeIntervalSince(keywords1Start)
        
        // 测试预设模板生成
        let preset1Start = Date()
        let presetPrompt = PromptOptimizer.shared.getPresetPromptTemplate(for: cat)
        let preset1Time = Date().timeIntervalSince(preset1Start)
        
        let totalStepTime = Date().timeIntervalSince(stepStartTime)
        
        print("✅ [PerformanceAnalyzer] 描述生成完成:")
        print("   📄 完整描述: \(String(format: "%.4f", desc1Time))秒 (\(fullDescription.count)字符)")
        print("   📝 简化描述: \(String(format: "%.4f", desc2Time))秒 (\(simpleDescription.count)字符)")
        print("   🔑 AI关键词: \(String(format: "%.4f", keywords1Time))秒 (\(aiKeywords.count)个)")
        print("   🎯 预设模板: \(String(format: "%.4f", preset1Time))秒 (\(presetPrompt.count)字符)")
        print("   ⏱️ 步骤总计: \(String(format: "%.4f", totalStepTime))秒")
        
        return StepAnalysisResult(
            stepName: "描述生成",
            duration: totalStepTime,
            operations: [
                ("完整描述生成", desc1Time),
                ("简化描述生成", desc2Time),
                ("AI关键词提取", keywords1Time),
                ("预设模板生成", preset1Time)
            ],
            metrics: [
                "full_description_length": fullDescription.count,
                "simple_description_length": simpleDescription.count,
                "ai_keywords_count": aiKeywords.count,
                "preset_template_length": presetPrompt.count
            ],
            success: true,
            bottlenecks: identifyDescriptionBottlenecks(
                fullDescTime: desc1Time,
                simpleDescTime: desc2Time,
                keywordsTime: keywords1Time,
                presetTime: preset1Time
            )
        )
    }
    
    private func analyzePromptOptimization(cat: Cat) -> StepAnalysisResult {
        return StepAnalysisResult(
            stepName: "Prompt优化 (模拟)",
            duration: 2.5, // 模拟的优化时间
            operations: [
                ("GPT-4o API调用", 2.0),
                ("结果清理", 0.3),
                ("格式化", 0.2)
            ],
            metrics: [
                "api_call_simulated": true,
                "estimated_tokens": 150,
                "optimization_type": "ai_art_prompt"
            ],
            success: true,
            bottlenecks: ["API网络延迟", "GPT-4o处理时间"]
        )
    }
    
    private func analyzeImageGeneration(cat: Cat) -> StepAnalysisResult {
        return StepAnalysisResult(
            stepName: "图片生成 (模拟)",
            duration: 15.0, // 模拟的图片生成时间
            operations: [
                ("POE API调用", 12.0),
                ("图片URL提取", 1.0),
                ("结果验证", 2.0)
            ],
            metrics: [
                "api_call_simulated": true,
                "image_size": "1024x1024",
                "retry_attempts": 0
            ],
            success: true,
            bottlenecks: ["POE API响应时间", "图片生成算法处理"]
        )
    }
    
    // MARK: - 瓶颈识别
    
    private func identifyDescriptionBottlenecks(
        fullDescTime: TimeInterval,
        simpleDescTime: TimeInterval,
        keywordsTime: TimeInterval,
        presetTime: TimeInterval
    ) -> [String] {
        var bottlenecks: [String] = []
        
        // 识别最慢的操作
        let operations = [
            ("完整描述生成", fullDescTime),
            ("简化描述生成", simpleDescTime),
            ("关键词提取", keywordsTime),
            ("预设模板", presetTime)
        ]
        
        let maxTime = operations.map { $0.1 }.max() ?? 0
        let avgTime = operations.map { $0.1 }.reduce(0, +) / Double(operations.count)
        
        for (name, time) in operations {
            if time > avgTime * 2 {
                bottlenecks.append("\(name)耗时异常 (\(String(format: "%.4f", time))秒)")
            }
        }
        
        if bottlenecks.isEmpty {
            bottlenecks.append("无明显瓶颈，性能良好")
        }
        
        return bottlenecks
    }
    
    // MARK: - 报告生成
    
    private func generateAnalysisReport(
        totalDuration: TimeInterval,
        steps: [StepAnalysisResult],
        cat: Cat
    ) -> PerformanceAnalysisReport {
        
        // 计算各步骤占比
        let stepsWithPercentage = steps.map { step in
            StepPerformanceData(
                name: step.stepName,
                duration: step.duration,
                percentage: (step.duration / totalDuration) * 100,
                operations: step.operations,
                bottlenecks: step.bottlenecks
            )
        }
        
        // 识别主要瓶颈
        let majorBottlenecks = identifyMajorBottlenecks(steps: steps)
        
        // 生成优化建议
        let recommendations = generateOptimizationRecommendations(steps: steps, totalDuration: totalDuration)
        
        return PerformanceAnalysisReport(
            testCat: cat,
            totalDuration: totalDuration,
            steps: stepsWithPercentage,
            majorBottlenecks: majorBottlenecks,
            recommendations: recommendations,
            analysisDate: Date()
        )
    }
    
    private func identifyMajorBottlenecks(steps: [StepAnalysisResult]) -> [String] {
        var bottlenecks: [String] = []
        
        // 找出耗时最长的步骤
        if let slowestStep = steps.max(by: { $0.duration < $1.duration }) {
            if slowestStep.duration > 10.0 {
                bottlenecks.append("主要瓶颈：\(slowestStep.stepName) - \(String(format: "%.1f", slowestStep.duration))秒")
            }
        }
        
        // 汇总所有步骤的瓶颈
        for step in steps {
            bottlenecks.append(contentsOf: step.bottlenecks)
        }
        
        return Array(Set(bottlenecks)) // 去重
    }
    
    private func generateOptimizationRecommendations(steps: [StepAnalysisResult], totalDuration: TimeInterval) -> [String] {
        var recommendations: [String] = []
        
        // 基于总耗时的建议
        if totalDuration > 30.0 {
            recommendations.append("🔥 总耗时过长，建议实施缓存策略")
        } else if totalDuration > 15.0 {
            recommendations.append("⚡ 耗时较长，可以考虑异步预加载")
        } else {
            recommendations.append("✅ 总体性能良好")
        }
        
        // 基于各步骤的建议
        for step in steps {
            if step.stepName.contains("描述生成") && step.duration > 0.1 {
                recommendations.append("📝 描述生成可添加缓存，减少重复计算")
            }
            
            if step.stepName.contains("Prompt优化") && step.duration > 5.0 {
                recommendations.append("🧠 考虑使用预设模板减少API调用频率")
            }
            
            if step.stepName.contains("图片生成") && step.duration > 20.0 {
                recommendations.append("🖼️ 图片生成耗时长，建议优化重试策略")
            }
        }
        
        // 添加通用优化建议
        recommendations.append("💾 实施智能缓存：相似猫咪特征的结果可复用")
        recommendations.append("⚡ 异步处理：允许用户取消长时间操作")
        recommendations.append("📊 进度指示：提供更详细的处理进度反馈")
        
        return recommendations
    }
}

// MARK: - 数据模型

struct StepAnalysisResult {
    let stepName: String
    let duration: TimeInterval
    let operations: [(String, TimeInterval)]
    let metrics: [String: Any]
    let success: Bool
    let bottlenecks: [String]
}

struct StepPerformanceData {
    let name: String
    let duration: TimeInterval
    let percentage: Double
    let operations: [(String, TimeInterval)]
    let bottlenecks: [String]
}

struct PerformanceAnalysisReport {
    let testCat: Cat
    let totalDuration: TimeInterval
    let steps: [StepPerformanceData]
    let majorBottlenecks: [String]
    let recommendations: [String]
    let analysisDate: Date
    
    var formattedTotalDuration: String {
        return String(format: "%.2f秒", totalDuration)
    }
    
    var efficiencyRating: String {
        switch totalDuration {
        case 0..<5: return "优秀"
        case 5..<15: return "良好"
        case 15..<30: return "一般"
        default: return "需优化"
        }
    }
}