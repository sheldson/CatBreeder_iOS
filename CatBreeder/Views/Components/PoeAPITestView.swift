//
//  PoeAPITestView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import SwiftUI
import Foundation

struct PoeAPITestView: View {
    @ObservedObject private var apiService = PoeAPIService.shared
    @State private var isLoading = false
    @State private var result = ""
    @State private var errorMessage = ""
    @State private var testPrompt = "你好，这是一个测试消息。请用中文回复'API连接成功'。"
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                VStack(spacing: 10) {
                    Text("🔌 POE API 测试工具")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    HStack {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 12, height: 12)
                        Text(statusText)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                
                // 测试输入
                VStack(alignment: .leading, spacing: 12) {
                    Text("测试消息")
                        .font(.headline)
                    
                    TextEditor(text: $testPrompt)
                        .padding(8)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(.gray.opacity(0.3), lineWidth: 1)
                        )
                        .frame(height: 100)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.ultraThinMaterial)
                )
                
                // 测试按钮
                VStack(spacing: 12) {
                    Button(action: testConnection) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "network")
                            }
                            Text(isLoading ? "测试中..." : "测试连接")
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
                    
                    Button(action: testCustomMessage) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "text.bubble")
                            }
                            Text(isLoading ? "生成中..." : "自定义测试")
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.green)
                        )
                        .foregroundColor(.white)
                    }
                    .disabled(isLoading || testPrompt.isEmpty)
                }
                .padding(.horizontal)
                
                // 结果显示
                if !result.isEmpty || !errorMessage.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("测试结果")
                            .font(.headline)
                        
                        ScrollView {
                            VStack(alignment: .leading, spacing: 8) {
                                if !errorMessage.isEmpty {
                                    Text("❌ 错误:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.red)
                                    
                                    Text(errorMessage)
                                        .font(.body)
                                        .foregroundColor(.red)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(.red.opacity(0.1))
                                        )
                                }
                                
                                if !result.isEmpty {
                                    Text("✅ 成功:")
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(.green)
                                    
                                    Text(result)
                                        .font(.body)
                                        .padding(8)
                                        .background(
                                            RoundedRectangle(cornerRadius: 6)
                                                .fill(.green.opacity(0.1))
                                        )
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                    )
                }
                
                Spacer()
                
                // 说明
                Text("💡 使用Config.swift中配置的API Key")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("API测试")
        }
    }
    
    private var statusColor: Color {
        if isLoading { return .orange }
        if !result.isEmpty { return .green }
        if !errorMessage.isEmpty { return .red }
        return .gray
    }
    
    private var statusText: String {
        if isLoading { return "测试中..." }
        if !result.isEmpty { return "连接正常" }
        if !errorMessage.isEmpty { return "连接异常" }
        return "等待测试"
    }
    
    private func testConnection() {
        Task {
            await performTest {
                let success = await apiService.testConnection()
                if success {
                    return "✅ API连接测试成功！"
                } else {
                    throw NSError(domain: "TestError", code: 500, userInfo: [
                        NSLocalizedDescriptionKey: "API连接测试失败"
                    ])
                }
            }
        }
    }
    
    private func testCustomMessage() {
        Task {
            await performTest {
                return try await apiService.generateText(prompt: testPrompt)
            }
        }
    }
    
    private func performTest(_ operation: @escaping () async throws -> String) async {
        await MainActor.run {
            isLoading = true
            result = ""
            errorMessage = ""
        }
        
        do {
            let response = try await operation()
            await MainActor.run {
                result = response
                errorMessage = ""
                isLoading = false
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                result = ""
                isLoading = false
            }
        }
    }
}

#Preview {
    PoeAPITestView()
}

