//
//  CacheManagementView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/29.
//

import SwiftUI

struct CacheManagementView: View {
    @ObservedObject private var cache = PromptCache.shared
    @State private var showingClearAlert = false
    
    var body: some View {
        NavigationView {
            List {
                CacheStatisticsSection(stats: cache.cacheStats)
                CachePerformanceSection(stats: cache.cacheStats)
                CacheManagementSection(
                    onClearCache: { showingClearAlert = true },
                    onRefreshStats: { cache.updateCacheStatistics() }
                )
            }
            .navigationTitle("缓存管理")
            .alert("清除所有缓存", isPresented: $showingClearAlert) {
                Button("取消", role: .cancel) { }
                Button("清除", role: .destructive) {
                    cache.clearAllCache()
                }
            } message: {
                Text("这将清除所有已保存的Prompt和图片缓存。下次生成时将重新调用API。")
            }
        }
    }
}

// MARK: - 缓存统计区域
struct CacheStatisticsSection: View {
    let stats: CacheStatistics
    
    var body: some View {
        Section("缓存统计") {
            CacheStatRow(
                title: "Prompt缓存",
                cacheSize: stats.promptCacheSize,
                hitRate: stats.promptHitRate,
                hits: stats.promptHits,
                misses: stats.promptMisses,
                color: .blue
            )
            
            CacheStatRow(
                title: "图片缓存",
                cacheSize: stats.imageCacheSize,
                hitRate: stats.imageHitRate,
                hits: stats.imageHits,
                misses: stats.imageMisses,
                color: .green
            )
            
            CacheStatRow(
                title: "描述缓存",
                cacheSize: stats.descriptionCacheSize,
                hitRate: stats.descriptionHitRate,
                hits: stats.descriptionHits,
                misses: stats.descriptionMisses,
                color: .orange
            )
        }
    }
}

struct CacheStatRow: View {
    let title: String
    let cacheSize: Int
    let hitRate: Double
    let hits: Int
    let misses: Int
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 8, height: 8)
                Text(title)
                    .font(.headline)
                    .fontWeight(.medium)
                Spacer()
                Text("\(cacheSize) 项")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("命中率")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(String(format: "%.1f%%", hitRate * 100))
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(hitRate > 0.5 ? .green : .orange)
                    }
                    
                    // 命中率进度条
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(.gray.opacity(0.2))
                                .frame(height: 4)
                            
                            RoundedRectangle(cornerRadius: 2)
                                .fill(color)
                                .frame(width: geometry.size.width * hitRate, height: 4)
                        }
                    }
                    .frame(height: 4)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("命中: \(hits)")
                        .font(.caption)
                        .foregroundColor(.green)
                    Text("未命中: \(misses)")
                        .font(.caption)
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - 性能影响区域
struct CachePerformanceSection: View {
    let stats: CacheStatistics
    
    var totalRequests: Int {
        stats.promptHits + stats.promptMisses + stats.imageHits + stats.imageMisses + stats.descriptionHits + stats.descriptionMisses
    }
    
    var estimatedTimeSaved: TimeInterval {
        // 基于缓存命中估算节省的时间
        let promptTimeSaved = Double(stats.promptHits) * 8.0  // 每次Prompt优化平均8秒
        let imageTimeSaved = Double(stats.imageHits) * 18.0   // 每次图片生成平均18秒
        let descTimeSaved = Double(stats.descriptionHits) * 0.05  // 描述生成很快
        
        return promptTimeSaved + imageTimeSaved + descTimeSaved
    }
    
    var body: some View {
        Section("性能影响") {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("总体命中率")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(String(format: "%.1f%%", stats.overallHitRate * 100))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(stats.overallHitRate > 0.5 ? .green : .orange)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("估算节省时间")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Text(formatTime(estimatedTimeSaved))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                }
            }
            .padding(.vertical, 4)
            
            if totalRequests > 0 {
                HStack {
                    Text("总请求数: \(totalRequests)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Text("缓存效率: \(cacheEfficiencyRating)")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(cacheEfficiencyColor)
                }
            }
        }
    }
    
    private var cacheEfficiencyRating: String {
        switch stats.overallHitRate {
        case 0.8...1.0: return "优秀"
        case 0.6..<0.8: return "良好"
        case 0.4..<0.6: return "一般"
        case 0.2..<0.4: return "较差"
        default: return "需改进"
        }
    }
    
    private var cacheEfficiencyColor: Color {
        switch stats.overallHitRate {
        case 0.8...1.0: return .green
        case 0.6..<0.8: return .blue
        case 0.4..<0.6: return .orange
        default: return .red
        }
    }
    
    private func formatTime(_ seconds: TimeInterval) -> String {
        if seconds >= 3600 {
            return String(format: "%.1f 小时", seconds / 3600)
        } else if seconds >= 60 {
            return String(format: "%.1f 分钟", seconds / 60)
        } else {
            return String(format: "%.1f 秒", seconds)
        }
    }
}

// MARK: - 缓存管理区域
struct CacheManagementSection: View {
    let onClearCache: () -> Void
    let onRefreshStats: () -> Void
    
    var body: some View {
        Section("缓存管理") {
            Button(action: onRefreshStats) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(.blue)
                    Text("刷新统计")
                    Spacer()
                }
            }
            
            Button(action: onClearCache) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                    Text("清除所有缓存")
                    Spacer()
                }
            }
            .foregroundColor(.red)
        }
        
        Section("缓存策略") {
            VStack(alignment: .leading, spacing: 8) {
                Text("智能缓存策略")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text("• Prompt缓存：24小时过期")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• 图片结果缓存：3天过期")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• 描述缓存：仅内存存储")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text("• 自动清理过期缓存")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
    }
}

#Preview {
    CacheManagementView()
}