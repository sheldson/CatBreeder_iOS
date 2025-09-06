//
//  StepByStepBreedingView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI
import Foundation







// MARK: - 分步骤合成界面
struct StepByStepBreedingView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 1
    @StateObject private var breedingState = BreedingState()
    @State private var isCompleted = false  // 标记是否已完成合成
    
    // 动态总步数：70%用户只有4步，30%用户有5步
    let totalSteps: Int
    
    init() {
        // 30%概率显示第5步
        self.totalSteps = Double.random(in: 0...1) < 0.3 ? 5 : 4
        print("🎯 用户获得\(totalSteps == 5 ? "完整5步" : "简化4步")体验")
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 步骤指示器（完成后不显示）
                if !isCompleted {
                    StepIndicator(currentStep: currentStep, totalSteps: totalSteps)
                }
                
                // 当前步骤内容（使用更紧凑的布局）
                currentStepView
                
                Spacer(minLength: 8)
                
                // 底部按钮区域（完成后不显示）
                if !isCompleted {
                    if currentStep == 1 {
                        // 步骤1使用内部控制，不显示外部按钮
                        Step1BottomControls(onSkip: skipToResult)
                    } else {
                        BottomControls(
                            currentStep: currentStep,
                            totalSteps: totalSteps,
                            canProceed: canProceedToNextStep,
                            isCompleted: breedingState.isCompleted,
                            onPrevious: previousStep,
                            onNext: nextStep,
                            onSkip: skipToResult,
                            onFinish: finishBreeding
                        )
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
            .navigationTitle(isCompleted ? "合成完成" : "猫咪合成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    if isCompleted {
                        Button("重新开始") {
                            restartBreeding()
                        }
                    } else {
                        Button("返回") {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - 当前步骤视图
    @ViewBuilder
    private var currentStepView: some View {
        if isCompleted {
            // 合成完成后显示结果页面
            if let cat = breedingState.finalCat {
                CompletedResultView(
                    cat: cat, 
                    breedingSummary: breedingState.breedingSummary,
                    onRestart: restartBreeding,
                    onDismiss: { dismiss() },
                    breedingState: breedingState
                )
            }
        } else {
            // 正常的步骤流程
            switch currentStep {
            case 1:
                Step1PlaceholderView(state: breedingState) {
                    nextStep() // 完成步骤1后进入步骤2
                }
            case 2:
                Step2PlaceholderView(state: breedingState)
            case 3:
                Step3PlaceholderView(state: breedingState)
            case 4:
                Step4PlaceholderView(state: breedingState)
            case 5:
                Step5PlaceholderView(state: breedingState)
            default:
                Text("未知步骤")
            }
        }
    }
    
    // MARK: - 步骤控制逻辑
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 1: return breedingState.selectedSex != nil && !breedingState.chromosomes.isEmpty
        case 2: return true // 稀释基因可选
        case 3: 
            // 橘猫必须选择斑纹，其他猫咪可选
            let timestamp = Date().timeIntervalSince1970
            let trigger = breedingState.uiRefreshTrigger  // 显式依赖触发器
            let isOrangeCat = breedingState.isOrangeCat()
            let hasSelectedTabby = breedingState.selectedTabbySubtype != nil
            let selectedTabbyType = breedingState.selectedTabbySubtype
            
            print("🔄 [\(timestamp)] canProceedToNextStep 重新计算 (trigger=\(trigger))")
            print("🐱 步骤3进度检查: 橘猫=\(isOrangeCat), 已选斑纹=\(hasSelectedTabby), 选择的类型=\(selectedTabbyType?.rawValue ?? "无")")
            
            if isOrangeCat {
                let canProceed = hasSelectedTabby && selectedTabbyType != TabbySubtype.none
                print("🍊 橘猫逻辑: 可进行下一步=\(canProceed)")
                return canProceed
            } else {
                let canProceed = hasSelectedTabby
                print("🐾 普通猫逻辑: 可进行下一步=\(canProceed)")
                return canProceed
            }
        case 4: return true // 加白可选
        case 5: return true // 温度敏感调色完全可选，不强制选择
        default: return false
        }
    }
    
    // 是否显示下一步按钮
    private var shouldShowNextButton: Bool {
        switch currentStep {
        case 1: return step1Phase == .complete // 只有完成步骤1所有子阶段才显示下一步
        default: return true
        }
    }
    
    // 获取当前步骤1的阶段
    private var step1Phase: Step1PlaceholderView.Step1Phase {
        // 从Step1PlaceholderView中获取当前阶段
        if breedingState.selectedSex == nil {
            return .sexSelection
        } else if breedingState.chromosomes.isEmpty {
            return .chromosomeExtraction
        } else {
            return .complete
        }
    }
    
    private func previousStep() {
        if currentStep > 1 {
            currentStep -= 1
        }
    }
    
    private func nextStep() {
        if currentStep < totalSteps {
            currentStep += 1
        } else {
            finishBreeding()
        }
    }
    
    private func skipToResult() {
        // 快速生成剩余步骤
        breedingState.fillRemainingStepsRandomly()
        finishBreeding()
    }
    
    private func finishBreeding() {
        // 标记合成已完成（不可逆）
        breedingState.isCompleted = true
        
        // 生成详细的合成汇总信息
        breedingState.breedingSummary = BreedingSummary.create(from: breedingState)
        
        // 根据breedingState生成最终猫咪
        let genetics = breedingState.generateFinalGenetics()
        let cat = Cat(genetics: genetics)
        breedingState.finalCat = cat
        
        // 添加到收藏
        gameData.addCat(cat)
        _ = gameData.spendCoins(50)
        
        // 切换到完成状态，显示结果页面
        isCompleted = true
        
        print("🎉 合成完成！已生成详细汇总信息，流程变为不可逆")
        print("💡 MVP集成：用户可以选择生成AI卡通头像")
    }
    
    // 重新开始合成
    private func restartBreeding() {
        // 重置所有状态
        isCompleted = false
        currentStep = 1
        breedingState.resetToInitialState()
        
        print("🔄 重新开始合成")
    }
}



// MARK: - 繁育状态管理
class BreedingState: ObservableObject {
    @Published var selectedSex: Sex?
    @Published var isXXY: Bool = false
    @Published var chromosomes: [BaseColor] = []
    @Published var dilutionLevel: Double = 0.0
    @Published var dyeingMethodLevel: Double = 0.0  // 染色方法滑块值（0.0-1.0）
    @Published var selectedPattern: Pattern?
    @Published var selectedTabbySubtype: TabbySubtype?
    @Published var patternCoverage: Double = 0.5  // 斑纹覆盖度 0-100%
    
    // 身体加白系统（从足底往上）
    @Published var bodyWhiteLevel: Double = 0.0  // 0.0-1.0，控制身体白色程度
    
    // 面部加白系统（独立）
    @Published var selectedFaceWhiteAreas: Set<WhiteArea> = []  // 面部白斑区域选择
    @Published var specialEffects: [GeneticModifier] = []
    @Published var finalCat: Cat?
    @Published var uiRefreshTrigger: Int = 0  // UI刷新触发器
    
    // 步骤5：温度敏感调色
    @Published var selectedTemperatureEffect: TemperatureEffect?
    @Published var selectedBodyParts: Set<BodyPart> = []
    @Published var temperatureIntensity: Double = 0.5  // 温度效应强度 0-1
    
    // 合成完成后的详细信息
    @Published var breedingSummary: BreedingSummary?
    @Published var isCompleted: Bool = false  // 标记合成是否已完成（不可逆）
    
    // AI图片生成相关状态 (MVP版本 - 最简设计)
    @Published var aiCartoonImage: GeneratedImage?     // 生成的卡通图片
    @Published var isGeneratingAI: Bool = false        // 生成状态
    @Published var aiGenerationError: String?          // 错误信息
    
    // 重置到初始状态
    func resetToInitialState() {
        selectedSex = nil
        isXXY = false
        chromosomes = []
        dilutionLevel = 0.0
        dyeingMethodLevel = 0.0
        selectedPattern = nil
        selectedTabbySubtype = nil
        patternCoverage = 0.5
        bodyWhiteLevel = 0.0
        selectedFaceWhiteAreas = []
        specialEffects = []
        finalCat = nil
        selectedTemperatureEffect = nil
        selectedBodyParts = []
        temperatureIntensity = 0.5
        breedingSummary = nil
        isCompleted = false
        uiRefreshTrigger = 0
        
        // 重置AI图片生成状态
        aiCartoonImage = nil
        isGeneratingAI = false
        aiGenerationError = nil
        
        print("🔄 BreedingState 已重置到初始状态")
    }
    
    // 强制触发UI刷新
    func forceUIRefresh() {
        uiRefreshTrigger += 1
        print("🔄 [BreedingState] 强制UI刷新触发: \(uiRefreshTrigger)")
    }
    
    // MVP版本：生成AI卡通图片 (固定参数)
    @MainActor
    func generateAICartoonImage() async {
        guard let cat = finalCat,
              let summary = breedingSummary else { 
            print("❌ [BreedingState] 无法生成AI图片：finalCat或breedingSummary为空")
            return 
        }
        
        print("🎨 [BreedingState] 开始基于详细合成汇总生成AI卡通图片")
        print("📋 [BreedingState] 使用合成汇总：\(summary.detailedColorDescription)")
        isGeneratingAI = true
        aiGenerationError = nil
        
        do {
            // 使用新的基于合成汇总的方法：卡通风格 + 标准质量
            let imageGenerator = ImageGenerator.shared
            let generatedImage = try await imageGenerator.generateCatImageFromSummary(
                from: summary,
                style: .cartoon,    // MVP固定：卡通风格
                quality: .standard  // MVP固定：标准质量
            )
            
            aiCartoonImage = generatedImage
            print("✅ [BreedingState] AI卡通图片生成成功")
            print("📸 [BreedingState] 图片URL: \(generatedImage.imageUrl)")
            print("🎨 [BreedingState] 设置isGeneratingAI = false")
            
        } catch {
            aiGenerationError = error.localizedDescription
            print("❌ [BreedingState] AI图片生成失败: \(error.localizedDescription)")
        }
        
        isGeneratingAI = false
    }
    
    // 检测是否为橘猫（需要强制选择斑纹）
    func isOrangeCat() -> Bool {
        guard let sex = selectedSex else { return false }
        
        switch sex {
        case .male:
            // 公猫：只要有橘色染色体就是橘猫
            return chromosomes.contains(.red)
        case .female:
            // 母猫：两条染色体都是橘色才是橘猫
            return chromosomes.filter { $0 == .red }.count == 2
        }
    }
    
    func fillRemainingStepsRandomly() {
        if selectedSex == nil {
            selectedSex = Sex.random()
        }
        if chromosomes.isEmpty {
            chromosomes = generateChromosomes(for: selectedSex!)
        }
        if selectedPattern == nil {
            selectedPattern = Pattern.random()
        }
        if selectedTabbySubtype == nil {
            // 橘猫不能选择"无斑纹"
            if isOrangeCat() {
                selectedTabbySubtype = TabbySubtype.allCases.filter { $0 != .none }.randomElement()
            } else {
                selectedTabbySubtype = TabbySubtype.random()
            }
        }
        
        // 步骤5随机设置
        if selectedTemperatureEffect == nil {
            // 30%概率应用温度效果
            if Double.random(in: 0...1) < 0.3 {
                selectedTemperatureEffect = TemperatureEffect.allCases.randomElement()
                if let effect = selectedTemperatureEffect {
                    let availableParts = effect.availableBodyParts
                    let randomCount = Int.random(in: 1...min(2, availableParts.count))
                    selectedBodyParts = Set(availableParts.shuffled().prefix(randomCount))
                    temperatureIntensity = Double.random(in: 0.3...0.8)
                }
            }
        }
    }
    
    func generateFinalGenetics() -> GeneticsData {
        let sex = selectedSex ?? Sex.random()
        let baseColor = chromosomes.first ?? BaseColor.random()
        let dilution = dilutionLevel > 0.5 ? Dilution.dilute : Dilution.dense
        let pattern = selectedPattern ?? Pattern.random()
        let white = WhitePattern(
            distribution: WhiteDistribution.random(),
            percentage: bodyWhiteLevel * 100  // 使用身体白色等级
        )
        
        return GeneticsData(
            sex: sex,
            baseColor: baseColor,
            dilution: dilution,
            pattern: pattern,
            white: white,
            modifiers: specialEffects
        )
    }
    
    private func generateChromosomes(for sex: Sex) -> [BaseColor] {
        switch sex {
        case .male:
            // 公猫一条X染色体
            return [Bool.random() ? BaseColor.black : BaseColor.red]
        case .female:
            // 母猫两条X染色体
            let first = Bool.random() ? BaseColor.black : BaseColor.red
            let second = Bool.random() ? BaseColor.black : BaseColor.red
            return [first, second]
        }
    }
}

// MARK: - 步骤指示器
struct StepIndicator: View {
    let currentStep: Int
    let totalSteps: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...totalSteps, id: \.self) { step in
                StepDot(
                    step: step,
                    currentStep: currentStep,
                    isCompleted: step < currentStep
                )
                
                if step < totalSteps {
                    StepConnector(isActive: step < currentStep)
                }
            }
        }
        .padding()
    }
}

