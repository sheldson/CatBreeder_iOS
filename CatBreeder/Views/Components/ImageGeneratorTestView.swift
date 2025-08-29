//
//  ImageGeneratorTestView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import SwiftUI

struct ImageGeneratorTestView: View {
    @ObservedObject private var imageGenerator = ImageGenerator.shared
    @ObservedObject private var apiService = PoeAPIService.shared
    
    @State private var testCat: Cat
    @State private var selectedStyle: ImageStyle = .realistic
    @State private var selectedQuality: ImageQuality = .standard
    @State private var generatedImage: GeneratedImage?
    @State private var errorMessage = ""
    @State private var selectedTab = 0
    @State private var customPrompt = ""
    
    init() {
        let genetics = GeneticsData(
            sex: .female,
            baseColor: .red,
            dilution: .dense,
            pattern: .calico,
            white: WhitePattern(distribution: .bicolor, percentage: 30.0),
            modifiers: [.golden]
        )
        _testCat = State(initialValue: Cat(genetics: genetics))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // API模式切换
                    APIModeToggle()
                    
                    // 标签切换
                    Picker("生成模式", selection: $selectedTab) {
                        Text("从猫咪生成").tag(0)
                        Text("自定义Prompt").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // 内容区域
                    switch selectedTab {
                    case 0:
                        CatImageGenerationView(
                            cat: testCat,
                            selectedStyle: $selectedStyle,
                            selectedQuality: $selectedQuality
                        ) {
                            generateFromCat()
                        } onNewCat: {
                            generateNewTestCat()
                        }
                    case 1:
                        CustomPromptView(
                            customPrompt: $customPrompt,
                            selectedStyle: $selectedStyle,
                            selectedQuality: $selectedQuality
                        ) {
                            generateFromPrompt()
                        }
                    default:
                        EmptyView()
                    }
                    
                    // 生成进度显示
                    if let progress = imageGenerator.generationProgress {
                        GenerationProgressView(progress: progress)
                    }
                    
                    // 错误信息
                    if !errorMessage.isEmpty {
                        ErrorView(message: errorMessage)
                    }
                    
                    // 生成结果
                    if let image = generatedImage {
                        GeneratedImageView(image: image)
                    }
                }
                .padding()
            }
            .navigationTitle("AI图片生成测试")
        }
    }
    
    // MARK: - 私有方法
    
    private func generateFromCat() {
        Task {
            await MainActor.run {
                errorMessage = ""
                generatedImage = nil
            }
            
            do {
                let result = try await imageGenerator.generateCatImage(
                    from: testCat,
                    style: selectedStyle,
                    quality: selectedQuality
                )
                
                await MainActor.run {
                    generatedImage = result
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func generateFromPrompt() {
        guard !customPrompt.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "请输入自定义提示词"
            return
        }
        
        Task {
            await MainActor.run {
                errorMessage = ""
                generatedImage = nil
            }
            
            do {
                let result = try await imageGenerator.generateImage(
                    from: customPrompt,
                    style: selectedStyle,
                    quality: selectedQuality
                )
                
                await MainActor.run {
                    generatedImage = result
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func generateNewTestCat() {
        let newGenetics = GeneticsData.random()
        testCat = Cat(genetics: newGenetics)
        
        // 清空之前的结果
        generatedImage = nil
        errorMessage = ""
    }
}

// MARK: - 子组件

struct CatImageGenerationView: View {
    let cat: Cat
    @Binding var selectedStyle: ImageStyle
    @Binding var selectedQuality: ImageQuality
    let onGenerate: () -> Void
    let onNewCat: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 猫咪预览
            CatPreviewSection(cat: cat, onNewCat: onNewCat)
            
            // 风格选择
            StyleSelectionView(selectedStyle: $selectedStyle)
            
            // 质量选择
            QualitySelectionView(selectedQuality: $selectedQuality)
            
            // 生成按钮
            GenerateButton(title: "生成猫咪图片", action: onGenerate)
        }
    }
}

struct CustomPromptView: View {
    @Binding var customPrompt: String
    @Binding var selectedStyle: ImageStyle
    @Binding var selectedQuality: ImageQuality
    let onGenerate: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 自定义提示词输入
            VStack(alignment: .leading, spacing: 8) {
                Text("自定义提示词")
                    .font(.headline)
                
                TextEditor(text: $customPrompt)
                    .frame(height: 120)
                    .padding(8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.gray.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(.gray.opacity(0.3), lineWidth: 1)
                    )
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(.ultraThinMaterial)
            )
            
            // 风格选择
            StyleSelectionView(selectedStyle: $selectedStyle)
            
            // 质量选择
            QualitySelectionView(selectedQuality: $selectedQuality)
            
            // 生成按钮
            GenerateButton(title: "生成图片", action: onGenerate)
        }
    }
}

struct StyleSelectionView: View {
    @Binding var selectedStyle: ImageStyle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("艺术风格")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(ImageStyle.allCases, id: \.self) { style in
                        StyleButton(
                            style: style,
                            isSelected: selectedStyle == style
                        ) {
                            selectedStyle = style
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct QualitySelectionView: View {
    @Binding var selectedQuality: ImageQuality
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("图片质量")
                .font(.headline)
            
            HStack(spacing: 8) {
                ForEach(ImageQuality.allCases, id: \.self) { quality in
                    QualityButton(
                        quality: quality,
                        isSelected: selectedQuality == quality
                    ) {
                        selectedQuality = quality
                    }
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

struct StyleButton: View {
    let style: ImageStyle
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: iconName)
                    .font(.title2)
                Text(style.displayName)
                    .font(.caption)
                    .multilineTextAlignment(.center)
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? .blue : .gray.opacity(0.2))
            )
            .foregroundColor(isSelected ? .white : .primary)
        }
    }
    
    private var iconName: String {
        switch style {
        case .realistic: return "camera"
        case .digital: return "paintbrush.pointed"
        case .painting: return "paintpalette"
        case .watercolor: return "drop"
        case .cartoon: return "face.smiling"
        }
    }
}

struct QualityButton: View {
    let quality: ImageQuality
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(quality.displayName)
                .font(.subheadline)
                .padding(.vertical, 8)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? .blue : .gray.opacity(0.2))
                )
                .foregroundColor(isSelected ? .white : .primary)
        }
    }
}

