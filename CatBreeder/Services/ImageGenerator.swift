//
//  ImageGenerator.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import Foundation
import SwiftUI

// MARK: - AI图片生成器
class ImageGenerator: ObservableObject {
    static let shared = ImageGenerator()
    
    private let apiService = PoeAPIService.shared
    private let promptOptimizer = PromptOptimizer.shared
    private let cache = PromptCache.shared
    
    @Published var isGenerating = false
    @Published var generationProgress: GenerationProgress?
    
    private init() {}
    
    // MARK: - 主要生成方法
    
    /// 从合成汇总生成AI图片（推荐方法）
    func generateCatImageFromSummary(
        from summary: BreedingSummary,
        style: ImageStyle = .realistic,
        quality: ImageQuality = .standard
    ) async throws -> GeneratedImage {
        
        let totalStartTime = Date()
        print("🚀 [ImageGenerator] 开始基于合成汇总的图片生成流程")
        
        await MainActor.run {
            isGenerating = true
            generationProgress = GenerationProgress(
                stage: .preparingPrompt,
                message: "准备基于详细合成信息生成描述..."
            )
        }
        
        do {
            // 步骤1：基于合成汇总生成详细描述
            let promptStartTime = Date()
            print("📝 [ImageGenerator] 步骤1开始：基于合成汇总生成描述")
            await updateProgress(stage: .optimizingPrompt, message: "基于详细合成信息优化prompt...")
            
            // 生成专注的AI描述（包含所有关键遗传信息）
            let focusedDescription = CatDescriptionGenerator.shared.generateFocusedAIDescription(from: summary)
            print("🎯 [ImageGenerator] 专注描述: \(focusedDescription)")
            print("📋 [ImageGenerator] 原始汇总: \(summary.detailedColorDescription)")
            
            // 构建最终的prompt
            let optimizedPrompt = buildFinalPrompt(from: focusedDescription)
            
            let promptDuration = Date().timeIntervalSince(promptStartTime)
            print("✅ [ImageGenerator] 步骤1完成：描述生成耗时 \(String(format: "%.4f", promptDuration))秒")
            
            // 后续步骤与原来相同...
            return try await continueImageGeneration(
                prompt: optimizedPrompt,
                style: style,
                quality: quality,
                totalStartTime: totalStartTime,
                promptDuration: promptDuration
            )
        } catch {
            let totalDuration = Date().timeIntervalSince(totalStartTime)
            await MainActor.run {
                isGenerating = false
            }
            print("❌ [ImageGenerator] 生成失败，总耗时 \(String(format: "%.2f", totalDuration))秒，错误: \(error.localizedDescription)")
            throw error
        }
    }
    