struct StepDot: View {
    let step: Int
    let currentStep: Int
    let isCompleted: Bool
    
    private var isActive: Bool {
        step == currentStep
    }
    
    var body: some View {
        ZStack {
            Circle()
                .fill(backgroundColor)
                .frame(width: 32, height: 32)
            
            if isCompleted {
                Image(systemName: "checkmark")
                    .foregroundColor(.white)
                    .font(.caption.weight(.bold))
            } else {
                Text("\(step)")
                    .foregroundColor(textColor)
                    .font(.caption.weight(.semibold))
            }
        }
    }
    
    private var backgroundColor: Color {
        if isCompleted {
            return .green
        } else if isActive {
            return .pink
        } else {
            return .gray.opacity(0.3)
        }
    }
    
    private var textColor: Color {
        if isActive {
            return .white
        } else {
            return .gray
        }
    }
}

struct StepConnector: View {
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(isActive ? .green : .gray.opacity(0.3))
            .frame(width: 20, height: 2)
    }
}

// MARK: - 底部控制按钮
struct BottomControls: View {
    let currentStep: Int
    let totalSteps: Int
    let canProceed: Bool
    let isCompleted: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 主要操作按钮
            HStack(spacing: 16) {
                // 上一步按钮（合成完成后不显示）
                if currentStep > 1 && !isCompleted {
                    Button("上一步", action: onPrevious)
                        .buttonStyle(.bordered)
                        .frame(maxWidth: .infinity)
                }
                
                // 下一步/完成按钮
                Button(nextButtonTitle) {
                    if currentStep < totalSteps {
                        onNext()
                    } else {
                        onFinish()
                    }
                }
                .buttonStyle(.borderedProminent)
                .disabled(!canProceed)
                .frame(maxWidth: .infinity)
                .onAppear {
                    print("🎯 [BottomControls] 步骤\(currentStep) - canProceed = \(canProceed), isCompleted = \(isCompleted)")
                }
                .onChange(of: canProceed) { oldValue, newValue in
                    print("🎯 [BottomControls] 步骤\(currentStep) - canProceed 变化: \(oldValue) → \(newValue)")
                }
            }
            