struct GenerateButton: View {
    let title: String
    let action: () -> Void
    @ObservedObject private var imageGenerator = ImageGenerator.shared
    
    var body: some View {
        Button(action: action) {
            HStack {
                if imageGenerator.isGenerating {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "sparkles")
                }
                Text(imageGenerator.isGenerating ? "生成中..." : title)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(.blue)
            )
            .foregroundColor(.white)
        }
        .disabled(imageGenerator.isGenerating)
        .padding(.horizontal)
    }
}

struct GenerationProgressView: View {
    let progress: GenerationProgress
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                VStack(alignment: .leading) {
                    Text(progress.stage.title)
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(progress.message)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.blue.opacity(0.1))
        )
    }
}

struct GeneratedImageView: View {
    let image: GeneratedImage
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundColor(.green)
                Text("生成成功")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(DateFormatter.localizedString(from: image.createdAt, dateStyle: .none, timeStyle: .short))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            // 生成的图片
            AsyncImage(url: URL(string: image.imageUrl)) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(height: 300)
                case .success(let uiImage):
                    uiImage
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                case .failure(_):
                    Image(systemName: "photo")
                        .font(.system(size: 50))
                        .foregroundColor(.gray)
                        .frame(height: 300)
                @unknown default:
                    EmptyView()
                }
            }
            
            // 图片信息
            VStack(alignment: .leading, spacing: 8) {
                ImageInfoRow(title: "风格", value: image.style.displayName)
                ImageInfoRow(title: "质量", value: image.quality.displayName)
                
                if let revisedPrompt = image.revisedPrompt {
                    Text("优化后的提示词:")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(revisedPrompt)
                        .font(.caption)
                        .padding(8)
                        .background(.gray.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            
            // 操作按钮
            HStack {
                Button("保存图片") {
                    // TODO: 实现保存功能
                }
                .buttonStyle(.bordered)
                
                Spacer()
                
                Button("分享") {
                    // TODO: 实现分享功能
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

struct ImageInfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
            Spacer()
        }
    }
}

#Preview {
    ImageGeneratorTestView()
}