    /// 从猫咪数据生成AI图片（兼容方法）
    func generateCatImage(
        from cat: Cat,
        style: ImageStyle = .realistic,
        quality: ImageQuality = .standard
    ) async throws -> GeneratedImage {
        
        let totalStartTime = Date()
        print("🚀 [ImageGenerator] 开始生成图片流程 - 总计时开始")
        
        await MainActor.run {
            isGenerating = true
            generationProgress = GenerationProgress(
                stage: .preparingPrompt,
                message: "准备生成描述..."
            )
        }
        
        do {
            // 步骤1：优化prompt
            let promptStartTime = Date()
            print("📝 [ImageGenerator] 步骤1开始：优化AI绘画提示词")
            await updateProgress(stage: .optimizingPrompt, message: "优化AI绘画提示词...")
            let optimizedPrompt = try await promptOptimizer.optimizeForAIArt(cat: cat)
            let promptDuration = Date().timeIntervalSince(promptStartTime)
            print("✅ [ImageGenerator] 步骤1完成：Prompt优化耗时 \(String(format: "%.2f", promptDuration))秒")
            
            // 步骤2：添加风格和质量修饰符
            let buildStartTime = Date()
            print("🎨 [ImageGenerator] 步骤2开始：构建最终Prompt")
            let finalPrompt = buildFinalPrompt(
                basePrompt: optimizedPrompt,
                style: style,
                quality: quality
            )
            let buildDuration = Date().timeIntervalSince(buildStartTime)
            print("✅ [ImageGenerator] 步骤2完成：构建Prompt耗时 \(String(format: "%.4f", buildDuration))秒")
            print("📄 [ImageGenerator] 最终Prompt长度: \(finalPrompt.count)字符")
            print("🎯 [ImageGenerator] 发送给AI的最终Prompt:")
            print("   \(finalPrompt)")
            
            // 步骤3：检查图片缓存或生成图片
            let imageStartTime = Date()
            print("🖼️ [ImageGenerator] 步骤3开始：检查缓存或生成图片")
            
            // 先检查缓存
            var imageUrl: String?
            var revisedPrompt: String?
            
            if let cachedUrl = cache.getCachedImageUrl(for: finalPrompt, style: style, quality: quality) {
                print("⚡ [ImageGenerator] 图片缓存命中，跳过API调用")
                imageUrl = cachedUrl
                await updateProgress(stage: .generatingImage, message: "从缓存加载图片...")
            } else {
                print("📡 [ImageGenerator] 缓存未命中，调用POE API生成图片")
                await updateProgress(stage: .generatingImage, message: "正在生成图片...")
                let imageResponse = try await generateImageWithRetry(
                    prompt: finalPrompt,
                    maxRetries: 2
                )
                
                guard let imageData = imageResponse.data.first else {
                    throw ImageGenerationError.noImageGenerated
                }
                
                imageUrl = imageData.url
                revisedPrompt = imageData.revisedPrompt
                
                // 缓存结果
                cache.cacheImageResult(imageData.url, for: finalPrompt, style: style, quality: quality)
            }
            
            let imageDuration = Date().timeIntervalSince(imageStartTime)
            print("✅ [ImageGenerator] 步骤3完成：图片获取耗时 \(String(format: "%.2f", imageDuration))秒")
            
            // 步骤4：处理结果
            let processStartTime = Date()
            print("⚙️ [ImageGenerator] 步骤4开始：处理生成结果")
            await updateProgress(stage: .processingResult, message: "处理生成结果...")
            
            guard let finalImageUrl = imageUrl else {
                throw ImageGenerationError.noImageGenerated
            }
            
            let generatedImage = GeneratedImage(
                id: UUID(),
                cat: cat,
                imageUrl: finalImageUrl,
                originalPrompt: optimizedPrompt,
                finalPrompt: finalPrompt,
                revisedPrompt: revisedPrompt,
                style: style,
                quality: quality,
                createdAt: Date()
            )
            let processDuration = Date().timeIntervalSince(processStartTime)
            print("✅ [ImageGenerator] 步骤4完成：结果处理耗时 \(String(format: "%.4f", processDuration))秒")
            
            let totalDuration = Date().timeIntervalSince(totalStartTime)
            print("🎉 [ImageGenerator] 🎉 总流程完成！")
            print("📊 [ImageGenerator] === 耗时统计 ===")
            print("📊 [ImageGenerator] Prompt优化: \(String(format: "%.2f", promptDuration))秒 (\(String(format: "%.1f", promptDuration/totalDuration*100))%)")
            print("📊 [ImageGenerator] Prompt构建: \(String(format: "%.4f", buildDuration))秒 (\(String(format: "%.1f", buildDuration/totalDuration*100))%)")
            print("📊 [ImageGenerator] 图片生成: \(String(format: "%.2f", imageDuration))秒 (\(String(format: "%.1f", imageDuration/totalDuration*100))%)")
            print("📊 [ImageGenerator] 结果处理: \(String(format: "%.4f", processDuration))秒 (\(String(format: "%.1f", processDuration/totalDuration*100))%)")
            print("📊 [ImageGenerator] === 总耗时: \(String(format: "%.2f", totalDuration))秒 ===")
            
            await MainActor.run {
                isGenerating = false
                generationProgress = nil
            }
            
            return generatedImage
            
        } catch {
            let totalDuration = Date().timeIntervalSince(totalStartTime)
            print("❌ [ImageGenerator] 生成失败，总耗时 \(String(format: "%.2f", totalDuration))秒，错误: \(error.localizedDescription)")
            await MainActor.run {
                isGenerating = false
                generationProgress = nil
            }
            throw error
        }
    }
    
