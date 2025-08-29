//
//  PromptCache.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/29.
//

import Foundation

// MARK: - 缓存项
struct CachedPromptItem: Codable {
    let prompt: String
    let catHash: String
    let createdAt: Date
    let usageCount: Int
    
    var isExpired: Bool {
        // 缓存24小时后过期
        return Date().timeIntervalSince(createdAt) > 86400
    }
}

struct CachedImageResult: Codable {
    let imageUrl: String
    let promptHash: String
    let style: String
    let quality: String
    let createdAt: Date
    let usageCount: Int
    
    var isExpired: Bool {
        // 图片结果缓存3天后过期
        return Date().timeIntervalSince(createdAt) > 259200
    }
}

// MARK: - 智能缓存管理器
class PromptCache: ObservableObject {
    static let shared = PromptCache()
    
    private let userDefaults = UserDefaults.standard
    private let promptCacheKey = "cached_prompts"
    private let imageCacheKey = "cached_images"
    private let descriptionCacheKey = "cached_descriptions"
    
    // 内存缓存
    private var memoryPromptCache: [String: String] = [:]
    private var memoryDescriptionCache: [String: String] = [:]
    private var memoryImageCache: [String: String] = [:]
    
    // 缓存统计
    @Published var cacheStats: CacheStatistics = CacheStatistics()
    
    private init() {
        loadCacheFromDisk()
        cleanExpiredItems()
    }
    
    // MARK: - Prompt缓存
    
    func getCachedPrompt(for cat: Cat) -> String? {
        let catHash = generateCatHash(cat)
        
        // 先查内存缓存
        if let cachedPrompt = memoryPromptCache[catHash] {
            updateCacheStats(hit: true, type: .prompt)
            print("💾 [PromptCache] Prompt缓存命中 (内存): \(catHash)")
            return cachedPrompt
        }
        
        // 查磁盘缓存
        if let diskCachedPrompts = loadCachedPrompts(),
           let cachedItem = diskCachedPrompts[catHash],
           !cachedItem.isExpired {
            
            // 加载到内存缓存
            memoryPromptCache[catHash] = cachedItem.prompt
            
            // 更新使用计数
            var updatedItem = cachedItem
            updatedItem = CachedPromptItem(
                prompt: cachedItem.prompt,
                catHash: cachedItem.catHash,
                createdAt: cachedItem.createdAt,
                usageCount: cachedItem.usageCount + 1
            )
            
            var allCached = diskCachedPrompts
            allCached[catHash] = updatedItem
            saveCachedPrompts(allCached)
            
            updateCacheStats(hit: true, type: .prompt)
            print("💿 [PromptCache] Prompt缓存命中 (磁盘): \(catHash)")
            return cachedItem.prompt
        }
        
        updateCacheStats(hit: false, type: .prompt)
        print("❌ [PromptCache] Prompt缓存未命中: \(catHash)")
        return nil
    }
    
    func cachePrompt(_ prompt: String, for cat: Cat) {
        let catHash = generateCatHash(cat)
        
        // 内存缓存
        memoryPromptCache[catHash] = prompt
        
        // 磁盘缓存
        var diskCached = loadCachedPrompts() ?? [:]
        diskCached[catHash] = CachedPromptItem(
            prompt: prompt,
            catHash: catHash,
            createdAt: Date(),
            usageCount: 1
        )
        saveCachedPrompts(diskCached)
        
        cacheStats.promptCacheSize = diskCached.count
        print("✅ [PromptCache] Prompt已缓存: \(catHash)")
    }
    
    // MARK: - 图片结果缓存
    
