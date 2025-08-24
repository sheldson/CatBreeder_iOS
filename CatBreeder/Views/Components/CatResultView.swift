//
//  CatResultView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 猫咪详情弹窗
struct CatResultView: View {
    let cat: Cat
    let breedingSummary: BreedingSummary?  // 添加合成汇总信息
    @EnvironmentObject var gameData: GameData
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0  // 0: 猫咪信息, 1: 合成过程
    
    // 便利构造器，保持向后兼容
    init(cat: Cat) {
        self.cat = cat
        self.breedingSummary = nil
    }
    
    init(cat: Cat, breedingSummary: BreedingSummary?) {
        self.cat = cat
        self.breedingSummary = breedingSummary
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 庆祝效果
                CelebrationHeader()
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
                
                // 内容区域（可滚动）
                ScrollView {
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
                }
                
                Spacer()
                
                // 关闭按钮
                DismissButton {
                    dismiss()
                }
                .padding()
            }
            .navigationTitle("合成结果")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 庆祝头部
struct CelebrationHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 60))
            
            Text("恭喜获得新猫咪！")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}

// MARK: - 猫咪详细信息
struct CatDetailInfo: View {
    let cat: Cat
    let breedingSummary: BreedingSummary?
    
    // 向后兼容的构造器
    init(cat: Cat) {
        self.cat = cat
        self.breedingSummary = nil
    }
    
    init(cat: Cat, breedingSummary: BreedingSummary?) {
        self.cat = cat
        self.breedingSummary = breedingSummary
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 基础信息区域
            VStack(alignment: .leading, spacing: 12) {
                InfoRow(title: "名称", value: cat.displayName)
                InfoRow(title: "稀有度", value: cat.rarity.rawValue, valueColor: cat.rarity.color)
                
                // 如果有合成汇总，显示预测品种
                if let summary = breedingSummary {
                    InfoRow(title: "推测品种", value: "\(summary.predictedBreed.emoji) \(summary.predictedBreed.rawValue)")
                    InfoRow(title: "品种特征", value: summary.predictedBreed.description)
                }
                
                InfoRow(title: "眼睛颜色", value: "\(eyeColor.rawValue)", valueColor: eyeColor.swiftUIColor)
                
                if cat.appearance.hasSpecialEffects {
                    InfoRow(title: "特殊效果", value: "✨ \(specialEffectsText)")
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            // 详细颜色描述区域
            if let summary = breedingSummary {
                VStack(alignment: .leading, spacing: 12) {
                    Text("详细颜色描述")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(summary.detailedColorDescription)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            
            // 稀有度解释区域
            if let summary = breedingSummary {
                VStack(alignment: .leading, spacing: 12) {
                    Text("稀有度分析")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text(summary.rarityExplanation)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .lineSpacing(4)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
            }
            
            // 特殊特征区域
            if let summary = breedingSummary, !summary.specialFeatures.isEmpty {
                VStack(alignment: .leading, spacing: 12) {
                    Text("特殊特征")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(summary.specialFeatures, id: \.self) { feature in
                            Text(feature)
                                .font(.body)
                                .foregroundColor(.orange)
                                .padding(.vertical, 2)
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
    }
    
    // 获取眼睛颜色（优先使用合成汇总中的结果）
    private var eyeColor: EyeColor {
        return breedingSummary?.eyeColorResult ?? cat.appearance.eyeColor
    }
    
    // 获取特殊效果文字
    private var specialEffectsText: String {
        return cat.appearance.specialEffects.map { $0.rawValue }.joined(separator: "、")
    }
}

// MARK: - 关闭按钮
struct DismissButton: View {
    let action: () -> Void
    
    var body: some View {
        Button("太棒了！", action: action)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
    }
}

// MARK: - 信息行
struct InfoRow: View {
    let title: String
    let value: String
    let valueColor: Color?
    
    // 默认构造器（向后兼容）
    init(title: String, value: String) {
        self.title = title
        self.value = value
        self.valueColor = nil
    }
    
    init(title: String, value: String, valueColor: Color) {
        self.title = title
        self.value = value
        self.valueColor = valueColor
    }
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundColor(valueColor ?? .primary)
        }
    }
}

// MARK: - 合成过程展示
struct BreedingProcessView: View {
    let summary: BreedingSummary
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // 合成过程标题
            Text("合成过程回顾")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            // 每一步的选择
            ForEach(summary.stepByStepChoices, id: \.stepNumber) { step in
                StepSummaryCard(step: step)
            }
            
            // 最终结果汇总
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("🎯 最终结果")
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer()
                    Text(summary.predictedBreed.emoji)
                        .font(.title2)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("品种：\(summary.predictedBreed.rawValue)")
                        .font(.body)
                        .fontWeight(.medium)
                    
                    Text("眼睛：\(summary.eyeColorResult.rawValue)")
                        .font(.body)
                        .foregroundColor(summary.eyeColorResult.swiftUIColor)
                        .fontWeight(.medium)
                    
                    if !summary.specialFeatures.isEmpty {
                        Text("特征：\(summary.specialFeatures.joined(separator: " "))")
                            .font(.body)
                            .foregroundColor(.orange)
                            .fontWeight(.medium)
                    }
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.green.opacity(0.1))
                    .stroke(.green.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// MARK: - 步骤汇总卡片
struct StepSummaryCard: View {
    let step: BreedingSummary.StepChoice
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("步骤 \(step.stepNumber)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.pink)
                    )
                
                Text(step.stepName)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            HStack {
                Text("选择：")
                    .font(.body)
                    .foregroundColor(.secondary)
                Text(step.choice)
                    .font(.body)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
            }
            
            if !step.description.isEmpty {
                Text(step.description)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineSpacing(2)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .stroke(.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

#Preview {
    let genetics = GeneticsData.random()
    let cat = Cat(genetics: genetics)
    
    return CatResultView(cat: cat)
        .environmentObject(GameData())
}