    /// 从自定义prompt生成图片
    func generateImage(
        from prompt: String,
        style: ImageStyle = .realistic,
        quality: ImageQuality = .standard
    ) async throws -> GeneratedImage {
        
        await MainActor.run {
            isGenerating = true
            generationProgress = GenerationProgress(
                stage: .preparingPrompt,
                message: "准备生成图片..."
            )
        }
        
        do {
            let finalPrompt = buildFinalPrompt(
                basePrompt: prompt,
                style: style,
                quality: quality
            )
            
            await updateProgress(stage: .generatingImage, message: "正在生成图片...")
            let imageResponse = try await generateImageWithRetry(
                prompt: finalPrompt,
                maxRetries: 2
            )
            
            await updateProgress(stage: .processingResult, message: "处理生成结果...")
            
            guard let imageData = imageResponse.data.first else {
                throw ImageGenerationError.noImageGenerated
            }
            
            let generatedImage = GeneratedImage(
                id: UUID(),
                cat: nil,
                imageUrl: imageData.url,
                originalPrompt: prompt,
                finalPrompt: finalPrompt,
                revisedPrompt: imageData.revisedPrompt,
                style: style,
                quality: quality,
                createdAt: Date()
            )
            
            await MainActor.run {
                isGenerating = false
                generationProgress = nil
            }
            
            return generatedImage
            
        } catch {
            await MainActor.run {
                isGenerating = false
                generationProgress = nil
            }
            throw error
        }
    }
    
    // MARK: - 私有辅助方法
    
    /// 智能重试机制的图片生成
    private func generateImageWithRetry(
        prompt: String,
        maxRetries: Int? = nil
    ) async throws -> ImageGenerationResponse {
        let actualMaxRetries = maxRetries ?? AppConfig.maxRetryAttempts
        var lastError: Error?
        let retryStartTime = Date()
        
        print("🔄 [ImageGenerator] 开始智能重试逻辑，最大重试次数: \(actualMaxRetries)")
        
        for attempt in 1...(actualMaxRetries + 1) {
            let attemptStartTime = Date()
            
            do {
                if attempt > 1 {
                    // 智能退避策略：根据尝试次数递增延迟时间
                    let delaySeconds = min(
                        AppConfig.baseRetryDelay * Double(attempt - 1),
                        AppConfig.maxRetryDelay
                    )
                    
                    print("⏰ [ImageGenerator] 第\(attempt)次尝试前智能等待 \(String(format: "%.1f", delaySeconds))秒...")
                    await updateProgress(
                        stage: .generatingImage, 
                        message: "网络繁忙，智能重试中... (尝试 \(attempt)/\(actualMaxRetries + 1))"
                    )
                    
                    // 智能延迟重试
                    try await Task.sleep(nanoseconds: UInt64(delaySeconds * 1_000_000_000))
                    print("✅ [ImageGenerator] 智能等待完成，开始第\(attempt)次尝试")
                }
                
                print("📡 [ImageGenerator] 第\(attempt)次尝试：调用POE API (超时限制: \(String(format: "%.0f", AppConfig.imageGenerationTimeout))秒)...")
                
                // 使用配置的超时时间
                let response = try await withTimeout(AppConfig.imageGenerationTimeout) { [self] in
                    try await apiService.generateImage(
                        prompt: prompt,
                        model: "GPT-Image-1"
                    )
                }
                
                let attemptDuration = Date().timeIntervalSince(attemptStartTime)
                let totalRetryDuration = Date().timeIntervalSince(retryStartTime)
                print("✅ [ImageGenerator] 第\(attempt)次尝试成功！")
                print("📊 [ImageGenerator] 本次尝试耗时: \(String(format: "%.2f", attemptDuration))秒")
                print("📊 [ImageGenerator] 总重试耗时: \(String(format: "%.2f", totalRetryDuration))秒")
                
                return response
                
            } catch {
                let attemptDuration = Date().timeIntervalSince(attemptStartTime)
                print("❌ [ImageGenerator] 第\(attempt)次尝试失败，耗时 \(String(format: "%.2f", attemptDuration))秒")
                print("❌ [ImageGenerator] 错误详情: \(error.localizedDescription)")
                
                lastError = error
                
                // 智能错误分析和重试策略
                let shouldRetry = shouldRetryForError(error, attempt: attempt, maxRetries: actualMaxRetries)
                
                if shouldRetry {
                    print("🔄 [ImageGenerator] 错误分析：建议重试 (剩余重试次数: \(actualMaxRetries + 1 - attempt))")
                    continue
                } else {
                    print("🚨 [ImageGenerator] 错误分析：不建议重试，直接抛出")
                    throw error
                }
            }
        }
        
        let totalRetryDuration = Date().timeIntervalSince(retryStartTime)
        print("💀 [ImageGenerator] 所有重试都失败了，总重试耗时: \(String(format: "%.2f", totalRetryDuration))秒")
        
        // 所有重试都失败了
        throw ImageGenerationError.apiError("生成图片失败，已智能重试\(actualMaxRetries)次。最后错误: \(lastError?.localizedDescription ?? "未知错误")")
    }
    