    func getCachedImageUrl(for prompt: String, style: ImageStyle, quality: ImageQuality) -> String? {
        let promptHash = generatePromptHash(prompt, style: style, quality: quality)
        
        // 先查内存缓存
        if let cachedUrl = memoryImageCache[promptHash] {
            updateCacheStats(hit: true, type: .image)
            print("💾 [PromptCache] 图片缓存命中 (内存): \(promptHash.prefix(8))")
            return cachedUrl
        }
        
        // 查磁盘缓存
        if let diskCachedImages = loadCachedImages(),
           let cachedItem = diskCachedImages[promptHash],
           !cachedItem.isExpired {
            
            // 加载到内存缓存
            memoryImageCache[promptHash] = cachedItem.imageUrl
            
            // 更新使用计数
            var updatedItem = cachedItem
            updatedItem = CachedImageResult(
                imageUrl: cachedItem.imageUrl,
                promptHash: cachedItem.promptHash,
                style: cachedItem.style,
                quality: cachedItem.quality,
                createdAt: cachedItem.createdAt,
                usageCount: cachedItem.usageCount + 1
            )
            
            var allCached = diskCachedImages
            allCached[promptHash] = updatedItem
            saveCachedImages(allCached)
            
            updateCacheStats(hit: true, type: .image)
            print("💿 [PromptCache] 图片缓存命中 (磁盘): \(promptHash.prefix(8))")
            return cachedItem.imageUrl
        }
        
        updateCacheStats(hit: false, type: .image)
        print("❌ [PromptCache] 图片缓存未命中: \(promptHash.prefix(8))")
        return nil
    }
    
    func cacheImageResult(_ imageUrl: String, for prompt: String, style: ImageStyle, quality: ImageQuality) {
        let promptHash = generatePromptHash(prompt, style: style, quality: quality)
        
        // 内存缓存
        memoryImageCache[promptHash] = imageUrl
        
        // 磁盘缓存
        var diskCached = loadCachedImages() ?? [:]
        diskCached[promptHash] = CachedImageResult(
            imageUrl: imageUrl,
            promptHash: promptHash,
            style: style.rawValue,
            quality: quality.rawValue,
            createdAt: Date(),
            usageCount: 1
        )
        saveCachedImages(diskCached)
        
        cacheStats.imageCacheSize = diskCached.count
        print("✅ [PromptCache] 图片结果已缓存: \(promptHash.prefix(8))")
    }
    
    // MARK: - 描述缓存
    
    func getCachedDescription(for cat: Cat) -> String? {
        let catHash = generateCatHash(cat)
        
        if let cached = memoryDescriptionCache[catHash] {
            updateCacheStats(hit: true, type: .description)
            return cached
        }
        
        updateCacheStats(hit: false, type: .description)
        return nil
    }
    
    func cacheDescription(_ description: String, for cat: Cat) {
        let catHash = generateCatHash(cat)
        memoryDescriptionCache[catHash] = description
        print("✅ [PromptCache] 描述已缓存: \(catHash)")
    }
    
    // MARK: - 缓存管理
    
    func clearAllCache() {
        memoryPromptCache.removeAll()
        memoryDescriptionCache.removeAll()
        memoryImageCache.removeAll()
        
        userDefaults.removeObject(forKey: promptCacheKey)
        userDefaults.removeObject(forKey: imageCacheKey)
        userDefaults.removeObject(forKey: descriptionCacheKey)
        
        cacheStats = CacheStatistics()
        print("🗑️ [PromptCache] 所有缓存已清除")
    }
    
    func cleanExpiredItems() {
        // 清理过期的Prompt缓存
        if var promptCache = loadCachedPrompts() {
            let originalCount = promptCache.count
            promptCache = promptCache.filter { !$0.value.isExpired }
            if promptCache.count != originalCount {
                saveCachedPrompts(promptCache)
                print("🧹 [PromptCache] 清理过期Prompt缓存: \(originalCount - promptCache.count)项")
            }
        }
        
        // 清理过期的图片缓存
        if var imageCache = loadCachedImages() {
            let originalCount = imageCache.count
            imageCache = imageCache.filter { !$0.value.isExpired }
            if imageCache.count != originalCount {
                saveCachedImages(imageCache)
                print("🧹 [PromptCache] 清理过期图片缓存: \(originalCount - imageCache.count)项")
            }
        }
        
        updateCacheStatistics()
    }
    
    // MARK: - 缓存统计
    
    func updateCacheStatistics() {
        let promptCount = loadCachedPrompts()?.count ?? 0
        let imageCount = loadCachedImages()?.count ?? 0
        let descriptionCount = memoryDescriptionCache.count
        
        cacheStats.promptCacheSize = promptCount
        cacheStats.imageCacheSize = imageCount
        cacheStats.descriptionCacheSize = descriptionCount
    }
    
