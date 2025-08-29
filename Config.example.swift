//
//  Config.example.swift
//  CatBreeder
//
//  这是配置文件的示例模板
//  使用方法：
//  1. 复制此文件为 Config.swift
//  2. 将 your_poe_api_key_here 替换为真实的API Key
//  3. Config.swift 已被 .gitignore 排除，不会被提交到Git
//

import Foundation

// MARK: - 应用配置
struct AppConfig {
    // POE API配置
    static let poeAPIKey = "your_poe_api_key_here"  // ⚠️ 请替换为真实的API Key
    
    // API端点
    static let poeBaseURL = "https://api.poe.com/v1"
    
    // 模型配置
    static let defaultTextModel = "GPT-4.1"
    static let defaultImageModel = "GPT-Image-1"
    
    // 请求超时设置（秒）- 基于性能分析优化
    static let requestTimeout: TimeInterval = 45        // 从60秒优化到45秒
    static let resourceTimeout: TimeInterval = 90       // 从120秒优化到90秒
    
    // 图片生成专用超时设置（基于实际测试数据优化）
    static let imageGenerationTimeout: TimeInterval = 120  // 从180秒优化到120秒（2分钟）
    static let imageResourceTimeout: TimeInterval = 180    // 从300秒优化到180秒（3分钟）
    
    // Prompt优化超时设置（新增）
    static let promptOptimizationTimeout: TimeInterval = 30  // Prompt优化30秒超时
    
    // 重试策略配置
    static let maxRetryAttempts = 2                     // 最大重试次数
    static let baseRetryDelay: TimeInterval = 3.0      // 基础重试延迟
    static let maxRetryDelay: TimeInterval = 10.0      // 最大重试延迟
    
    // 生成参数默认值
    static let defaultMaxTokens = 500
    static let defaultTemperature = 0.7
}

// MARK: - 环境变量获取方法（推荐）
extension AppConfig {
    /// 安全获取API Key的方法
    /// 优先级：环境变量 > Config文件配置
    static func getPoeAPIKey() -> String? {
        // 优先从环境变量获取
        if let envKey = ProcessInfo.processInfo.environment["POE_API_KEY"] {
            return envKey
        }
        
        // 如果Config中设置了有效的key（不是示例值），则使用
        if poeAPIKey != "your_poe_api_key_here" && !poeAPIKey.isEmpty {
            return poeAPIKey
        }
        
        return nil
    }
}