            // 跳过按钮（合成完成后不显示）
            if !isCompleted {
                Button("跳过剩余步骤，直接合成", action: onSkip)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("✅ 合成已完成，无法返回修改")
                    .font(.caption)
                    .foregroundColor(.orange)
                    .padding(.top, 8)
            }
        }
        .padding()
    }
    
    private var nextButtonTitle: String {
        if currentStep < totalSteps {
            return "下一步"
        } else {
            return "完成合成"
        }
    }
}

// MARK: - 步骤1：性别和染色体选择
struct Step1PlaceholderView: View {
    @ObservedObject var state: BreedingState
    @State private var isExtracting = false
    @State private var step1Phase: Step1Phase = .sexSelection
    let onComplete: () -> Void // 完成步骤1的回调
    
    enum Step1Phase {
        case sexSelection
        case chromosomeExtraction
        case complete
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Text("步骤 1：性别选择与染色体抽取")
                .font(.title2)
                .fontWeight(.bold)
            
            // 步骤1子阶段内容
            switch step1Phase {
            case .sexSelection:
                SexSelectionPhase(onSexSelected: { sex in
                    selectSex(sex)
                    step1Phase = .chromosomeExtraction
                })
                
            case .chromosomeExtraction:
                ChromosomeExtractionPhase(
                    sex: state.selectedSex!,
                    isXXY: state.isXXY,
                    isExtracting: $isExtracting,
                    onExtract: {
                        extractChromosomes()
                    },
                    onComplete: {
                        step1Phase = .complete
                    }
                )
                
            case .complete:
                VStack(spacing: 20) {
                    ChromosomeResultView(
                        sex: state.selectedSex!,
                        chromosomes: state.chromosomes,
                        isXXY: state.isXXY
                    )
                    
                    // 完成步骤1的下一步按钮
                    Button("进入下一步") {
                        onComplete()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .animation(.easeInOut(duration: 0.3), value: step1Phase)
    }
}

// MARK: - 步骤1专用底部控件
struct Step1BottomControls: View {
    let onSkip: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 跳过按钮
            Button("跳过剩余步骤，直接合成", action: onSkip)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
    
    private func selectSex(_ sex: Sex) {
        // 这个函数移到了Step1PlaceholderView中
    }
}

// MARK: - Step1PlaceholderView的扩展函数
extension Step1PlaceholderView {
    private func selectSex(_ sex: Sex) {
        state.selectedSex = sex
        // 检查万分之一概率的XXY
        if sex == .male && Double.random(in: 0...1) < 0.0001 {
            state.isXXY = true
        }
    }
    
    private func extractChromosomes() {
        guard let sex = state.selectedSex else { return }
        
        isExtracting = true
        
        // 模拟抽取过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            state.chromosomes = generateChromosomes(for: sex, isXXY: state.isXXY)
            isExtracting = false
            
            // 直接更新步骤状态，不依赖onChange
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                step1Phase = .complete
            }
        }
    }
    