    private func updateCacheStats(hit: Bool, type: CacheType) {
        switch type {
        case .prompt:
            if hit {
                cacheStats.promptHits += 1
            } else {
                cacheStats.promptMisses += 1
            }
        case .image:
            if hit {
                cacheStats.imageHits += 1
            } else {
                cacheStats.imageMisses += 1
            }
        case .description:
            if hit {
                cacheStats.descriptionHits += 1
            } else {
                cacheStats.descriptionMisses += 1
            }
        }
    }
    
    // MARK: - 哈希生成
    
    private func generateCatHash(_ cat: Cat) -> String {
        let genetics = cat.genetics
        let hashString = "\(genetics.sex.rawValue)-\(genetics.baseColor.rawValue)-\(genetics.dilution.rawValue)-\(genetics.pattern.rawValue)-\(genetics.white.distribution.rawValue)-\(genetics.white.percentage)-\(genetics.modifiers.map { $0.rawValue }.joined(separator: ","))"
        return hashString.sha256()
    }
    
    private func generatePromptHash(_ prompt: String, style: ImageStyle, quality: ImageQuality) -> String {
        let hashString = "\(prompt)-\(style.rawValue)-\(quality.rawValue)"
        return hashString.sha256()
    }
    
    // MARK: - 持久化
    
    private func loadCacheFromDisk() {
        updateCacheStatistics()
        print("📁 [PromptCache] 缓存已从磁盘加载")
    }
    
    private func loadCachedPrompts() -> [String: CachedPromptItem]? {
        guard let data = userDefaults.data(forKey: promptCacheKey) else { return nil }
        return try? JSONDecoder().decode([String: CachedPromptItem].self, from: data)
    }
    
    private func saveCachedPrompts(_ cache: [String: CachedPromptItem]) {
        if let data = try? JSONEncoder().encode(cache) {
            userDefaults.set(data, forKey: promptCacheKey)
        }
    }
    
    private func loadCachedImages() -> [String: CachedImageResult]? {
        guard let data = userDefaults.data(forKey: imageCacheKey) else { return nil }
        return try? JSONDecoder().decode([String: CachedImageResult].self, from: data)
    }
    
    private func saveCachedImages(_ cache: [String: CachedImageResult]) {
        if let data = try? JSONEncoder().encode(cache) {
            userDefaults.set(data, forKey: imageCacheKey)
        }
    }
}

// MARK: - 缓存统计数据模型
struct CacheStatistics {
    var promptHits: Int = 0
    var promptMisses: Int = 0
    var imageHits: Int = 0
    var imageMisses: Int = 0
    var descriptionHits: Int = 0
    var descriptionMisses: Int = 0
    
    var promptCacheSize: Int = 0
    var imageCacheSize: Int = 0
    var descriptionCacheSize: Int = 0
    
    var promptHitRate: Double {
        let total = promptHits + promptMisses
        return total > 0 ? Double(promptHits) / Double(total) : 0
    }
    
    var imageHitRate: Double {
        let total = imageHits + imageMisses
        return total > 0 ? Double(imageHits) / Double(total) : 0
    }
    
    var descriptionHitRate: Double {
        let total = descriptionHits + descriptionMisses
        return total > 0 ? Double(descriptionHits) / Double(total) : 0
    }
    
    var overallHitRate: Double {
        let totalHits = promptHits + imageHits + descriptionHits
        let totalRequests = promptHits + promptMisses + imageHits + imageMisses + descriptionHits + descriptionMisses
        return totalRequests > 0 ? Double(totalHits) / Double(totalRequests) : 0
    }
}

enum CacheType {
    case prompt
    case image
    case description
}

// MARK: - String扩展：SHA256哈希
extension String {
    func sha256() -> String {
        guard let data = self.data(using: .utf8) else { return self }
        
        // 简单哈希实现（在实际项目中应该使用CryptoKit）
        let hash = data.hashValue
        return String(format: "%08x", abs(hash))
    }
}