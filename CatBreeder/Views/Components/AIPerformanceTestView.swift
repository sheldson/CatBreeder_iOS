//
//  AIPerformanceTestView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/29.
//

import SwiftUI
import Foundation

// MARK: - 性能测试数据模型
struct PerformanceTestResult {
    let testName: String
    let startTime: Date
    let endTime: Date
    let duration: TimeInterval
    let success: Bool
    let errorMessage: String?
    let details: [String: Any]
    
    var formattedDuration: String {
        return String(format: "%.2f秒", duration)
    }
}

struct FlowPerformanceResult {
    let totalDuration: TimeInterval
    let steps: [StepPerformance]
    let success: Bool
    let errorMessage: String?
}

struct StepPerformance {
    let stepName: String
    let duration: TimeInterval
    let percentage: Double
    let success: Bool
    let details: String?
}

// MARK: - AI性能测试视图
struct AIPerformanceTestView: View {
    @ObservedObject private var imageGenerator = ImageGenerator.shared
    @ObservedObject private var apiService = PoeAPIService.shared
    @ObservedObject private var performanceAnalyzer = PerformanceAnalyzer.shared
    
    private let promptOptimizer = PromptOptimizer.shared
    private let descriptionGenerator = CatDescriptionGenerator.shared
    
    @State private var testResults: [PerformanceTestResult] = []
    @State private var flowResult: FlowPerformanceResult?
    @State private var analysisReport: PerformanceAnalysisReport?
    @State private var isRunningTest = false
    @State private var currentTestName = ""
    @State private var testCat: Cat
    @State private var selectedTestType = 0
    