    /// 智能错误分析：判断是否应该重试
    private func shouldRetryForError(_ error: Error, attempt: Int, maxRetries: Int) -> Bool {
        // 如果已达到最大重试次数，不再重试
        guard attempt <= maxRetries else { return false }
        
        // 分析错误类型
        if let nsError = error as NSError? {
            switch nsError.domain {
            case NSURLErrorDomain:
                switch nsError.code {
                case NSURLErrorTimedOut:
                    print("⏱️ [ImageGenerator] 超时错误 - 建议重试")
                    return true
                case NSURLErrorNetworkConnectionLost, NSURLErrorNotConnectedToInternet:
                    print("🌐 [ImageGenerator] 网络连接错误 - 建议重试")
                    return true
                case NSURLErrorCannotFindHost, NSURLErrorDNSLookupFailed:
                    print("🔍 [ImageGenerator] DNS/主机错误 - 建议重试")
                    return true
                case NSURLErrorHTTPTooManyRedirects, NSURLErrorRedirectToNonExistentLocation:
                    print("🔄 [ImageGenerator] 重定向错误 - 不重试")
                    return false
                case NSURLErrorBadURL, NSURLErrorUnsupportedURL:
                    print("🚫 [ImageGenerator] URL错误 - 不重试")
                    return false
                default:
                    print("❓ [ImageGenerator] 其他网络错误 (代码: \(nsError.code)) - 建议重试")
                    return true
                }
            default:
                break
            }
        }
        
        // 检查HTTP状态码错误
        if let httpError = error as? URLError,
           let response = httpError.userInfo["NSHTTPURLResponse"] as? HTTPURLResponse {
            switch response.statusCode {
            case 500...599:
                print("🔧 [ImageGenerator] 服务器错误 (\(response.statusCode)) - 建议重试")
                return true
            case 429:
                print("⚡ [ImageGenerator] 请求过于频繁 (429) - 建议重试")
                return true
            case 401, 403:
                print("🔐 [ImageGenerator] 认证/权限错误 (\(response.statusCode)) - 不重试")
                return false
            case 400...499:
                print("📝 [ImageGenerator] 客户端错误 (\(response.statusCode)) - 不重试")
                return false
            default:
                print("❓ [ImageGenerator] 未知HTTP错误 (\(response.statusCode)) - 建议重试")
                return true
            }
        }
        
        // 默认建议重试（保守策略）
        print("🤔 [ImageGenerator] 未知错误类型 - 保守重试")
        return true
    }
    
