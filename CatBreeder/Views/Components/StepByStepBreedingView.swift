//
//  StepByStepBreedingView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI
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

// MARK: - 白斑区域枚举
enum WhiteArea: String, CaseIterable {
    case forehead = "额头"
    case noseBridge = "鼻梁" 
    case chin = "下巴"
    case leftEyeRing = "左眼圈"
    case rightEyeRing = "右眼圈"
    case muzzle = "嘴周"
    case leftCheek = "左脸颊"
    case rightCheek = "右脸颊"
    
    var emoji: String {
        switch self {
        case .forehead: return "🤔"
        case .noseBridge: return "👃"
        case .chin: return "😮"
        case .leftEyeRing: return "👁️"
        case .rightEyeRing: return "👁️"
        case .muzzle: return "😺"
        case .leftCheek: return "😊"
        case .rightCheek: return "😊"
        }
    }
    
    var position: CGPoint {
        // 相对于200x200猫脸的位置坐标
        switch self {
        case .forehead: return CGPoint(x: 100, y: 60)
        case .noseBridge: return CGPoint(x: 100, y: 100)
        case .chin: return CGPoint(x: 100, y: 160)
        case .leftEyeRing: return CGPoint(x: 75, y: 85)
        case .rightEyeRing: return CGPoint(x: 125, y: 85)
        case .muzzle: return CGPoint(x: 100, y: 130)
        case .leftCheek: return CGPoint(x: 60, y: 110)
        case .rightCheek: return CGPoint(x: 140, y: 110)
        }
    }
}

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

// MARK: - 分步骤合成界面
struct StepByStepBreedingView: View {
    @EnvironmentObject var gameData: GameData
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 1
    @StateObject private var breedingState = BreedingState()
    @State private var showingResult = false
    
    let totalSteps = 5
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 步骤指示器
                StepIndicator(currentStep: currentStep, totalSteps: totalSteps)
                
                // 当前步骤内容（使用更紧凑的布局）
                currentStepView
                
                Spacer(minLength: 8)
                
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
            .padding(.horizontal, 16)
            .padding(.top, 8)
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
    @Published var dyeingMethodLevel: Double = 0.0  // 染色方法滑块值（0.0-1.0）
    @Published var selectedPattern: Pattern?
    @Published var selectedTabbySubtype: TabbySubtype?
    @Published var patternCoverage: Double = 0.5  // 斑纹覆盖度 0-100%
    @Published var whitePercentage: Double = 0.0
    @Published var selectedWhiteAreas: Set<WhiteArea> = []  // 白斑区域选择
    @Published var specialEffects: [GeneticModifier] = []
    @Published var finalCat: Cat?
    @Published var uiRefreshTrigger: Int = 0  // UI刷新触发器
    
    // 强制触发UI刷新
    func forceUIRefresh() {
        uiRefreshTrigger += 1
        print("🔄 [BreedingState] 强制UI刷新触发: \(uiRefreshTrigger)")
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
                .onAppear {
                    print("🎯 [BottomControls] 步骤\(currentStep) - canProceed = \(canProceed)")
                }
                .onChange(of: canProceed) { oldValue, newValue in
                    print("🎯 [BottomControls] 步骤\(currentStep) - canProceed 变化: \(oldValue) → \(newValue)")
                }
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

// MARK: - 染色体颜色显示组件
struct ChromosomeColorView: View {
    let chromosome: BaseColor
    let dilutionLevel: Double
    let tabbySubtype: TabbySubtype?
    let patternCoverage: Double
    let whitePercentage: Double
    let whiteAreas: Set<WhiteArea>
    
    init(chromosome: BaseColor, dilutionLevel: Double, tabbySubtype: TabbySubtype? = nil, patternCoverage: Double = 0.5, whitePercentage: Double = 0.0, whiteAreas: Set<WhiteArea> = []) {
        self.chromosome = chromosome
        self.dilutionLevel = dilutionLevel
        self.tabbySubtype = tabbySubtype
        self.patternCoverage = patternCoverage
        self.whitePercentage = whitePercentage
        self.whiteAreas = whiteAreas
    }
    
    var body: some View {
        let interpolatedColor = ColorInterpolator.interpolateColor(
            baseColor: chromosome, 
            dilutionLevel: dilutionLevel
        )
        
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(hex: interpolatedColor))
            .frame(width: 60, height: 45)
            .overlay(
                // 斑纹叠加层
                patternOverlay
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
                    
                    if let tabbyType = tabbySubtype, tabbyType != .none {
                        Text(tabbyType.rawValue)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 1)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: dilutionLevel)
            .animation(.easeInOut(duration: 0.2), value: patternCoverage)
            .animation(.easeInOut(duration: 0.2), value: whitePercentage)
            .id("\(chromosome.rawValue)-\(dilutionLevel)-\(tabbySubtype?.rawValue ?? "none")-\(patternCoverage)-\(whitePercentage)-\(whiteAreas.count)") // 强制刷新
    }
    
    @ViewBuilder
    private var patternOverlay: some View {
        if let tabbyType = tabbySubtype, tabbyType != .none {
            patternFill(for: tabbyType)
                .opacity(patternCoverage * 0.6) // 根据覆盖度调整透明度
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
                .opacity(0.8) // 基础透明度，让底色可见
        }
    }
    
    private func patternFill(for tabbyType: TabbySubtype) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(getPatternGradient(for: tabbyType))
    }
    