    init() {
        // 创建一个复杂的测试猫咪
        let genetics = GeneticsData(
            sex: .female,
            baseColor: .red,
            dilution: .dilute,
            pattern: .calico,
            white: WhitePattern(distribution: .bicolor, percentage: 35.0),
            modifiers: [.golden, .silver]
        )
        _testCat = State(initialValue: Cat(genetics: genetics))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // API模式切换
                    APIModeToggle()
                    
                    // 测试类型选择
                    TestTypeSelector(selectedType: $selectedTestType)
                    
                    // 测试猫咪预览
                    TestCatPreview(cat: testCat) {
                        generateNewTestCat()
                    }
                    
                    // 测试控制按钮
                    TestControlButtons(
                        isRunning: isRunningTest,
                        currentTest: currentTestName,
                        onStartTest: startSelectedTest,
                        onStartFullFlow: startFullFlowTest,
                        onStartAnalysis: startPerformanceAnalysis,
                        onClearResults: clearResults
                    )
                    
                    // 性能分析报告
                    if let report = analysisReport {
                        PerformanceAnalysisReportView(report: report)
                    }
                    
                    // 完整流程结果
                    if let flowResult = flowResult {
                        FullFlowResultView(result: flowResult)
                    }
                    
                    // 单项测试结果
                    if !testResults.isEmpty {
                        IndividualTestResultsView(results: testResults)
                    }
                }
                .padding()
            }
            .navigationTitle("AI性能测试")
        }
    }
    
    // MARK: - 测试方法
    
    private func startSelectedTest() {
        switch selectedTestType {
        case 0: startDescriptionTest()
        case 1: startPromptOptimizationTest()
        case 2: startImageGenerationTest()
        case 3: startAPIConnectionTest()
        default: break
        }
    }
    
    private func startDescriptionTest() {
        Task {
            await performTest(name: "猫咪描述生成测试") {
                // 测试描述生成器性能
                let startTime = Date()
                
                let fullDesc = descriptionGenerator.generateDescription(for: testCat)
                let simpleDesc = descriptionGenerator.generateSimpleDescription(for: testCat)
                let keywords = descriptionGenerator.generateAIPromptKeywords(for: testCat)
                
                let endTime = Date()
                
                return [
                    "full_description_length": fullDesc.count,
                    "simple_description_length": simpleDesc.count,
                    "keywords_count": keywords.count,
                    "full_description": fullDesc.prefix(50) + "...",
                    "processing_time": endTime.timeIntervalSince(startTime)
                ]
            }
        }
    }
    
    private func startPromptOptimizationTest() {
        Task {
            await performTest(name: "Prompt优化测试") {
                let startTime = Date()
                
                let optimizedPrompt = try await promptOptimizer.optimizeForAIArt(cat: testCat)
                
                let endTime = Date()
                
                return [
                    "optimized_prompt_length": optimizedPrompt.count,
                    "prompt_preview": optimizedPrompt.prefix(100) + "...",
                    "api_call_time": endTime.timeIntervalSince(startTime)
                ]
            }
        }
    }
    
    private func startImageGenerationTest() {
        Task {
            await performTest(name: "图片生成测试") {
                let startTime = Date()
                
                let result = try await imageGenerator.generateCatImage(
                    from: testCat,
                    style: .realistic,
                    quality: .standard
                )
                
                let endTime = Date()
                
                return [
                    "image_url": result.imageUrl,
                    "original_prompt_length": result.originalPrompt.count,
                    "final_prompt_length": result.finalPrompt.count,
                    "generation_time": endTime.timeIntervalSince(startTime)
                ]
            }
        }
    }
    
    private func startAPIConnectionTest() {
        Task {
            await performTest(name: "API连接测试") {
                let startTime = Date()
                
                let success = await apiService.testConnection()
                
                let endTime = Date()
                
                if !success {
                    throw NSError(domain: "APITest", code: 500, userInfo: [
                        NSLocalizedDescriptionKey: "API连接失败"
                    ])
                }
                
                return [
                    "connection_success": success,
                    "response_time": endTime.timeIntervalSince(startTime),
                    "api_mode": apiService.isSimulationMode ? "simulation" : "real"
                ]
            }
        }
    }
    
    private func startPerformanceAnalysis() {
        Task {
            await MainActor.run {
                isRunningTest = true
                currentTestName = "性能分析"
                analysisReport = nil
            }
            
            let report = await performanceAnalyzer.analyzeFullAIWorkflow(cat: testCat)
            
            await MainActor.run {
                analysisReport = report
                isRunningTest = false
                currentTestName = ""
            }
        }
    }
    
    private func startFullFlowTest() {
        Task {
            await MainActor.run {
                isRunningTest = true
                currentTestName = "完整流程测试"
                flowResult = nil
            }
            
            let totalStartTime = Date()
            var steps: [StepPerformance] = []
            
            do {
                // 步骤1: 描述生成 
                let step1Start = Date()
                let fullDesc = descriptionGenerator.generateDescription(for: testCat)
                let step1Duration = Date().timeIntervalSince(step1Start)
                
                // 步骤2: Prompt优化
                let step2Start = Date()
                let optimizedPrompt = try await promptOptimizer.optimizeForAIArt(cat: testCat)
                let step2Duration = Date().timeIntervalSince(step2Start)
                
                // 步骤3: 图片生成
                let step3Start = Date()
                let imageResult = try await imageGenerator.generateCatImage(
                    from: testCat,
                    style: .realistic,
                    quality: .standard
                )
                let step3Duration = Date().timeIntervalSince(step3Start)
                
                let totalDuration = Date().timeIntervalSince(totalStartTime)
                
                // 计算各步骤占比
                steps = [
                    StepPerformance(
                        stepName: "描述生成",
                        duration: step1Duration,
                        percentage: (step1Duration / totalDuration) * 100,
                        success: true,
                        details: "生成 \(fullDesc.count) 字符描述"
                    ),
                    StepPerformance(
                        stepName: "Prompt优化",
                        duration: step2Duration,
                        percentage: (step2Duration / totalDuration) * 100,
                        success: true,
                        details: "优化后长度 \(optimizedPrompt.count) 字符"
                    ),
                    StepPerformance(
                        stepName: "图片生成",
                        duration: step3Duration,
                        percentage: (step3Duration / totalDuration) * 100,
                        success: true,
                        details: "生成图片URL: \(imageResult.imageUrl.prefix(30))..."
                    )
                ]
                
                await MainActor.run {
                    flowResult = FlowPerformanceResult(
                        totalDuration: totalDuration,
                        steps: steps,
                        success: true,
                        errorMessage: nil
                    )
                    isRunningTest = false
                    currentTestName = ""
                }
                
            } catch {
                let totalDuration = Date().timeIntervalSince(totalStartTime)
                await MainActor.run {
                    flowResult = FlowPerformanceResult(
                        totalDuration: totalDuration,
                        steps: steps,
                        success: false,
                        errorMessage: error.localizedDescription
                    )
                    isRunningTest = false
                    currentTestName = ""
                }
            }
        }
    }
    
    // MARK: - 辅助方法
    
    private func performTest(name: String, operation: @escaping () async throws -> [String: Any]) async {
        await MainActor.run {
            isRunningTest = true
            currentTestName = name
        }
        
        let startTime = Date()
        
        do {
            let details = try await operation()
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            let result = PerformanceTestResult(
                testName: name,
                startTime: startTime,
                endTime: endTime,
                duration: duration,
                success: true,
                errorMessage: nil,
                details: details
            )
            
            await MainActor.run {
                testResults.append(result)
                isRunningTest = false
                currentTestName = ""
            }
            
        } catch {
            let endTime = Date()
            let duration = endTime.timeIntervalSince(startTime)
            
            let result = PerformanceTestResult(
                testName: name,
                startTime: startTime,
                endTime: endTime,
                duration: duration,
                success: false,
                errorMessage: error.localizedDescription,
                details: [:]
            )
            
            await MainActor.run {
                testResults.append(result)
                isRunningTest = false
                currentTestName = ""
            }
        }
    }
    
    private func generateNewTestCat() {
        let newGenetics = GeneticsData.random()
        testCat = Cat(genetics: newGenetics)
        clearResults()
    }
    
    private func clearResults() {
        testResults.removeAll()
        flowResult = nil
        analysisReport = nil
    }
}