    /// 带超时的异步任务执行
    private func withTimeout<T>(_ timeout: TimeInterval, _ operation: @escaping () async throws -> T) async throws -> T {
        return try await withThrowingTaskGroup(of: T.self) { group in
            // 添加主要操作
            group.addTask {
                try await operation()
            }
            
            // 添加超时任务
            group.addTask {
                try await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorTimedOut, userInfo: [
                    NSLocalizedDescriptionKey: "操作超时（\(Int(timeout))秒）"
                ])
            }
            
            // 返回第一个完成的结果
            guard let result = try await group.next() else {
                throw NSError(domain: NSURLErrorDomain, code: NSURLErrorUnknown, userInfo: [
                    NSLocalizedDescriptionKey: "任务组意外终止"
                ])
            }
            
            // 取消其他任务
            group.cancelAll()
            return result
        }
    }
    
    private func updateProgress(stage: GenerationStage, message: String) async {
        await MainActor.run {
            generationProgress = GenerationProgress(stage: stage, message: message)
        }
    }
    
    private func buildFinalPrompt(
        basePrompt: String,
        style: ImageStyle,
        quality: ImageQuality
    ) -> String {
        var components = [basePrompt]
        
        // 添加风格修饰符
        if !style.modifiers.isEmpty {
            components.append(style.modifiers)
        }
        
        // 添加质量修饰符
        if !quality.modifiers.isEmpty {
            components.append(quality.modifiers)
        }
        
        return components.joined(separator: ", ")
    }
    
    // MARK: - 新的简化方法
    
    /// 基于专注描述构建简洁prompt
    private func buildFinalPrompt(from focusedDescription: String) -> String {
        var components: [String] = []
        
        // 核心描述：全身照展示完整特征
        components.append("Full body cat")
        components.append("standing pose")
        components.append(focusedDescription)
        components.append("whole body visible")
        components.append("complete cat from head to tail")
        
        // 基础质量要求（简化）
        components.append("professional photography")
        components.append("high quality")
        components.append("detailed")
        
        let prompt = components.joined(separator: ", ")
        print("🎯 [ImageGenerator] 最终prompt构建完成: \(prompt)")
        
        return prompt
    }
    
    /// 基于详细描述构建简化prompt（保留用于兼容性）
    private func buildSimplifiedPrompt(from description: String, summary: BreedingSummary) -> String {
        var components: [String] = []
        
        // 核心描述：直接使用详细的合成汇总
        components.append("Cat portrait:")
        components.append(description)
        
        // 基础质量和风格要求
        components.append("professional photography")
        components.append("detailed fur texture")
        components.append("clear eyes")
        components.append("good lighting")
        
        let prompt = components.joined(separator: ", ")
        print("🎯 [ImageGenerator] 简化prompt构建完成: \(prompt)")
        
        return prompt
    }
    
    /// 继续图片生成流程（共用逻辑）
    private func continueImageGeneration(
        prompt: String,
        style: ImageStyle,
        quality: ImageQuality,
        totalStartTime: Date,
        promptDuration: TimeInterval
    ) async throws -> GeneratedImage {
        
        // 步骤2：构建最终Prompt
        let buildStartTime = Date()
        print("🎨 [ImageGenerator] 步骤2开始：构建最终Prompt")
        let finalPrompt = buildFinalPrompt(
            basePrompt: prompt,
            style: style,
            quality: quality
        )
        let buildDuration = Date().timeIntervalSince(buildStartTime)
        print("✅ [ImageGenerator] 步骤2完成：构建Prompt耗时 \(String(format: "%.4f", buildDuration))秒")
        print("📄 [ImageGenerator] 最终Prompt长度: \(finalPrompt.count)字符")
        print("🎯 [ImageGenerator] 发送给AI的最终Prompt:")
        print("   \(finalPrompt)")
        
        // 步骤3：检查图片缓存或生成图片
        let imageStartTime = Date()
        print("🖼️ [ImageGenerator] 步骤3开始：检查缓存或生成图片")
        
        // 先检查缓存
        var imageUrl: String?
        var revisedPrompt: String?
        
        if let cachedUrl = cache.getCachedImageUrl(for: finalPrompt, style: style, quality: quality) {
            print("⚡ [ImageGenerator] 图片缓存命中，跳过API调用")
            imageUrl = cachedUrl
            revisedPrompt = nil
        } else {
            print("📡 [ImageGenerator] 缓存未命中，调用POE API生成图片")
            
            // 调用API生成图片
            let response = try await generateImageWithRetry(prompt: finalPrompt)
            imageUrl = response.data.first?.url
            revisedPrompt = response.data.first?.revisedPrompt
            
            // 缓存结果
            if let url = imageUrl {
                cache.cacheImageResult(url, for: finalPrompt, style: style, quality: quality)
                print("✅ [PromptCache] 图片结果已缓存")
            }
        }
        
        let imageDuration = Date().timeIntervalSince(imageStartTime)
        print("✅ [ImageGenerator] 步骤3完成：图片获取耗时 \(String(format: "%.2f", imageDuration))秒")
        
        // 步骤4：处理生成结果
        let processStartTime = Date()
        print("⚙️ [ImageGenerator] 步骤4开始：处理生成结果")
        
        guard let finalImageUrl = imageUrl else {
            throw NSError(domain: "ImageGenerator", code: 500, userInfo: [
                NSLocalizedDescriptionKey: "未能获取图片URL"
            ])
        }
        
        let result = GeneratedImage(
            id: UUID(),
            cat: nil, // 基于summary生成时无Cat对象
            imageUrl: finalImageUrl,
            originalPrompt: prompt,
            finalPrompt: finalPrompt,
            revisedPrompt: revisedPrompt,
            style: style,
            quality: quality,
            createdAt: Date()
        )
        
        let processDuration = Date().timeIntervalSince(processStartTime)
        print("✅ [ImageGenerator] 步骤4完成：结果处理耗时 \(String(format: "%.4f", processDuration))秒")
        
        await MainActor.run {
            isGenerating = false
        }
        
        // 统计信息
        let totalDuration = Date().timeIntervalSince(totalStartTime)
        print("🎉 [ImageGenerator] 🎉 总流程完成！")
        print("📊 [ImageGenerator] === 耗时统计 ===")
        print("📊 [ImageGenerator] Prompt优化: \(String(format: "%.2f", promptDuration))秒 (\(String(format: "%.1f", promptDuration/totalDuration*100))%)")
        print("📊 [ImageGenerator] Prompt构建: \(String(format: "%.4f", buildDuration))秒 (\(String(format: "%.1f", buildDuration/totalDuration*100))%)")
        print("📊 [ImageGenerator] 图片生成: \(String(format: "%.2f", imageDuration))秒 (\(String(format: "%.1f", imageDuration/totalDuration*100))%)")
        print("📊 [ImageGenerator] 结果处理: \(String(format: "%.4f", processDuration))秒 (\(String(format: "%.1f", processDuration/totalDuration*100))%)")
        print("📊 [ImageGenerator] === 总耗时: \(String(format: "%.2f", totalDuration))秒 ===")
        
        return result
    }
}