    private func generateChromosomes(for sex: Sex, isXXY: Bool) -> [BaseColor] {
        switch sex {
        case .male:
            if isXXY {
                // XXY公猫，抽两次
                let firstRandom = Double.random(in: 0...1)
                let secondRandom = Double.random(in: 0...1)
                let first = firstRandom < 0.5 ? BaseColor.black : BaseColor.red
                let second = secondRandom < 0.5 ? BaseColor.black : BaseColor.red
                print("🎲 第一次随机值: \(firstRandom)")
                print("🎲 第二次随机值: \(secondRandom)")
                print("🧬 XXY公猫抽取结果: \(first.rawValue) + \(second.rawValue)")
                return [first, second]
            } else {
                // 普通公猫一条X染色体
                let randomValue = Double.random(in: 0...1)
                let result = randomValue < 0.5 ? BaseColor.black : BaseColor.red
                print("🎲 随机值: \(randomValue)")
                print("🧬 公猫抽取结果: \(result.rawValue)")
                return [result]
            }
        case .female:
            // 母猫两条X染色体 - 分开抽取增加参与感
            let firstRandom = Double.random(in: 0...1)
            let secondRandom = Double.random(in: 0...1)
            let first = firstRandom < 0.5 ? BaseColor.black : BaseColor.red
            let second = secondRandom < 0.5 ? BaseColor.black : BaseColor.red
            print("🎲 第一条染色体随机值: \(firstRandom)")
            print("🎲 第二条染色体随机值: \(secondRandom)")
            print("🧬 母猫第一条染色体: \(first.rawValue)")
            print("🧬 母猫第二条染色体: \(second.rawValue)")
            return [first, second]
        }
    }
}

// MARK: - 性别选择阶段
struct SexSelectionPhase: View {
    let onSexSelected: (Sex) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("请选择要合成的猫咪性别")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            HStack(spacing: 40) {
                SexSelectionButton(
                    sex: .male,
                    icon: "🙂",
                    title: "公猫",
                    isSelected: false
                ) {
                    onSexSelected(.male)
                }
                
                SexSelectionButton(
                    sex: .female,
                    icon: "😊",
                    title: "母猫",
                    isSelected: false
                ) {
                    onSexSelected(.female)
                }
            }
        }
    }
}

// MARK: - 染色体抽取阶段
struct ChromosomeExtractionPhase: View {
    let sex: Sex
    let isXXY: Bool
    @Binding var isExtracting: Bool
    let onExtract: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            Text("已选择：\(sex.rawValue)")
                .font(.headline)
                .foregroundColor(.pink)
            
            if isXXY {
                Text("🎉 超稀有 XXY 公猫！")
                    .font(.subheadline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orange.opacity(0.1))
                    )
            }
            
            ChromosomeExtractionView(
                sex: sex,
                isExtracting: $isExtracting,
                onExtract: onExtract
            )
        }
    }
}





struct SexSelectionButton: View {
    let sex: Sex
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(icon)
                    .font(.system(size: 40))
                
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
            }
            .frame(width: 100, height: 100)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? .pink.opacity(0.2) : .gray.opacity(0.1))
                    .stroke(isSelected ? .pink : .clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// 其他步骤的占位视图
struct Step2PlaceholderView: View {
    @ObservedObject var state: BreedingState
    
    var body: some View {
        VStack(spacing: 20) {
            Text("步骤 2：稀释基因调节")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("稀释基因会让颜色变淡，创造更多颜色变化")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 当前染色体展示
            if !state.chromosomes.isEmpty {
                VStack(spacing: 16) {
                    Text("当前染色体：")
                        .font(.headline)
                    
                    HStack(spacing: 16) {
                        ForEach(Array(state.chromosomes.enumerated()), id: \.offset) { index, chromosome in
                            VStack(spacing: 8) {
                                Text("第\(index + 1)条")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                // 实时颜色展示（根据稀释程度连续更新）
                                ChromosomeColorView(
                                    chromosome: chromosome, 
                                    dilutionLevel: state.dilutionLevel
                                )
                            }
                        }
                    }
                }
            }
            
            // 稀释程度控制
            VStack(spacing: 12) {
                Text("稀释程度：\(Int(state.dilutionLevel * 100))%")
                    .font(.headline)
                
                HStack {
                    Text("浓郁")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { state.dilutionLevel },
                        set: { state.dilutionLevel = $0 }
                    ), in: 0...1)
                        .onChange(of: state.dilutionLevel) { oldValue, newValue in
                            print("🎚️ 稀释程度调节到: \(newValue)")
                        }
                    .accentColor(.pink)
                    
                    Text("淡化")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.horizontal)
            
            // 染色方法控制
            VStack(spacing: 12) {
                let currentMethod = DyeingMethod.fromSliderValue(state.dyeingMethodLevel)
                
                Text("染色方法：\(currentMethod.name)")
                    .font(.headline)
                
                HStack {
                    Text("单色")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { state.dyeingMethodLevel },
                        set: { state.dyeingMethodLevel = $0 }
                    ), in: 0...1)
                        .onChange(of: state.dyeingMethodLevel) { oldValue, newValue in
                            // 吸附到最近的有效档位
                            let snappedValue = DyeingMethod.snapToNearestValue(newValue)
                            if abs(snappedValue - newValue) > 0.01 {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                    state.dyeingMethodLevel = snappedValue
                                }
                            }
                            let method = DyeingMethod.fromSliderValue(snappedValue)
                            print("🎨 染色方法调节到: \(method.name) (\(snappedValue))")
                        }
                        .accentColor(.orange)
                    
                    Text("斑纹")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 染色方法描述
                Text(currentMethod.description)
                    .font(.caption)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            .padding(.horizontal)
            
            // 快速选项
            HStack(spacing: 16) {
                Button("随机稀释") {
                    let newValue = Double.random(in: 0...1)
                    print("🎲 随机稀释设置: \(newValue)")
                    state.dilutionLevel = newValue
                }
                .buttonStyle(.bordered)
                
                Button("跳过稀释") {
                    print("⚪ 跳过稀释，设置为0.0")
                    state.dilutionLevel = 0.0
                }
                .buttonStyle(.bordered)
            }
            
            // 效果说明
            if !state.chromosomes.isEmpty {
                Text("当前效果：\(ColorInterpolator.getDilutionDescription(dilutionLevel: state.dilutionLevel))")
                    .font(.subheadline)
                    .foregroundColor(.pink)
                    .padding(.horizontal)
                    .multilineTextAlignment(.center)
            }
        }
        .padding()
    }
}


struct Step3PlaceholderView: View {
    @ObservedObject var state: BreedingState
    