    private func getPatternGradient(for tabbyType: TabbySubtype) -> some ShapeStyle {
        switch tabbyType {
        case .mackerel:
            // 鲭鱼斑：垂直线条效果
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.4), location: 0.0),
                        .init(color: .clear, location: 0.1),
                        .init(color: .black.opacity(0.4), location: 0.2),
                        .init(color: .clear, location: 0.3),
                        .init(color: .black.opacity(0.4), location: 0.4),
                        .init(color: .clear, location: 0.5)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .classic:
            // 古典斑：宽条纹
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.4), location: 0.0),
                        .init(color: .clear, location: 0.3),
                        .init(color: .black.opacity(0.4), location: 0.7),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .spotted:
            // 点斑：径向渐变模拟点状
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [.black.opacity(0.4), .clear]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 20
                )
            )
        case .ticked:
            // 细斑纹：细腻渐变
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.2), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .none:
            return AnyShapeStyle(.clear)
        }
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
            
            Text("调整白色分布范围和强度")
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
                                    whitePercentage: state.whitePercentage,
                                    whiteAreas: state.selectedWhiteAreas
                                )
                            }
                        }
                    }
                }
            }
            
            // 加白程度滑块
            VStack(spacing: 6) {
                Text("加白程度：\(Int(state.whitePercentage * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                HStack {
                    Text("无白")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Slider(value: Binding(
                        get: { state.whitePercentage },
                        set: { state.whitePercentage = $0 }
                    ), in: 0...1)
                        .onChange(of: state.whitePercentage) { oldValue, newValue in
                            print("⚪ 加白程度调节到: \(newValue)")
                        }
                        .accentColor(.blue)
                    
                    Text("纯白")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Text("影响白色覆盖范围")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }
            .padding(.horizontal)
            
            // 猫脸白斑精选器
            VStack(spacing: 6) {
                Text("白斑精选区域")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                CatFaceSelector(selectedAreas: Binding(
                    get: { state.selectedWhiteAreas },
                    set: { state.selectedWhiteAreas = $0 }
                ))
                .frame(height: 200)
                
                Text("点击猫脸区域选择白斑位置")
                    .font(.caption2)
                    .foregroundColor(.blue)
                    .multilineTextAlignment(.center)
            }
            
            // 快速选项
            VStack(spacing: 6) {
                HStack(spacing: 12) {
                    Button("随机白斑") {
                        let randomCount = Int.random(in: 1...3)
                        state.selectedWhiteAreas = Set(WhiteArea.allCases.shuffled().prefix(randomCount))
                        state.whitePercentage = Double.random(in: 0.2...0.8)
                        print("🎲 随机白斑设置: \(state.selectedWhiteAreas.count)个区域, \(Int(state.whitePercentage * 100))%强度")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("经典白胸") {
                        state.selectedWhiteAreas = [.chin, .muzzle]
                        state.whitePercentage = 0.4
                        print("🤍 经典白胸设置")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                }
                
                HStack(spacing: 12) {
                    Button("双色猫") {
                        state.selectedWhiteAreas = [.forehead, .chin, .muzzle, .leftCheek, .rightCheek]
                        state.whitePercentage = 0.6
                        print("🔵 双色猫设置")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
                    
                    Button("清除白色") {
                        state.selectedWhiteAreas.removeAll()
                        state.whitePercentage = 0.0
                        print("🚫 清除所有白色设置")
                    }
                    .buttonStyle(.bordered)
                    .font(.caption)
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
        VStack {
            Text("步骤 5：特殊调色")
                .font(.title2)
            Text("(占位 - 待实现)")
                .foregroundColor(.secondary)
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

#Preview {
    StepByStepBreedingView()
        .environmentObject(GameData())
        .onAppear {
            // 运行测试验证
            ColorInterpolator.runColorInterpolationTests()
        }
}