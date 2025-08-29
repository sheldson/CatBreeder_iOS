//
//  CatDescriptionTestView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import SwiftUI

struct CatDescriptionTestView: View {
    @State private var testCat: Cat
    @State private var fullDescription = ""
    @State private var simpleDescription = ""
    @State private var aiKeywords: [String] = []
    
    private let descriptionGenerator = CatDescriptionGenerator.shared
    
    init() {
        // 创建一个测试猫咪
        let genetics = GeneticsData(
            sex: .female,
            baseColor: .red,
            dilution: .dense,
            pattern: .tortoiseshell,
            white: WhitePattern(distribution: .bicolor, percentage: 30.0),
            modifiers: [.golden]
        )
        _testCat = State(initialValue: Cat(genetics: genetics))
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 猫咪预览
                    VStack(spacing: 10) {
                        Text("🐱 测试猫咪")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        CatCardView(cat: testCat, size: .medium)
                            .padding()
                    }
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                    
                    // 生成按钮
                    Button("生成描述") {
                        generateDescriptions()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    // 描述结果
                    if !fullDescription.isEmpty {
                        DescriptionSection(
                            title: "完整描述",
                            content: fullDescription,
                            icon: "doc.text"
                        )
                    }
                    
                    if !simpleDescription.isEmpty {
                        DescriptionSection(
                            title: "简化描述",
                            content: simpleDescription,
                            icon: "text.quote"
                        )
                    }
                    
                    if !aiKeywords.isEmpty {
                        AIKeywordsSection(keywords: aiKeywords)
                    }
                    
                    // 重新生成测试猫咪按钮
                    Button("生成新的测试猫咪") {
                        generateNewTestCat()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.secondary)
                }
                .padding()
            }
            .navigationTitle("描述生成测试")
            .onAppear {
                generateDescriptions()
            }
        }
    }
    
    private func generateDescriptions() {
        fullDescription = descriptionGenerator.generateDescription(for: testCat)
        simpleDescription = descriptionGenerator.generateSimpleDescription(for: testCat)
        aiKeywords = descriptionGenerator.generateAIPromptKeywords(for: testCat)
    }
    
    private func generateNewTestCat() {
        let newGenetics = GeneticsData.random()
        testCat = Cat(genetics: newGenetics)
        generateDescriptions()
    }
}

struct DescriptionSection: View {
    let title: String
    let content: String
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(title)
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            Text(content)
                .font(.body)
                .padding()
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

struct AIKeywordsSection: View {
    let keywords: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "paintbrush")
                    .foregroundColor(.purple)
                Text("AI绘画关键词")
                    .font(.headline)
                    .fontWeight(.semibold)
            }
            
            LazyVGrid(columns: [
                GridItem(.adaptive(minimum: 100), spacing: 8)
            ], spacing: 8) {
                ForEach(keywords, id: \.self) { keyword in
                    Text(keyword)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(
                            RoundedRectangle(cornerRadius: 6)
                                .fill(.purple.opacity(0.2))
                        )
                        .foregroundColor(.purple)
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

#Preview {
    CatDescriptionTestView()
}