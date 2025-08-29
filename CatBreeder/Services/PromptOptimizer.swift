//
//  PromptOptimizer.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import Foundation

// MARK: - AI绘画Prompt优化器
class PromptOptimizer {
    static let shared = PromptOptimizer()
    
    private let apiService = PoeAPIService.shared
    private let descriptionGenerator = CatDescriptionGenerator.shared
    private let cache = PromptCache.shared
    
    private init() {}
    
    // MARK: - 主要优化方法
    
    /// 将猫咪描述优化为专业AI绘画prompt（简化版本）
    func optimizeForAIArt(cat: Cat) async throws -> String {
        print("🎯 [PromptOptimizer] 开始简化Prompt优化流程")
        
        // 检查缓存
        if let cachedPrompt = cache.getCachedPrompt(for: cat) {
            print("⚡ [PromptOptimizer] 缓存命中，直接返回结果")
            return cachedPrompt
        }
        
        // 直接生成简洁的prompt，不再调用外部API
        print("📝 [PromptOptimizer] 生成简洁AI描述")
        let keywords = descriptionGenerator.generateAIPromptKeywords(for: cat)
        let mainKeywords = Array(keywords.prefix(6)) // 只取前6个关键词
        
        let simplePrompt = mainKeywords.joined(separator: ", ")
        print("✅ [PromptOptimizer] 简洁prompt生成完成: \(simplePrompt)")
        
        // 缓存结果
        cache.cachePrompt(simplePrompt, for: cat)
        
        return simplePrompt
    }
    
    /// 生成多个风格变体的prompt（简化版本）
    func generateStyleVariants(cat: Cat) async throws -> [StyleVariant] {
        print("🎨 [PromptOptimizer] 生成简化风格变体")
        
        let keywords = descriptionGenerator.generateAIPromptKeywords(for: cat)
        let baseKeywords = Array(keywords.prefix(4)).joined(separator: ", ")
        
        let styles = [
            ("真实摄影", "realistic photography"),
            ("数字艺术", "digital art"),
            ("油画风格", "oil painting"),
            ("水彩画", "watercolor"),
            ("卡通风格", "cartoon style")
        ]
        
        var variants: [StyleVariant] = []
        
        for (chineseName, englishStyle) in styles {
            // 直接生成简洁的风格prompt，不调用API
            let stylePrompt = "\(baseKeywords), \(englishStyle), high quality, detailed"
            variants.append(StyleVariant(
                styleName: chineseName,
                englishName: englishStyle,
                prompt: stylePrompt
            ))
        }
        
        print("✅ [PromptOptimizer] 风格变体生成完成，共\(variants.count)个")
        return variants
    }
    
    // MARK: - 私有辅助方法
    
    private func buildOptimizationPrompt(
        basicDescription: String,
        keywords: [String],
        cat: Cat
    ) -> String {
        return """
        你是一个专业的AI绘画prompt专家。请根据以下猫咪信息，生成一个高质量的AI绘画prompt。

        猫咪描述: \(basicDescription)
        关键词: \(keywords.joined(separator: ", "))
        稀有度: \(cat.rarity.rawValue)

        请生成一个详细的英文绘画prompt，要求：
        1. 使用专业的艺术描述词汇
        2. 包含光线、构图、质量描述
        3. 适合Midjourney或DALL-E等AI绘画工具
        4. 长度控制在200-300个英文单词
        5. 突出猫咪的独特特征

        只返回优化后的prompt，不要其他解释。
        """
    }
    
    private func buildStylePrompt(
        description: String,
        style: String,
        cat: Cat
    ) -> String {
        return """
        请为以下猫咪生成一个\(style)风格的AI绘画prompt：

        猫咪描述: \(description)
        目标风格: \(style)
        稀有度: \(cat.rarity.rawValue)

        要求：
        1. 突出\(style)的特色
        2. 保持猫咪特征准确
        3. 包含适当的技术参数
        4. 英文prompt，简洁专业

        只返回prompt，不要解释。
        """
    }
    
    private func cleanupPrompt(_ prompt: String) -> String {
        var cleaned = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // 移除常见的无用前缀
        let prefixes = ["Here's", "Here is", "The prompt is:", "Prompt:"]
        for prefix in prefixes {
            if cleaned.hasPrefix(prefix) {
                cleaned = String(cleaned.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            }
        }
        
        // 移除多余的引号
        if cleaned.hasPrefix("\"") && cleaned.hasSuffix("\"") {
            cleaned = String(cleaned.dropFirst().dropLast())
        }
        
        return cleaned
    }
    
    private func generateFallbackPrompt(for cat: Cat, style: String) -> String {
        let keywords = descriptionGenerator.generateAIPromptKeywords(for: cat)
        let basicKeywords = keywords.prefix(5).joined(separator: ", ")
        
        return "\(basicKeywords), \(style), high quality, detailed, beautiful lighting, professional photography"
    }
}

// MARK: - 数据模型

/// 风格变体
struct StyleVariant {
    let styleName: String      // 中文风格名
    let englishName: String    // 英文风格名
    let prompt: String         // 优化后的prompt
}

// MARK: - 扩展：预设prompt模板
extension PromptOptimizer {
    
    /// 获取预设的高质量prompt模板
    func getPresetPromptTemplate(for cat: Cat) -> String {
        let keywords = descriptionGenerator.generateAIPromptKeywords(for: cat)
        let mainKeywords = keywords.prefix(8).joined(separator: ", ")
        
        return """
        \(mainKeywords), professional photography, studio lighting, high resolution, detailed fur texture, beautiful composition, sharp focus, depth of field, masterpiece, award winning photography, trending on artstation
        """
    }
    
    /// 获取不同质量等级的prompt
    func getQualityPrompts(for cat: Cat) -> [QualityVariant] {
        let baseKeywords = descriptionGenerator.generateAIPromptKeywords(for: cat)
        let mainDesc = baseKeywords.prefix(5).joined(separator: ", ")
        
        return [
            QualityVariant(
                level: "标准质量",
                prompt: "\(mainDesc), cute, detailed"
            ),
            QualityVariant(
                level: "高质量",
                prompt: "\(mainDesc), high quality, detailed, beautiful lighting, professional"
            ),
            QualityVariant(
                level: "专业级",
                prompt: "\(mainDesc), masterpiece, best quality, ultra detailed, professional photography, studio lighting, sharp focus, depth of field, award winning"
            )
        ]
    }
}

/// 质量等级变体
struct QualityVariant {
    let level: String          // 质量等级名称
    let prompt: String         // 对应的prompt
}