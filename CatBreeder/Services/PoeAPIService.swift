//
//  PoeAPIService.swift
//  CatBreeder
//
//  Created by Sheldon027 on 2025/8/24.
//

import Foundation

// MARK: - POE API响应模型
struct PoeAPIResponse: Codable {
    let choices: [Choice]
    
    struct Choice: Codable {
        let message: Message
    }
    
    struct Message: Codable {
        let content: String
    }
}

// MARK: - 图片生成API模型
struct ImageGenerationRequest: Codable {
    let model: String
    let prompt: String
    let n: Int
    let size: String
    let quality: String
}

struct ImageGenerationResponse: Codable {
    let created: Int
    let data: [ImageData]
}

struct ImageData: Codable {
    let url: String
    let revisedPrompt: String?
    
    enum CodingKeys: String, CodingKey {
        case url
        case revisedPrompt = "revised_prompt"
    }
}

// MARK: - POE API请求模型
struct PoeAPIRequest: Codable {
    let model: String
    let messages: [Message]
    let maxTokens: Int?
    let temperature: Double?
    
    enum CodingKeys: String, CodingKey {
        case model, messages, temperature
        case maxTokens = "max_tokens"
    }
    
    struct Message: Codable {
        let role: String
        let content: String
    }
}

// MARK: - POE API服务
class PoeAPIService: ObservableObject {
    static let shared = PoeAPIService()
    
    private let baseURL = "https://api.poe.com/v1"
    private let session: URLSession
    private let imageSession: URLSession  // 专用于图片生成的session
    
    // 开发模式开关
    @Published var isSimulationMode = true  // 默认使用模拟模式
    
    private init() {
        // 标准请求session
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = AppConfig.requestTimeout
        config.timeoutIntervalForResource = AppConfig.resourceTimeout
        self.session = URLSession(configuration: config)
        
        // 图片生成专用session（更长超时）
        let imageConfig = URLSessionConfiguration.default
        imageConfig.timeoutIntervalForRequest = AppConfig.imageGenerationTimeout
        imageConfig.timeoutIntervalForResource = AppConfig.imageResourceTimeout
        self.imageSession = URLSession(configuration: imageConfig)
    }
    
    // MARK: - 主要方法
    
    func testConnection() async -> Bool {
        if isSimulationMode {
            // 模拟模式
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒延迟
            return true
        } else {
            // 真实API调用
            do {
                let _ = try await generateText(prompt: "测试连接", maxTokens: 10)
                return true
            } catch {
                print("API连接测试失败: \(error.localizedDescription)")
                return false
            }
        }
    }
    
    func generateText(
        prompt: String,
        model: String = AppConfig.defaultTextModel,
        maxTokens: Int = AppConfig.defaultMaxTokens,
        temperature: Double = AppConfig.defaultTemperature
    ) async throws -> String {
        
        if isSimulationMode {
            // 模拟模式 - 返回智能模拟响应
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 2秒延迟
            return generateSimulatedResponse(for: prompt)
        } else {
            // 真实API调用
            return try await callRealAPI(
                prompt: prompt,
                model: model,
                maxTokens: maxTokens,
                temperature: temperature
            )
        }
    }
    
    // MARK: - 真实API调用
    
    private func callRealAPI(
        prompt: String,
        model: String,
        maxTokens: Int,
        temperature: Double
    ) async throws -> String {
        
        guard let apiKey = getAPIKey() else {
            throw NSError(domain: "PoeAPIService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "POE API Key 未配置"
            ])
        }
        
        // 构建请求
        let request = PoeAPIRequest(
            model: model,
            messages: [
                PoeAPIRequest.Message(role: "user", content: prompt)
            ],
            maxTokens: maxTokens,
            temperature: temperature
        )
        