// MARK: - 子组件

struct TestTypeSelector: View {
    @Binding var selectedType: Int
    
    private let testTypes = [
        "描述生成", "Prompt优化", "图片生成", "API连接"
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("选择单项测试")
                .font(.headline)
            
            Picker("测试类型", selection: $selectedType) {
                ForEach(0..<testTypes.count, id: \.self) { index in
                    Text(testTypes[index]).tag(index)
                }
            }
            .pickerStyle(.segmented)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct TestCatPreview: View {
    let cat: Cat
    let onNewCat: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🧪 测试猫咪")
                .font(.headline)
            
            CatCardView(cat: cat, size: .medium)
            
            HStack {
                Text("稀有度: \(cat.rarity.rawValue)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button("重新生成", action: onNewCat)
                    .buttonStyle(.bordered)
                    .font(.caption)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct TestControlButtons: View {
    let isRunning: Bool
    let currentTest: String
    let onStartTest: () -> Void
    let onStartFullFlow: () -> Void
    let onStartAnalysis: () -> Void
    let onClearResults: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            if isRunning {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("正在运行: \(currentTest)")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.blue.opacity(0.1))
                )
            } else {
                VStack(spacing: 8) {
                    HStack(spacing: 12) {
                        Button("单项测试", action: onStartTest)
                            .buttonStyle(.borderedProminent)
                        
                        Button("完整流程", action: onStartFullFlow)
                            .buttonStyle(.borderedProminent)
                            .tint(.green)
                    }
                    
                    HStack(spacing: 12) {
                        Button("性能分析", action: onStartAnalysis)
                            .buttonStyle(.borderedProminent)
                            .tint(.orange)
                        
                        Button("清除结果", action: onClearResults)
                            .buttonStyle(.bordered)
                    }
                }
            }
        }
    }
}

struct FullFlowResultView: View {
    let result: FlowPerformanceResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundColor(result.success ? .green : .red)
                Text("完整流程测试")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.2f秒", result.totalDuration))
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(result.success ? .green : .red)
            }
            
            if result.success {
                VStack(spacing: 8) {
                    ForEach(result.steps.indices, id: \.self) { index in
                        let step = result.steps[index]
                        StepPerformanceRow(step: step)
                    }
                }
            }
            
            if let error = result.errorMessage {
                Text("错误: \(error)")
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(8)
                    .background(.red.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct StepPerformanceRow: View {
    let step: StepPerformance
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    Text(step.stepName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                    Text(String(format: "%.2f秒", step.duration))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("(\(String(format: "%.1f", step.percentage))%)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let details = step.details {
                    Text(details)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 进度条
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 2)
                            .fill(.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        RoundedRectangle(cornerRadius: 2)
                            .fill(step.success ? .blue : .red)
                            .frame(width: geometry.size.width * (step.percentage / 100), height: 4)
                    }
                }
                .frame(height: 4)
            }
        }
    }
}

