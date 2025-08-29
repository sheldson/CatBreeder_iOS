#!/usr/bin/swift
//
// AI性能测试模拟器
// 用于模拟测试AI流程的各个步骤性能
//

import Foundation

// 模拟性能数据
struct SimulatedPerformanceData {
    let stepName: String
    let baseTime: TimeInterval
    let variance: TimeInterval
    let subOperations: [(String, TimeInterval, TimeInterval)]
    
    func simulateExecution() -> (TimeInterval, [(String, TimeInterval)]) {
        let randomVariance = Double.random(in: -variance...variance)
        let totalTime = baseTime + randomVariance
        
        var operations: [(String, TimeInterval)] = []
        var accumulatedTime: TimeInterval = 0
        
        for (opName, opBaseTime, opVariance) in subOperations {
            let opRandomVariance = Double.random(in: -opVariance...opVariance)
            let opTime = opBaseTime + opRandomVariance
            operations.append((opName, opTime))
            accumulatedTime += opTime
        }
        
        // 确保总时间合理
        let adjustedTotalTime = max(totalTime, accumulatedTime)
        return (adjustedTotalTime, operations)
    }
}

// 性能测试模拟器
class PerformanceTestSimulator {
    
    // 模拟步骤数据
    private let stepData: [SimulatedPerformanceData] = [
        // 步骤1: 描述生成 (本地处理，很快)
        SimulatedPerformanceData(
            stepName: "描述生成",
            baseTime: 0.05,
            variance: 0.02,
            subOperations: [
                ("完整描述生成", 0.015, 0.005),
                ("简化描述生成", 0.008, 0.003),
                ("AI关键词提取", 0.012, 0.004),
                ("预设模板生成", 0.010, 0.003)
            ]
        ),
        
        // 步骤2: Prompt优化 (网络API调用)
        SimulatedPerformanceData(
            stepName: "Prompt优化",
            baseTime: 8.5,
            variance: 3.0,
            subOperations: [
                ("构建优化请求", 0.02, 0.01),
                ("GPT-4o API调用", 7.8, 2.5),
                ("结果清理格式化", 0.15, 0.05),
                ("提取最终prompt", 0.08, 0.03)
            ]
        ),
        
        // 步骤3: 图片生成 (最大瓶颈)
        SimulatedPerformanceData(
            stepName: "图片生成",
            baseTime: 18.0,
            variance: 8.0,
            subOperations: [
                ("构建最终prompt", 0.08, 0.02),
                ("POE API调用", 15.5, 7.0),
                ("图片URL提取", 0.5, 0.2),
                ("结果处理验证", 0.3, 0.1),
                ("重试处理(如需要)", 1.2, 1.0)
            ]
        )
    ]
    
    func runPerformanceSimulation(iterations: Int = 5) {
        print("🔬 AI流程性能模拟测试")
        print("=" * 50)
        print("模拟迭代次数: \(iterations)")
        print()
        
        var allResults: [(TimeInterval, [String: (TimeInterval, [(String, TimeInterval)])])] = []
        
        for iteration in 1...iterations {
            print("📊 迭代 \(iteration)/\(iterations)")
            
            let startTime = Date()
            var stepResults: [String: (TimeInterval, [(String, TimeInterval)])] = [:]
            
            for stepData in self.stepData {
                let (stepTime, operations) = stepData.simulateExecution()
                stepResults[stepData.stepName] = (stepTime, operations)
                
                print("  \(stepData.stepName): \(String(format: "%.2f", stepTime))秒")
                for (opName, opTime) in operations {
                    print("    └─ \(opName): \(String(format: "%.4f", opTime))秒")
                }
            }
            
            let totalTime = stepResults.values.map { $0.0 }.reduce(0, +)
            allResults.append((totalTime, stepResults))
            
            print("  总耗时: \(String(format: "%.2f", totalTime))秒")
            print()
        }
        
        // 分析结果
        analyzeResults(allResults)
    }
    
