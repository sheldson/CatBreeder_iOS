//
//  Config.swift
//  CatBreeder
//
//  Created by Sheldon027 on 2025/8/24.
//


//
//  Config.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/24.
//

import Foundation

// MARK: - 应用配置
struct AppConfig {
    // POE API配置
    static let poeAPIKey = "your_poe_api_key_here"  // ⚠️ 请使用环境变量 POE_API_KEY
    
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

