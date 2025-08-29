//
//  PromptOptimizerTestView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import SwiftUI

struct PromptOptimizerTestView: View {
    @ObservedObject private var apiService = PoeAPIService.shared
    @State private var testCat: Cat
    @State private var isLoading = false
    @State private var optimizedPrompt = ""
    @State private var styleVariants: [StyleVariant] = []
    @State private var qualityVariants: [QualityVariant] = []
    @State private var errorMessage = ""
    @State private var selectedTab = 0
    
    private let promptOptimizer = PromptOptimizer.shared
    
    init() {
        // 创建一个测试猫咪
        let genetics = GeneticsData(
            sex: .female,
            baseColor: .red,
            dilution: .dense,
            pattern: .calico,
            white: WhitePattern(distribution: .bicolor, percentage: 25.0),
            modifiers: [.golden]
        )
        _testCat = State(initialValue: Cat(genetics: genetics))
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // API模式切换
                APIModeToggle()
                
                // 猫咪预览
                CatPreviewSection(cat: testCat) {
                    generateNewTestCat()
                }
                
                // 标签切换
                Picker("功能选择", selection: $selectedTab) {
                    Text("基础优化").tag(0)
                    Text("风格变体").tag(1)
                    Text("质量等级").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                // 内容区域
                ScrollView {
                    VStack(spacing: 16) {
                        switch selectedTab {
                        case 0:
                            BasicOptimizationView(
                                cat: testCat,
                                optimizedPrompt: optimizedPrompt,
                                isLoading: isLoading,
                                errorMessage: errorMessage
                            ) {
                                optimizeBasicPrompt()
                            }
                        case 1:
                            StyleVariantsView(
                                styleVariants: styleVariants,
                                isLoading: isLoading
                            ) {
                                generateStyleVariants()
                            }
                        case 2:
                            QualityVariantsView(qualityVariants: qualityVariants)
                        default:
                            EmptyView()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Prompt优化测试")
        }
        .onAppear {
            generateQualityVariants()
        }
    }
    
    // MARK: - 私有方法
    
    private func optimizeBasicPrompt() {
        Task {
            await MainActor.run {
                isLoading = true
                errorMessage = ""
                optimizedPrompt = ""
            }
            
            do {
                let prompt = try await promptOptimizer.optimizeForAIArt(cat: testCat)
                await MainActor.run {
                    optimizedPrompt = prompt
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func generateStyleVariants() {
        Task {
            await MainActor.run {
                isLoading = true
                styleVariants = []
            }
            
            do {
                let variants = try await promptOptimizer.generateStyleVariants(cat: testCat)
                await MainActor.run {
                    styleVariants = variants
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isLoading = false
                }
            }
        }
    }
    
    private func generateQualityVariants() {
        qualityVariants = promptOptimizer.getQualityPrompts(for: testCat)
    }
    
    private func generateNewTestCat() {
        let newGenetics = GeneticsData.random()
        testCat = Cat(genetics: newGenetics)
        generateQualityVariants()
        
        // 清空之前的结果
        optimizedPrompt = ""
        styleVariants = []
        errorMessage = ""
    }
}

// MARK: - 子组件

struct APIModeToggle: View {
    @ObservedObject private var apiService = PoeAPIService.shared
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Text("API模式:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Toggle("模拟模式", isOn: $apiService.isSimulationMode)
                    .labelsHidden()
            }
            
            Text(apiService.isSimulationMode ? "🟡 模拟模式 (离线测试)" : "🟢 真实API模式")
                .font(.caption)
                .foregroundColor(apiService.isSimulationMode ? .orange : .green)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}

struct CatPreviewSection: View {
    let cat: Cat
    let onNewCat: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("🐱 测试猫咪")
                .font(.headline)
            
            CatCardView(cat: cat, size: .medium)
            
            Button("生成新猫咪", action: onNewCat)
                .buttonStyle(.bordered)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}

struct BasicOptimizationView: View {
    let cat: Cat
    let optimizedPrompt: String
    let isLoading: Bool
    let errorMessage: String
    let onOptimize: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onOptimize) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "wand.and.stars")
                    }
                    Text(isLoading ? "优化中..." : "生成AI绘画Prompt")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.blue)
                )
                .foregroundColor(.white)
            }
            .disabled(isLoading)
            
            if !errorMessage.isEmpty {
                ErrorView(message: errorMessage)
            }
            
            if !optimizedPrompt.isEmpty {
                PromptResultView(
                    title: "优化后的AI绘画Prompt",
                    prompt: optimizedPrompt,
                    icon: "paintbrush.pointed"
                )
            }
        }
    }
}

struct StyleVariantsView: View {
    let styleVariants: [StyleVariant]
    let isLoading: Bool
    let onGenerate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Button(action: onGenerate) {
                HStack {
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "paintpalette")
                    }
                    Text(isLoading ? "生成中..." : "生成风格变体")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.purple)
                )
                .foregroundColor(.white)
            }
            .disabled(isLoading)
            
            if !styleVariants.isEmpty {
                LazyVStack(spacing: 12) {
                    ForEach(styleVariants.indices, id: \.self) { index in
                        let variant = styleVariants[index]
                        PromptResultView(
                            title: "\(variant.styleName) (\(variant.englishName))",
                            prompt: variant.prompt,
                            icon: "paintbrush.pointed.fill"
                        )
                    }
                }
            }
        }
    }
}

struct QualityVariantsView: View {
    let qualityVariants: [QualityVariant]
    
    var body: some View {
        LazyVStack(spacing: 12) {
            Text("质量等级Prompt")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ForEach(qualityVariants.indices, id: \.self) { index in
                let variant = qualityVariants[index]
                PromptResultView(
                    title: variant.level,
                    prompt: variant.prompt,
                    icon: "star.fill"
                )
            }
        }
    }
}

struct PromptResultView: View {
    let title: String
    let prompt: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Spacer()
                CopyButton(text: prompt)
            }
            
            Text(prompt)
                .font(.body)
                .padding(12)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(.gray.opacity(0.1))
                )
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct CopyButton: View {
    let text: String
    @State private var copied = false
    
    var body: some View {
        Button(action: copyToClipboard) {
            Image(systemName: copied ? "checkmark" : "doc.on.doc")
                .foregroundColor(copied ? .green : .blue)
        }
    }
    
    private func copyToClipboard() {
        #if os(iOS)
        UIPasteboard.general.string = text
        #endif
        copied = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            copied = false
        }
    }
}

struct ErrorView: View {
    let message: String
    
    var body: some View {
        HStack {
            Image(systemName: "exclamationmark.triangle")
                .foregroundColor(.red)
            Text(message)
                .font(.caption)
                .foregroundColor(.red)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(.red.opacity(0.1))
        )
    }
}

#Preview {
    PromptOptimizerTestView()
}