    private func analyzeResults(_ results: [(TimeInterval, [String: (TimeInterval, [(String, TimeInterval)])])]) {
        print("📈 性能分析报告")
        print("=" * 50)
        
        let totalTimes = results.map { $0.0 }
        let avgTotal = totalTimes.reduce(0, +) / Double(totalTimes.count)
        let minTotal = totalTimes.min() ?? 0
        let maxTotal = totalTimes.max() ?? 0
        
        print("总体性能:")
        print("  平均总耗时: \(String(format: "%.2f", avgTotal))秒")
        print("  最快: \(String(format: "%.2f", minTotal))秒")
        print("  最慢: \(String(format: "%.2f", maxTotal))秒")
        print("  变化范围: \(String(format: "%.2f", maxTotal - minTotal))秒")
        print()
        
        // 各步骤分析
        for stepData in self.stepData {
            let stepName = stepData.stepName
            let stepTimes = results.compactMap { $0.1[stepName]?.0 }
            
            if !stepTimes.isEmpty {
                let avgStepTime = stepTimes.reduce(0, +) / Double(stepTimes.count)
                let minStepTime = stepTimes.min() ?? 0
                let maxStepTime = stepTimes.max() ?? 0
                let percentage = (avgStepTime / avgTotal) * 100
                
                print("\(stepName):")
                print("  平均耗时: \(String(format: "%.2f", avgStepTime))秒 (\(String(format: "%.1f", percentage))%)")
                print("  范围: \(String(format: "%.2f", minStepTime))秒 - \(String(format: "%.2f", maxStepTime))秒")
                
                // 瓶颈识别
                if percentage > 60 {
                    print("  🔴 主要瓶颈 - 需优先优化")
                } else if percentage > 25 {
                    print("  🟡 次要瓶颈 - 可考虑优化")
                } else {
                    print("  🟢 性能良好")
                }
                print()
            }
        }
        
        // 生成优化建议
        generateOptimizationRecommendations(avgTotal, results)
    }
    
    private func generateOptimizationRecommendations(_ avgTotal: TimeInterval, _ results: [(TimeInterval, [String: (TimeInterval, [(String, TimeInterval)])])]) {
        print("💡 优化建议")
        print("=" * 50)
        
        // 基于总耗时的建议
        if avgTotal > 30 {
            print("🔥 总耗时过长(\(String(format: "%.1f", avgTotal))秒)，急需优化:")
            print("   • 实施aggressive缓存策略")
            print("   • 考虑预计算常用组合")
            print("   • 添加取消机制")
        } else if avgTotal > 15 {
            print("⚡ 耗时较长(\(String(format: "%.1f", avgTotal))秒)，建议优化:")
            print("   • 添加intelligent缓存")
            print("   • 异步预加载热门特征")
        } else {
            print("✅ 总体性能良好(\(String(format: "%.1f", avgTotal))秒)")
        }
        print()
        
        // 基于各步骤的具体建议
        let avgResults = calculateAverageStepTimes(results)
        
        for (stepName, avgTime) in avgResults {
            let percentage = (avgTime / avgTotal) * 100
            
            switch stepName {
            case "描述生成":
                if avgTime > 0.2 {
                    print("📝 描述生成优化:")
                    print("   • 添加描述缓存")
                    print("   • 预计算常见组合")
                }
                
            case "Prompt优化":
                if avgTime > 10 {
                    print("🧠 Prompt优化建议:")
                    print("   • 实施prompt模板库")
                    print("   • 减少API调用频率")
                    print("   • 考虑使用更快的模型")
                } else if avgTime > 5 {
                    print("🧠 Prompt优化建议:")
                    print("   • 添加智能缓存")
                    print("   • 批量处理相似请求")
                }
                
            case "图片生成":
                if avgTime > 25 {
                    print("🖼️ 图片生成优化:")
                    print("   • 优化重试策略")
                    print("   • 实施超时限制")
                    print("   • 考虑多API provider负载均衡")
                } else if avgTime > 15 {
                    print("🖼️ 图片生成建议:")
                    print("   • 添加进度指示")
                    print("   • 允许用户取消")
                }
                
            default:
                break
            }
        }
        
        // 通用建议
        print()
        print("🎯 通用优化策略:")
        print("   • 智能缓存: 相似猫咪特征结果复用")
        print("   • 异步处理: 长操作不阻塞UI")
        print("   • 进度反馈: 实时显示处理状态")
        print("   • 降级策略: 网络问题时的备选方案")
        print("   • 预设模板: 常用组合快速生成")
    }
    
    private func calculateAverageStepTimes(_ results: [(TimeInterval, [String: (TimeInterval, [(String, TimeInterval)])])]) -> [String: TimeInterval] {
        var stepTotals: [String: TimeInterval] = [:]
        var stepCounts: [String: Int] = [:]
        
        for (_, stepResults) in results {
            for (stepName, (stepTime, _)) in stepResults {
                stepTotals[stepName, default: 0] += stepTime
                stepCounts[stepName, default: 0] += 1
            }
        }
        
        var averages: [String: TimeInterval] = [:]
        for (stepName, total) in stepTotals {
            if let count = stepCounts[stepName], count > 0 {
                averages[stepName] = total / Double(count)
            }
        }
        
        return averages
    }
}

// 扩展字符串重复功能
extension String {
    static func * (left: String, right: Int) -> String {
        return String(repeating: left, count: right)
    }
}

// 运行模拟
let simulator = PerformanceTestSimulator()
simulator.runPerformanceSimulation(iterations: 3)