        // 创建URL请求
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw NSError(domain: "PoeAPIService", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "无效的API URL"
            ])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 编码请求体
        urlRequest.httpBody = try JSONEncoder().encode(request)
        
        // 发送请求
        let (data, response) = try await session.data(for: urlRequest)
        
        // 检查HTTP状态码
        if let httpResponse = response as? HTTPURLResponse {
            guard 200...299 ~= httpResponse.statusCode else {
                throw NSError(domain: "PoeAPIService", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "API请求失败，状态码: \(httpResponse.statusCode)"
                ])
            }
        }
        
        // 解析响应
        let apiResponse = try JSONDecoder().decode(PoeAPIResponse.self, from: data)
        
        guard let firstChoice = apiResponse.choices.first else {
            throw NSError(domain: "PoeAPIService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "API响应中未找到结果"
            ])
        }
        
        return firstChoice.message.content
    }
    
    // MARK: - 模拟响应生成器
    
    private func generateSimulatedResponse(for prompt: String) -> String {
        let lowercasePrompt = prompt.lowercased()
        
        // 检测prompt类型并生成相应的模拟响应
        if lowercasePrompt.contains("测试") || lowercasePrompt.contains("test") {
            return "API连接成功"
        }
        
        // AI绘画prompt优化请求
        if lowercasePrompt.contains("ai绘画") || lowercasePrompt.contains("prompt") || lowercasePrompt.contains("绘画") {
            return generateMockArtPrompt(from: prompt)
        }
        
        // 默认回复
        return "这是一个模拟的GPT-4o响应。原始提示：\(prompt.prefix(50))..."
    }
    
    private func generateMockArtPrompt(from originalPrompt: String) -> String {
        // 提取一些关键信息生成逼真的模拟AI绘画prompt
        let mockPrompts = [
            "a beautiful cat with detailed fur texture, professional photography, studio lighting, high quality, sharp focus, depth of field, masterpiece",
            "cute cat, orange tabby, green eyes, sitting pose, soft natural lighting, detailed whiskers, professional pet photography, award winning",
            "majestic cat portrait, golden fur, blue eyes, elegant pose, beautiful composition, high resolution, trending on artstation",
            "adorable kitten, fluffy fur, bright eyes, playful expression, soft lighting, detailed texture, professional quality, stunning details"
        ]
        
        return mockPrompts.randomElement() ?? mockPrompts[0]
    }
    
    // MARK: - 私有方法
    
    private func getAPIKey() -> String? {
        // 优先从环境变量获取（推荐方式）
        if let envKey = ProcessInfo.processInfo.environment["POE_API_KEY"] {
            print("✅ [PoeAPIService] 使用环境变量中的API Key")
            return envKey
        }
        
        // 从配置文件获取（备用方式）
        let configKey = AppConfig.poeAPIKey
        if !configKey.isEmpty && configKey != "your_poe_api_key_here" {
            print("⚠️ [PoeAPIService] 使用配置文件中的API Key（建议使用环境变量）")
            return configKey
        }
        
        print("❌ [PoeAPIService] 未找到API Key，请设置POE_API_KEY环境变量")
        return nil
    }
    
    // MARK: - 图片生成功能
    
    func generateImage(
        prompt: String,
        model: String = "GPT-Image-1", // 使用POE的图片生成模型
        size: String = "1024x1024",
        quality: String = "standard",
        n: Int = 1
    ) async throws -> ImageGenerationResponse {
        
        if isSimulationMode {
            // 模拟模式 - 返回模拟图片URL
            try? await Task.sleep(nanoseconds: 3_000_000_000) // 3秒延迟
            return generateSimulatedImageResponse(for: prompt)
        } else {
            // 真实API调用 - 使用chat completions端点和图片模型
            return try await callPOEImageGenerationAPI(
                prompt: prompt,
                model: model
            )
        }
    }
    
    private func callPOEImageGenerationAPI(
        prompt: String,
        model: String
    ) async throws -> ImageGenerationResponse {
        
        let apiStartTime = Date()
        print("🌐 [PoeAPIService] 开始POE API调用")
        print("🌐 [PoeAPIService] 模型: \(model)")
        print("🌐 [PoeAPIService] Prompt长度: \(prompt.count)字符")
        
        guard let apiKey = getAPIKey() else {
            print("❌ [PoeAPIService] API Key未配置")
            throw NSError(domain: "PoeAPIService", code: 401, userInfo: [
                NSLocalizedDescriptionKey: "POE API Key 未配置"
            ])
        }
        
        // POE图片生成使用chat completions端点，但使用图片模型
        let request = PoeAPIRequest(
            model: model, // GPT-Image-1 或其他图片模型
            messages: [
                PoeAPIRequest.Message(role: "user", content: prompt)
            ],
            maxTokens: nil,
            temperature: nil
        )
        
        // 使用标准的chat completions端点
        guard let url = URL(string: "\(baseURL)/chat/completions") else {
            throw NSError(domain: "PoeAPIService", code: 400, userInfo: [
                NSLocalizedDescriptionKey: "无效的API URL"
            ])
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "POST"
        urlRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
        urlRequest.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        // 编码请求体
        print("📦 [PoeAPIService] 编码请求体...")
        urlRequest.httpBody = try JSONEncoder().encode(request)
        print("✅ [PoeAPIService] 请求体编码完成")
        
        // 发送请求 - 使用专用的图片生成session
        let requestStartTime = Date()
        print("📤 [PoeAPIService] 发送HTTP请求到POE API...")
        let (data, response) = try await imageSession.data(for: urlRequest)
        let requestDuration = Date().timeIntervalSince(requestStartTime)
        print("📥 [PoeAPIService] 收到HTTP响应，网络耗时: \(String(format: "%.2f", requestDuration))秒")
        print("📏 [PoeAPIService] 响应数据大小: \(data.count) 字节")
        
        // 检查HTTP状态码
        if let httpResponse = response as? HTTPURLResponse {
            print("📊 [PoeAPIService] HTTP状态码: \(httpResponse.statusCode)")
            guard 200...299 ~= httpResponse.statusCode else {
                print("❌ [PoeAPIService] HTTP错误，状态码: \(httpResponse.statusCode)")
                throw NSError(domain: "PoeAPIService", code: httpResponse.statusCode, userInfo: [
                    NSLocalizedDescriptionKey: "图片生成API请求失败，状态码: \(httpResponse.statusCode)"
                ])
            }
        }
        
        // 解析chat completions响应
        let parseStartTime = Date()
        print("🔍 [PoeAPIService] 开始解析JSON响应...")
        let apiResponse = try JSONDecoder().decode(PoeAPIResponse.self, from: data)
        let parseDuration = Date().timeIntervalSince(parseStartTime)
        print("✅ [PoeAPIService] JSON解析完成，耗时: \(String(format: "%.4f", parseDuration))秒")
        
        guard let firstChoice = apiResponse.choices.first else {
            print("❌ [PoeAPIService] API响应中没有找到choices")
            throw NSError(domain: "PoeAPIService", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "API响应中未找到结果"
            ])
        }
        
        print("📄 [PoeAPIService] API响应内容长度: \(firstChoice.message.content.count)字符")
        
        // POE图片模型的响应content应该包含图片URL
        let extractStartTime = Date()
        print("🔗 [PoeAPIService] 开始提取图片URL...")
        let extractedUrl = extractImageUrlFromContent(firstChoice.message.content)
        let extractDuration = Date().timeIntervalSince(extractStartTime)
        print("✅ [PoeAPIService] URL提取完成，耗时: \(String(format: "%.4f", extractDuration))秒")
        print("🖼️ [PoeAPIService] 提取的图片URL: \(extractedUrl)")
        
        let totalApiDuration = Date().timeIntervalSince(apiStartTime)
        print("🎯 [PoeAPIService] === API调用完成 ===")
        print("📊 [PoeAPIService] 网络请求: \(String(format: "%.2f", requestDuration))秒 (\(String(format: "%.1f", requestDuration/totalApiDuration*100))%)")
        print("📊 [PoeAPIService] JSON解析: \(String(format: "%.4f", parseDuration))秒 (\(String(format: "%.1f", parseDuration/totalApiDuration*100))%)")
        print("📊 [PoeAPIService] URL提取: \(String(format: "%.4f", extractDuration))秒 (\(String(format: "%.1f", extractDuration/totalApiDuration*100))%)")
        print("📊 [PoeAPIService] === 总API耗时: \(String(format: "%.2f", totalApiDuration))秒 ===")
        
        // 将chat completions响应转换为ImageGenerationResponse格式
        return ImageGenerationResponse(
            created: Int(Date().timeIntervalSince1970),
            data: [
                ImageData(
                    url: extractedUrl,
                    revisedPrompt: prompt
                )
            ]
        )
    }
    
    // 从POE图片模型的响应中提取图片URL
    private func extractImageUrlFromContent(_ content: String) -> String {
        // POE图片模型可能返回markdown格式的图片链接或直接的URL
        // 这里需要根据实际响应格式来解析
        
        // 尝试匹配markdown格式: ![alt](url)
        let markdownPattern = #"!\[.*?\]\((https?://[^\)]+)\)"#
        if let regex = try? NSRegularExpression(pattern: markdownPattern),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let urlRange = Range(match.range(at: 1), in: content) {
            return String(content[urlRange])
        }
        
        // 尝试匹配直接的HTTP URL
        let urlPattern = #"https?://[^\s]+"#
        if let regex = try? NSRegularExpression(pattern: urlPattern),
           let match = regex.firstMatch(in: content, range: NSRange(content.startIndex..., in: content)),
           let urlRange = Range(match.range, in: content) {
            return String(content[urlRange])
        }
        
        // 如果没有找到URL，返回占位符（可能是错误情况）
        return "https://picsum.photos/1024/1024?random=error"
    }
    
    private func generateSimulatedImageResponse(for prompt: String) -> ImageGenerationResponse {
        // 模拟生成的图片URL（使用更稳定的图片服务）
        let mockImageUrls = [
            "https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?w=1024&h=1024&fit=crop",
            "https://images.unsplash.com/photo-1573865526739-10659fec78a5?w=1024&h=1024&fit=crop", 
            "https://images.unsplash.com/photo-1513245543132-31f507417b26?w=1024&h=1024&fit=crop"
        ]
        
        let randomUrl = mockImageUrls.randomElement() ?? mockImageUrls[0]
        
        return ImageGenerationResponse(
            created: Int(Date().timeIntervalSince1970),
            data: [
                ImageData(
                    url: randomUrl,
                    revisedPrompt: "模拟模式生成的图片 - 原始提示：\(prompt.prefix(50))..."
                )
            ]
        )
    }
}