    var body: some View {
        VStack(spacing: 8) {
            Text("步骤 3：斑纹选择")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("选择斑纹类型和覆盖程度")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 当前状态展示
            if !state.chromosomes.isEmpty {
                VStack(spacing: 8) {
                    Text("当前染色体：")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        ForEach(Array(state.chromosomes.enumerated()), id: \.offset) { index, chromosome in
                            VStack(spacing: 4) {
                                Text("第\(index + 1)条")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                // 展示叠加了稀释、染色和斑纹效果的颜色
                                ChromosomeColorView(
                                    chromosome: chromosome, 
                                    dilutionLevel: state.dilutionLevel,
                                    tabbySubtype: state.selectedTabbySubtype,
                                    patternCoverage: state.patternCoverage
                                )
                            }
                        }
                    }
                }
            }
            
            // 橘猫检测提示
            if state.isOrangeCat() {
                HStack {
                    Text("🍊")
                    Text("橘猫必须选择斑纹")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 4)
                .background(
                    RoundedRectangle(cornerRadius: 6)
                        .fill(.orange.opacity(0.1))
                )
            }
            
            // 斑纹类型选择
            VStack(spacing: 8) {
                Text("斑纹类型")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                    ForEach(TabbySubtype.allCases, id: \.self) { subtype in
                        TabbyTypeCard(
                            subtype: subtype,
                            isSelected: state.selectedTabbySubtype == subtype,
                            isDisabled: state.isOrangeCat() && subtype == .none
                        ) {
                            if !(state.isOrangeCat() && subtype == .none) {
                                print("🎨 [开始] 选择斑纹类型: \(subtype.rawValue)")
                                print("🎨 [更新前] selectedTabbySubtype = \(state.selectedTabbySubtype?.rawValue ?? "nil")")
                                state.selectedTabbySubtype = subtype
                                print("🎨 [更新后] selectedTabbySubtype = \(state.selectedTabbySubtype?.rawValue ?? "nil")")
                                
                                // 强制触发UI更新
                                state.forceUIRefresh()
                                
                                // 异步再次检查状态
                                DispatchQueue.main.async {
                                    print("🎨 [异步检查] selectedTabbySubtype = \(state.selectedTabbySubtype?.rawValue ?? "nil")")
                                }
                            }
                        }
                    }
                }
            }
            
            // 斑纹覆盖度控制（仅在选择斑纹时显示）
            if let selectedType = state.selectedTabbySubtype, selectedType != .none {
                VStack(spacing: 6) {
                    Text("覆盖度：\(Int(state.patternCoverage * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("稀疏")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: Binding(
                            get: { state.patternCoverage },
                            set: { state.patternCoverage = $0 }
                        ), in: 0...1)
                            .onChange(of: state.patternCoverage) { oldValue, newValue in
                                print("🎚️ 斑纹覆盖度调节到: \(newValue)")
                            }
                            .accentColor(.brown)
                        
                        Text("密集")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("影响斑纹密度")
                        .font(.caption2)
                        .foregroundColor(.brown)
                }
                .padding(.horizontal)
            }
            
            // 快速选项
            HStack(spacing: 16) {
                Button("随机斑纹") {
                    if state.isOrangeCat() {
                        state.selectedTabbySubtype = TabbySubtype.allCases.filter { $0 != .none }.randomElement()
                    } else {
                        state.selectedTabbySubtype = TabbySubtype.random()
                    }
                    state.patternCoverage = Double.random(in: 0.3...0.8)
                    print("🎲 随机斑纹设置: \(state.selectedTabbySubtype?.rawValue ?? "无")")
                }
                .buttonStyle(.bordered)
                
                if !state.isOrangeCat() {
                    Button("跳过斑纹") {
                        print("⚪ [开始] 跳过斑纹按钮点击")
                        print("⚪ [更新前] selectedTabbySubtype = \(state.selectedTabbySubtype?.rawValue ?? "nil")")
                        state.selectedTabbySubtype = TabbySubtype.none
                        state.patternCoverage = 0.0
                        print("⚪ [更新后] selectedTabbySubtype = \(state.selectedTabbySubtype?.rawValue ?? "nil")")
                        
                        // 强制触发UI更新
                        state.forceUIRefresh()
                        
                        print("⚪ 跳过斑纹，设置为无斑纹")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .onAppear {
            // 如果还没选择斑纹类型，设置默认值
            if state.selectedTabbySubtype == nil {
                if state.isOrangeCat() {
                    // 橘猫自动选择第一个非无斑纹类型
                    state.selectedTabbySubtype = TabbySubtype.allCases.first { $0 != .none }
                    print("🍊 橘猫自动选择斑纹: \(state.selectedTabbySubtype?.rawValue ?? "无")")
                } else {
                    // 普通猫默认选择"无斑纹"
                    state.selectedTabbySubtype = TabbySubtype.none
                    print("🐾 普通猫默认选择: 无斑纹")
                }
            }
        }
    }
}

// MARK: - 斑纹类型选择卡片
struct TabbyTypeCard: View {
    let subtype: TabbySubtype
    let isSelected: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(subtype.emoji)
                    .font(.system(size: 24))
                
                Text(subtype.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(subtype.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.4 : 1.0)
    }
    
    private var backgroundColor: Color {
        if isDisabled {
            return .gray.opacity(0.1)
        } else if isSelected {
            return .brown.opacity(0.2)
        } else {
            return .gray.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isDisabled {
            return .gray.opacity(0.3)
        } else if isSelected {
            return .brown
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        return isSelected ? 2 : 0
    }
}

// MARK: - 猫脸白斑选择器
struct CatFaceSelector: View {
    @Binding var selectedAreas: Set<WhiteArea>
    
    var body: some View {
        ZStack {
            // 猫脸轮廓
            CatFaceOutline()
            
            // 可点击的区域
            ForEach(WhiteArea.allCases, id: \.self) { area in
                ClickableWhiteArea(
                    area: area,
                    isSelected: selectedAreas.contains(area)
                ) {
                    toggleArea(area)
                }
            }
        }
        .frame(width: 200, height: 200)
    }
    
    private func toggleArea(_ area: WhiteArea) {
        if selectedAreas.contains(area) {
            selectedAreas.remove(area)
        } else {
            selectedAreas.insert(area)
        }
        print("🐱 切换白斑区域: \(area.rawValue) -> \(selectedAreas.contains(area) ? "选中" : "取消")")
    }
}

// MARK: - 猫脸轮廓
struct CatFaceOutline: View {
    var body: some View {
        ZStack {
            // 主要脸部轮廓
            RoundedRectangle(cornerRadius: 80)
                .stroke(.gray.opacity(0.5), lineWidth: 2)
                .frame(width: 160, height: 180)
            
            // 耳朵
            HStack(spacing: 100) {
                Triangle()
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                    .frame(width: 30, height: 40)
                    .offset(y: -70)
                Triangle()
                    .stroke(.gray.opacity(0.5), lineWidth: 2)
                    .frame(width: 30, height: 40)
                    .offset(y: -70)
            }
            
            // 眼睛轮廓
            HStack(spacing: 50) {
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 20, height: 20)
                    .offset(y: -15)
                Circle()
                    .stroke(.gray.opacity(0.3), lineWidth: 1)
                    .frame(width: 20, height: 20)
                    .offset(y: -15)
            }
            
            // 鼻子
            Circle()
                .fill(.gray.opacity(0.3))
                .frame(width: 8, height: 8)
            
            // 嘴巴轮廓
            Path { path in
                path.move(to: CGPoint(x: 100, y: 115))
                path.addCurve(
                    to: CGPoint(x: 85, y: 125),
                    control1: CGPoint(x: 95, y: 118),
                    control2: CGPoint(x: 90, y: 121)
                )
                path.move(to: CGPoint(x: 100, y: 115))
                path.addCurve(
                    to: CGPoint(x: 115, y: 125),
                    control1: CGPoint(x: 105, y: 118),
                    control2: CGPoint(x: 110, y: 121)
                )
            }
            .stroke(.gray.opacity(0.3), lineWidth: 1)
        }
    }
}

// MARK: - 三角形形状（耳朵）
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

// MARK: - 可点击的白斑区域
struct ClickableWhiteArea: View {
    let area: WhiteArea
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(isSelected ? .white.opacity(0.8) : .gray.opacity(0.2))
                    .frame(width: 24, height: 24)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? .blue : .gray, lineWidth: isSelected ? 2 : 1)
                    )
                
                Text(area.emoji)
                    .font(.caption2)
                    .opacity(isSelected ? 0.7 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .position(area.position)
    }
}

