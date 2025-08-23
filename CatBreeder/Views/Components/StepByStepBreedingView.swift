//
//  StepByStepBreedingView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 分步骤合成界面
struct StepByStepBreedingView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 1
    @State private var breedingState = BreedingState()
    @State private var showingResult = false
    
    let totalSteps = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 步骤指示器
                StepIndicator(currentStep: currentStep, totalSteps: totalSteps)
                
                Spacer()
                
                // 当前步骤内容
                currentStepView
                
                Spacer()
                
                // 底部按钮区域
                if currentStep == 1 {
                    // 步骤1使用内部控制，不显示外部按钮
                    Step1BottomControls(onSkip: skipToResult)
                } else {
                    BottomControls(
                        currentStep: currentStep,
                        totalSteps: totalSteps,
                        canProceed: canProceedToNextStep,
                        onPrevious: previousStep,
                        onNext: nextStep,
                        onSkip: skipToResult,
                        onFinish: finishBreeding
                    )
                }
            }
            .padding()
            .navigationTitle("猫咪合成")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("返回") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingResult) {
                if let cat = breedingState.finalCat {
                    CatResultView(cat: cat)
                        .environmentObject(gameData)
                }
            }
        }
    }
    
    // MARK: - 当前步骤视图
    @ViewBuilder
    private var currentStepView: some View {
        switch currentStep {
        case 1:
            Step1PlaceholderView(state: $breedingState) {
                nextStep() // 完成步骤1后进入步骤2
            }
        case 2:
            Step2PlaceholderView(state: $breedingState)
        case 3:
            Step3PlaceholderView(state: $breedingState)
        case 4:
            Step4PlaceholderView(state: $breedingState)
        case 5:
            Step5PlaceholderView(state: $breedingState)
        default:
            Text("未知步骤")
        }
    }
    
    // MARK: - 步骤控制逻辑
    private var canProceedToNextStep: Bool {
        switch currentStep {
        case 1: return breedingState.selectedSex != nil && !breedingState.chromosomes.isEmpty
        case 2: return true // 稀释基因可选
        case 3: return true // 斑纹可选
        case 4: return true // 加白可选
        case 5: return true // 特殊调色自动
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
        // 根据breedingState生成最终猫咪
        let genetics = breedingState.generateFinalGenetics()
        let cat = Cat(genetics: genetics)
        breedingState.finalCat = cat
        
        // 添加到收藏
        gameData.addCat(cat)
        _ = gameData.spendCoins(50)
        
        showingResult = true
    }
}

// MARK: - 繁育状态管理
class BreedingState: ObservableObject {
    @Published var selectedSex: Sex?
    @Published var isXXY: Bool = false
    @Published var chromosomes: [BaseColor] = []
    @Published var dilutionLevel: Double = 0.0
    @Published var selectedPattern: Pattern?
    @Published var patternCoverage: Double = 0.5
    @Published var whitePercentage: Double = 0.0
    @Published var specialEffects: [GeneticModifier] = []
    @Published var finalCat: Cat?
    
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
        // 其他属性使用默认值或随机值
    }
    
    func generateFinalGenetics() -> GeneticsData {
        let sex = selectedSex ?? Sex.random()
        let baseColor = chromosomes.first ?? BaseColor.random()
        let dilution = dilutionLevel > 0.5 ? Dilution.dilute : Dilution.dense
        let pattern = selectedPattern ?? Pattern.random()
        let white = WhitePattern(
            distribution: WhiteDistribution.random(),
            percentage: whitePercentage * 100
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
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSkip: () -> Void
    let onFinish: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 主要操作按钮
            HStack(spacing: 16) {
                // 上一步按钮
                if currentStep > 1 {
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
            }
            
            // 跳过按钮
            Button("跳过剩余步骤，直接合成", action: onSkip)
                .font(.caption)
                .foregroundColor(.secondary)
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
    @Binding var state: BreedingState
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

// MARK: - 染色体抽取界面
struct ChromosomeExtractionView: View {
    let sex: Sex
    @Binding var isExtracting: Bool
    let onExtract: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(extractionPrompt)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onExtract) {
                HStack {
                    if isExtracting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("抽取中...")
                    } else {
                        Image(systemName: "shuffle")
                        Text("开始抽取染色体")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: 200)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.pink)
                )
            }
            .disabled(isExtracting)
        }
    }
    
    private var extractionPrompt: String {
        switch sex {
        case .male: return "公猫有一条X染色体\n将随机获得黑色或橘色基因"
        case .female: return "母猫有两条X染色体\n将进行两次抽取"
        }
    }
}

// MARK: - 染色体结果展示
struct ChromosomeResultView: View {
    let sex: Sex
    let chromosomes: [BaseColor]
    let isXXY: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if isXXY {
                Text("🎉 超稀有 XXY 公猫！")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orange.opacity(0.1))
                    )
            }
            
            Text("染色体抽取结果：")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(Array(chromosomes.enumerated()), id: \.offset) { index, chromosome in
                    ChromosomeCard(
                        chromosome: chromosome,
                        position: index + 1,
                        isXXY: isXXY
                    )
                }
            }
            
            Text(resultDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var resultDescription: String {
        if chromosomes.count == 1 {
            return "公猫获得了\(chromosomes[0].rawValue)基因"
        } else if chromosomes.count == 2 {
            let first = chromosomes[0]
            let second = chromosomes[1]
            
            if first == second {
                return "\(sex.rawValue)获得了双\(first.rawValue)基因"
            } else {
                if sex == .male && isXXY {
                    return "XXY公猫获得了黑色+橘色基因，将表现为玳瑁色！"
                } else {
                    return "母猫获得了黑色+橘色基因，将表现为玳瑁/三花色！"
                }
            }
        }
        return ""
    }
}

// MARK: - 染色体卡片
struct ChromosomeCard: View {
    let chromosome: BaseColor
    let position: Int
    let isXXY: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text("X\(position)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(chromosomeColor)
                .frame(width: 60, height: 80)
                .overlay(
                    VStack {
                        Text(chromosome.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if isXXY && position == 2 {
                            Text("Y")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                )
        }
    }
    
    private var chromosomeColor: Color {
        switch chromosome {
        case .black: return .black
        case .red: return .red
        default: return .gray
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
    @Binding var state: BreedingState
    
    var body: some View {
        VStack {
            Text("步骤 2：稀释基因调节")
                .font(.title2)
            Text("(占位 - 待实现)")
                .foregroundColor(.secondary)
        }
    }
}

struct Step3PlaceholderView: View {
    @Binding var state: BreedingState
    
    var body: some View {
        VStack {
            Text("步骤 3：斑纹选择")
                .font(.title2)
            Text("(占位 - 待实现)")
                .foregroundColor(.secondary)
        }
    }
}

struct Step4PlaceholderView: View {
    @Binding var state: BreedingState
    
    var body: some View {
        VStack {
            Text("步骤 4：加白设置")
                .font(.title2)
            Text("(占位 - 待实现)")
                .foregroundColor(.secondary)
        }
    }
}

struct Step5PlaceholderView: View {
    @Binding var state: BreedingState
    
    var body: some View {
        VStack {
            Text("步骤 5：特殊调色")
                .font(.title2)
            Text("(占位 - 待实现)")
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    StepByStepBreedingView()
        .environmentObject(GameData())
}