struct IndividualTestResultsView: View {
    let results: [PerformanceTestResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("测试记录")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVStack(spacing: 8) {
                ForEach(results.indices, id: \.self) { index in
                    let result = results[index]
                    IndividualTestRow(result: result)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct IndividualTestRow: View {
    let result: PerformanceTestResult
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: { isExpanded.toggle() }) {
                HStack {
                    Image(systemName: result.success ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .foregroundColor(result.success ? .green : .red)
                    
                    Text(result.testName)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Spacer()
                    
                    Text(result.formattedDuration)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(result.success ? .green : .red)
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    Text("开始时间: \(DateFormatter.localizedString(from: result.startTime, dateStyle: .none, timeStyle: .medium))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    if result.success {
                        ForEach(Array(result.details.keys.sorted()), id: \.self) { key in
                            if let value = result.details[key] {
                                Text("\(key): \(String(describing: value))")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    } else {
                        Text("错误: \(result.errorMessage ?? "未知错误")")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.1))
        )
    }
}

// MARK: - 性能分析报告视图
struct PerformanceAnalysisReportView: View {
    let report: PerformanceAnalysisReport
    @State private var selectedDetailIndex: Int?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 报告头部
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .foregroundColor(.orange)
                Text("性能分析报告")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                VStack(alignment: .trailing) {
                    Text(report.formattedTotalDuration)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("效率: \(report.efficiencyRating)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            // 测试猫咪信息
            HStack {
                Text("测试对象:")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text("\(report.testCat.genetics.baseColor.rawValue)\(report.testCat.genetics.sex.rawValue) (\(report.testCat.rarity.rawValue))")
                    .font(.caption)
                    .fontWeight(.medium)
                Spacer()
                Text(DateFormatter.localizedString(from: report.analysisDate, dateStyle: .none, timeStyle: .short))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 步骤性能分解
            VStack(alignment: .leading, spacing: 8) {
                Text("性能分解")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                ForEach(report.steps.indices, id: \.self) { index in
                    let step = report.steps[index]
                    Button(action: {
                        selectedDetailIndex = (selectedDetailIndex == index) ? nil : index
                    }) {
                        PerformanceStepRow(
                            step: step,
                            isExpanded: selectedDetailIndex == index
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // 主要瓶颈
            if !report.majorBottlenecks.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("主要瓶颈")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(report.majorBottlenecks, id: \.self) { bottleneck in
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(.orange)
                                .font(.caption)
                            Text(bottleneck)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(8)
                .background(.orange.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
            
            // 优化建议
            if !report.recommendations.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("优化建议")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    
                    ForEach(report.recommendations, id: \.self) { recommendation in
                        Text(recommendation)
                            .font(.caption)
                            .foregroundColor(.blue)
                    }
                }
                .padding(8)
                .background(.blue.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct PerformanceStepRow: View {
    let step: StepPerformanceData
    let isExpanded: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(step.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    // 进度条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.blue)
                                .frame(width: geometry.size.width * (step.percentage / 100), height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Text(String(format: "%.2f秒", step.duration))
                        .font(.subheadline)
                        .fontWeight(.semibold)
                    Text("\(String(format: "%.1f", step.percentage))%")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 4) {
                    // 操作详情
                    if !step.operations.isEmpty {
                        Text("详细操作:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.secondary)
                        
                        ForEach(step.operations.indices, id: \.self) { opIndex in
                            let (name, duration) = step.operations[opIndex]
                            HStack {
                                Text("• \(name)")
                                    .font(.caption)
                                Spacer()
                                Text(String(format: "%.4f秒", duration))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // 瓶颈信息
                    if !step.bottlenecks.isEmpty {
                        Text("瓶颈分析:")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.orange)
                        
                        ForEach(step.bottlenecks, id: \.self) { bottleneck in
                            Text("• \(bottleneck)")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 12)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.gray.opacity(0.1))
        )
    }
}

#Preview {
    AIPerformanceTestView()
}