struct Step4PlaceholderView: View {
    @ObservedObject var state: BreedingState
    
    var body: some View {
        VStack(spacing: 8) {
            Text("步骤 4：加白设置")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("身体加白和面部白斑独立控制")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 当前状态展示
            if !state.chromosomes.isEmpty {
                VStack(spacing: 8) {
                    Text("当前猫咪预览：")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        ForEach(Array(state.chromosomes.enumerated()), id: \.offset) { index, chromosome in
                            VStack(spacing: 4) {
                                Text("第\(index + 1)条")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                // 展示叠加了前3步效果+白色效果
                                ChromosomeColorView(
                                    chromosome: chromosome, 
                                    dilutionLevel: state.dilutionLevel,
                                    tabbySubtype: state.selectedTabbySubtype,
                                    patternCoverage: state.patternCoverage,
                                    whitePercentage: state.bodyWhiteLevel,
                                    whiteAreas: state.selectedFaceWhiteAreas
                                )
                            }
                        }
                    }
                }
            }
            
            // 身体加白程度滑块
            VStack(spacing: 6) {
                let currentLevel = BodyWhiteLevel.fromPercentage(state.bodyWhiteLevel)
                
                Text("身体加白：\(currentLevel.name)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("足底")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { state.bodyWhiteLevel },
                        set: { state.bodyWhiteLevel = $0 }
                    ), in: 0...1)
                        .onChange(of: state.bodyWhiteLevel) { oldValue, newValue in
                            let level = BodyWhiteLevel.fromPercentage(newValue)
                            print("⚪ 身体加白调节到: \(level.name)")
                        }
                        .accentColor(.blue)
                    
                    Text("脊柱")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text(BodyWhiteLevel.fromPercentage(state.bodyWhiteLevel).description)
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            // 面部白斑选择器
            VStack(spacing: 6) {
                Text("面部白斑（独立）")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                CatFaceSelector(selectedAreas: Binding(
                    get: { state.selectedFaceWhiteAreas },
                    set: { state.selectedFaceWhiteAreas = $0 }
                ))
                .frame(height: 160)
                
                Text("点击面部区域添加白斑")
                    .font(.caption2)
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
            }
            
            // 快速选项
            VStack(spacing: 6) {
                HStack(spacing: 8) {
                    Button("白袜猫") {
                        state.bodyWhiteLevel = BodyWhiteLevel.paws.percentage
                        state.selectedFaceWhiteAreas = []
                        print("🧦 白袜猫设置")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption2)
                    
                    Button("面部白斑") {
                        state.bodyWhiteLevel = 0.0
                        state.selectedFaceWhiteAreas = [.chin, .muzzle, .noseBridge]
                        print("😺 面部白斑设置")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption2)
                    
                    Button("双色猫") {
                        state.bodyWhiteLevel = BodyWhiteLevel.belly.percentage
                        state.selectedFaceWhiteAreas = [.forehead, .chin, .leftCheek, .rightCheek]
                        print("🔵 双色猫设置")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption2)
                }
                
                HStack(spacing: 8) {
                    Button("随机组合") {
                        state.bodyWhiteLevel = Double.random(in: 0...1)
                        let randomCount = Int.random(in: 0...3)
                        state.selectedFaceWhiteAreas = Set(WhiteArea.allCases.shuffled().prefix(randomCount))
                        print("🎲 随机加白组合")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption2)
                    
                    Button("清除所有") {
                        state.bodyWhiteLevel = 0.0
                        state.selectedFaceWhiteAreas.removeAll()
                        print("🚫 清除所有白色")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption2)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
    }
}

struct Step5PlaceholderView: View {
    @ObservedObject var state: BreedingState
    
    var body: some View {
        VStack(spacing: 8) {
            Text("步骤 5：温度敏感调色")
                .font(.title3)
                .fontWeight(.bold)
            
            Text("基于体温分布的局部颜色调节")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            // 当前状态展示
            if !state.chromosomes.isEmpty {
                VStack(spacing: 8) {
                    Text("当前猫咪预览：")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack(spacing: 12) {
                        ForEach(Array(state.chromosomes.enumerated()), id: \.offset) { index, chromosome in
                            VStack(spacing: 4) {
                                Text("第\(index + 1)条")
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                
                                // 展示叠加了前4步+温度效果
                                TemperatureColorView(
                                    chromosome: chromosome, 
                                    dilutionLevel: state.dilutionLevel,
                                    tabbySubtype: state.selectedTabbySubtype,
                                    patternCoverage: state.patternCoverage,
                                    whitePercentage: state.bodyWhiteLevel,
                                    whiteAreas: state.selectedFaceWhiteAreas,
                                    temperatureEffect: state.selectedTemperatureEffect,
                                    affectedParts: state.selectedBodyParts,
                                    intensity: state.temperatureIntensity
                                )
                            }
                        }
                    }
                }
            }
            
            // 温度效果选择
            VStack(spacing: 8) {
                Text("温度效应类型")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack(spacing: 16) {
                    ForEach(TemperatureEffect.allCases, id: \.self) { effect in
                        TemperatureEffectCard(
                            effect: effect,
                            isSelected: state.selectedTemperatureEffect == effect
                        ) {
                            state.selectedTemperatureEffect = effect
                            // 清除之前选择的部位，重新开始
                            state.selectedBodyParts.removeAll()
                        }
                    }
                }
            }
            
            // 身体部位选择（仅在选择了温度效果时显示）
            if let selectedEffect = state.selectedTemperatureEffect {
                VStack(spacing: 8) {
                    Text("选择\(selectedEffect.rawValue)部位")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    Text(selectedEffect.description)
                        .font(.caption)
                        .foregroundColor(.orange)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(selectedEffect.availableBodyParts, id: \.self) { part in
                            BodyPartCard(
                                part: part,
                                isSelected: state.selectedBodyParts.contains(part)
                            ) {
                                if state.selectedBodyParts.contains(part) {
                                    state.selectedBodyParts.remove(part)
                                } else {
                                    state.selectedBodyParts.insert(part)
                                }
                                print("🌡️ 切换身体部位: \(part.rawValue) -> \(state.selectedBodyParts.contains(part) ? "选中" : "取消")")
                            }
                        }
                    }
                }
            }
            
            // 强度调节（仅在选择了部位时显示）
            if !state.selectedBodyParts.isEmpty {
                VStack(spacing: 6) {
                    Text("效果强度：\(Int(state.temperatureIntensity * 100))%")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    
                    HStack {
                        Text("轻微")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Slider(value: Binding(
                            get: { state.temperatureIntensity },
                            set: { state.temperatureIntensity = $0 }
                        ), in: 0...1)
                            .onChange(of: state.temperatureIntensity) { oldValue, newValue in
                                print("🌡️ 温度效应强度调节到: \(newValue)")
                            }
                            .accentColor(.orange)
                        
                        Text("强烈")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Text("影响颜色变化程度")
                        .font(.caption2)
                        .foregroundColor(.orange)
                }
                .padding(.horizontal)
            }
            
            // 快速选项
            if state.selectedTemperatureEffect != nil {
                HStack(spacing: 12) {
                    Button("随机组合") {
                        if let effect = state.selectedTemperatureEffect {
                            let availableParts = effect.availableBodyParts
                            let randomCount = Int.random(in: 1...min(2, availableParts.count))
                            state.selectedBodyParts = Set(availableParts.shuffled().prefix(randomCount))
                            state.temperatureIntensity = Double.random(in: 0.3...0.8)
                            print("🎲 随机温度效应设置")
                        }
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("清除效果") {
                        state.selectedTemperatureEffect = nil
                        state.selectedBodyParts.removeAll()
                        state.temperatureIntensity = 0.5
                        print("🚫 清除温度效应")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(.bottom, 12)
        .onAppear {
            print("🌡️ 步骤5加载完成 - 温度敏感调色系统")
        }
    }
}

// MARK: - 温度效果选择卡片
struct TemperatureEffectCard: View {
    let effect: TemperatureEffect
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(effect.emoji)
                    .font(.system(size: 30))
                
                Text(effect.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(effect.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .frame(height: 90)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .orange.opacity(0.2)
        } else {
            return .gray.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .orange
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        return isSelected ? 2 : 0
    }
}

// MARK: - 身体部位选择卡片
struct BodyPartCard: View {
    let part: BodyPart
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Text(part.emoji)
                    .font(.system(size: 24))
                
                Text(part.rawValue)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(part.description)
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(1)
            }
            .frame(height: 70)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(backgroundColor)
                    .stroke(borderColor, lineWidth: borderWidth)
            )
        }
        .buttonStyle(.plain)
    }
    
    private var backgroundColor: Color {
        if isSelected {
            return .orange.opacity(0.2)
        } else {
            return .gray.opacity(0.05)
        }
    }
    
    private var borderColor: Color {
        if isSelected {
            return .orange
        } else {
            return .clear
        }
    }
    
    private var borderWidth: CGFloat {
        return isSelected ? 2 : 0
    }
}

// MARK: - 温度敏感颜色显示组件
struct TemperatureColorView: View {
    let chromosome: BaseColor
    let dilutionLevel: Double
    let tabbySubtype: TabbySubtype?
    let patternCoverage: Double
    let whitePercentage: Double
    let whiteAreas: Set<WhiteArea>
    let temperatureEffect: TemperatureEffect?
    let affectedParts: Set<BodyPart>
    let intensity: Double
    
    var body: some View {
        let baseColor = ColorInterpolator.interpolateColor(
            baseColor: chromosome, 
            dilutionLevel: dilutionLevel
        )
        
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(hex: baseColor))
            .frame(width: 60, height: 45)
            .overlay(
                // 斑纹叠加层
                patternOverlay
            )
            .overlay(
                // 温度效应叠加层
                temperatureOverlay
            )
            .overlay(
                // 白色叠加层
                whiteOverlay
            )
            .overlay(
                // 文字标签
                VStack(spacing: 2) {
                    Text(ColorInterpolator.getColorName(
                        baseColor: chromosome, 
                        dilutionLevel: dilutionLevel
                    ))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                    
                    if let effect = temperatureEffect, !affectedParts.isEmpty {
                        Text(effect.rawValue)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 1)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: intensity)
    }
    
    @ViewBuilder
    private var patternOverlay: some View {
        if let tabbyType = tabbySubtype, tabbyType != .none {
            // 使用现有的斑纹渲染逻辑
            ChromosomeColorView(
                chromosome: chromosome,
                dilutionLevel: dilutionLevel,
                tabbySubtype: tabbyType,
                patternCoverage: patternCoverage
            )
            .opacity(0)  // 透明，只使用其叠加效果
        }
    }
    
    @ViewBuilder
    private var temperatureOverlay: some View {
        if let effect = temperatureEffect, !affectedParts.isEmpty {
            let temperatureGradient = createTemperatureGradient(effect: effect)
            
            RoundedRectangle(cornerRadius: 6)
                .fill(temperatureGradient)
                .opacity(intensity * 0.6)  // 根据强度调整透明度
        }
    }
    
    @ViewBuilder
    private var whiteOverlay: some View {
        if whitePercentage > 0.0 && !whiteAreas.isEmpty {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(whitePercentage * 0.9),
                            .white.opacity(whitePercentage * 0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.8)
        }
    }
    
    private func createTemperatureGradient(effect: TemperatureEffect) -> some ShapeStyle {
        switch effect {
        case .lighten:
            // 变浅效果：添加白色/黄色渐变
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .white.opacity(0.7),
                        .yellow.opacity(0.3),
                        .clear
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        case .darken:
            // 变深效果：添加黑色/棕色渐变
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [
                        .black.opacity(0.4),
                        .brown.opacity(0.2),
                        .clear
                    ]),
                    startPoint: .topTrailing,
                    endPoint: .bottomLeading
                )
            )
        }
    }
}

// MARK: - 测试验证函数
extension ColorInterpolator {
    static func runColorInterpolationTests() {
        print("🧪 开始颜色插值测试...")
        
        // 测试1: 边界值测试
        testBoundaryValues()
        
        // 测试2: 颜色插值连续性测试
        testColorContinuity()
        
        // 测试3: 描述文字测试
        testDescriptions()
        
        print("✅ 所有颜色插值测试完成")
    }
    