// MARK: - 数据模型

/// 生成的图片数据
struct GeneratedImage: Identifiable {
    let id: UUID
    let cat: Cat?
    let imageUrl: String
    let originalPrompt: String
    let finalPrompt: String
    let revisedPrompt: String?
    let style: ImageStyle
    let quality: ImageQuality
    let createdAt: Date
}

/// 生成进度
struct GenerationProgress {
    let stage: GenerationStage
    let message: String
}

/// 生成阶段
enum GenerationStage {
    case preparingPrompt
    case optimizingPrompt
    case generatingImage
    case processingResult
    
    var title: String {
        switch self {
        case .preparingPrompt: return "准备阶段"
        case .optimizingPrompt: return "优化提示词"
        case .generatingImage: return "生成图片"
        case .processingResult: return "处理结果"
        }
    }
}

/// 图片风格
enum ImageStyle: String, CaseIterable {
    case realistic = "realistic"
    case digital = "digital"
    case painting = "painting"
    case watercolor = "watercolor"
    case cartoon = "cartoon"
    
    var displayName: String {
        switch self {
        case .realistic: return "真实摄影"
        case .digital: return "数字艺术"
        case .painting: return "油画风格"
        case .watercolor: return "水彩画"
        case .cartoon: return "卡通风格"
        }
    }
    
    var modifiers: String {
        switch self {
        case .realistic:
            return "professional photography, studio lighting, realistic, detailed"
        case .digital:
            return "digital art, concept art, trending on artstation"
        case .painting:
            return "oil painting, artistic, painted, brush strokes"
        case .watercolor:
            return "watercolor painting, soft colors, artistic"
        case .cartoon:
            return "cartoon style, animated, stylized, cute"
        }
    }
}

/// 图片质量
enum ImageQuality: String, CaseIterable {
    case standard = "standard"
    case high = "high"
    case premium = "premium"
    
    var displayName: String {
        switch self {
        case .standard: return "标准质量"
        case .high: return "高质量"
        case .premium: return "专业级"
        }
    }
    
    var imageSize: String {
        switch self {
        case .standard: return "1024x1024"
        case .high: return "1024x1024"
        case .premium: return "1792x1024"
        }
    }
    
    var apiQuality: String {
        switch self {
        case .standard: return "standard"
        case .high: return "hd"
        case .premium: return "hd"
        }
    }
    
    var modifiers: String {
        switch self {
        case .standard:
            return "good quality, detailed"
        case .high:
            return "high quality, highly detailed, sharp focus"
        case .premium:
            return "masterpiece, best quality, ultra detailed, award winning, professional"
        }
    }
}

/// 图片生成错误
enum ImageGenerationError: LocalizedError {
    case noImageGenerated
    case invalidPrompt
    case apiError(String)
    
    var errorDescription: String? {
        switch self {
        case .noImageGenerated:
            return "未能生成图片"
        case .invalidPrompt:
            return "无效的提示词"
        case .apiError(let message):
            return "API错误: \(message)"
        }
    }
}