    private static func testBoundaryValues() {
        print("🔍 测试边界值...")
        
        let testCases: [(Double, String)] = [
            (0.0, "应该是原色"),
            (0.25, "应该是25%插值"),
            (0.5, "应该是50%插值"),
            (0.75, "应该是75%插值"),
            (1.0, "应该是完全稀释"),
            (-0.1, "应该被限制为0.0"),
            (1.5, "应该被限制为1.0")
        ]
        
        for (level, expectation) in testCases {
            let blackResult = interpolateColor(baseColor: .black, dilutionLevel: level)
            let redResult = interpolateColor(baseColor: .red, dilutionLevel: level)
            print("  稀释度\(level): 黑色→\(blackResult), 橙色→\(redResult) (\(expectation))")
        }
    }
    
    private static func testColorContinuity() {
        print("🔍 测试颜色连续性...")
        
        for i in 0...10 {
            let level = Double(i) / 10.0
            let result = interpolateColor(baseColor: .black, dilutionLevel: level)
            let description = getDilutionDescription(dilutionLevel: level)
            print("  \(Int(level*100))%: \(result) - \(description)")
        }
    }
    
    private static func testDescriptions() {
        print("🔍 测试描述文字...")
        
        let levels = [0.0, 0.2, 0.5, 0.8, 1.0]
        for level in levels {
            let desc = getDilutionDescription(dilutionLevel: level)
            let blackName = getColorName(baseColor: .black, dilutionLevel: level)
            let redName = getColorName(baseColor: .red, dilutionLevel: level)
            print("  \(Int(level*100))%: \(desc) | 黑→\(blackName), 红→\(redName)")
        }
    }
}

// MARK: - 步骤2交互测试验证
extension Step2PlaceholderView {
    func testInteractiveFeatures() {
        print("🧪 开始步骤2交互测试...")
        print("📱 请手动验证以下功能：")
        print("  1. 滑动滑块0→100%，色块应连续变化")
        print("  2. 点击'使用随机值'，色块应立即更新") 
        print("  3. 点击'跳过稀释'，色块应回到原色")
        print("  4. 稀释百分比文字应与滑块位置同步")
        print("  5. 效果描述文字应实时更新")
        print("  6. 多条染色体应同时响应变化")
    }
}

// MARK: - 完成后的结果页面组件
struct CompletedResultView: View {
    let cat: Cat
    let breedingSummary: BreedingSummary?
    let onRestart: () -> Void
    let onDismiss: () -> Void
    let breedingState: BreedingState
    @State private var selectedTab = 0  // 0: 猫咪信息, 1: 合成过程
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // 庆祝效果
                VStack(spacing: 20) {
                    Text("🎉")
                        .font(.system(size: 60))
                    
                    Text("恭喜获得新猫咪！")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.bottom, 20)
                
                // 猫咪展示
                CatCardView(cat: cat, size: .large)
                    .padding(.bottom, 20)
                
                // 标签切换（只有当有合成汇总时才显示）
                if breedingSummary != nil {
                    Picker("信息类型", selection: $selectedTab) {
                        Text("猫咪信息").tag(0)
                        Text("合成过程").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .padding(.bottom, 16)
                }
                
                // 内容区域
                VStack(spacing: 16) {
                    if selectedTab == 0 {
                        // 猫咪详细信息
                        CatDetailInfo(cat: cat, breedingSummary: breedingSummary)
                    } else if let summary = breedingSummary {
                        // 合成过程信息
                        BreedingProcessView(summary: summary)
                    }
                }
                .padding(.horizontal)
                
                // 操作按钮
                VStack(spacing: 16) {
                    // MVP版本：AI生成卡通头像按钮
                    Button(action: {
                        Task {
                            await breedingState.generateAICartoonImage()
                        }
                    }) {
                        HStack {
                            if breedingState.isGeneratingAI {
                                ProgressView()
                                    .scaleEffect(0.8)
                                Text("生成中...")
                            } else if breedingState.aiCartoonImage != nil {
                                Image(systemName: "photo.fill")
                                Text("重新生成卡通头像")
                            } else {
                                Image(systemName: "sparkles")
                                Text("生成卡通头像")
                            }
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .disabled(breedingState.isGeneratingAI)
                    
                    // AI生成结果显示
                    if let aiImage = breedingState.aiCartoonImage {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("🎨 AI卡通头像")
                                .font(.headline)
                            
                            if let imageURL = URL(string: aiImage.imageUrl) {
                                AsyncImage(url: imageURL) { image in
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                } placeholder: {
                                    ProgressView()
                                        .frame(height: 200)
                                }
                                .frame(maxHeight: 200)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                            }
                        }
                        .padding()
                        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                    }
                    
                    // AI生成错误显示
                    if let error = breedingState.aiGenerationError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
                    }
                    
                    Divider()
                        .padding(.vertical, 8)
                    
                    Button("再次合成") {
                        onRestart()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                    
                    Button("返回主界面") {
                        onDismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .frame(maxWidth: .infinity)
                }
                .padding()
            }
        }
    }
}

#Preview {
    StepByStepBreedingView()
        .environmentObject(GameData())
        .onAppear {
            // 运行测试验证
            ColorInterpolator.runColorInterpolationTests()
        }
}