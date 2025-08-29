//
//  SettingsView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI
import Foundation

// MARK: - 设置界面
struct SettingsView: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        NavigationView {
            List {
                GameStatsSection()
                DeveloperOptionsSection()
                APITestingSection()
            }
            .navigationTitle("设置")
        }
    }
}

// MARK: - 游戏统计区域
struct GameStatsSection: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        Section("游戏统计") {
            StatRow(title: "总合成次数", value: "\(gameData.totalCatsGenerated)")
            StatRow(title: "当前等级", value: "Lv.\(gameData.playerLevel)")
            StatRow(title: "收藏猫咪", value: "\(gameData.ownedCats.count)")
        }
    }
}

// MARK: - 开发选项区域
struct DeveloperOptionsSection: View {
    @EnvironmentObject var gameData: GameData
    @ObservedObject private var poeAPIService = PoeAPIService.shared
    
    var body: some View {
        Section("开发选项") {
            HStack {
                VStack(alignment: .leading) {
                    Text("AI模拟模式")
                    Text("开启时使用模拟图片，关闭时调用真实API")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Toggle("", isOn: $poeAPIService.isSimulationMode)
            }
            
            Button("重置游戏数据") {
                gameData.resetGameData()
            }
            .foregroundColor(.red)
        }
    }
}

// MARK: - API测试区域  
struct APITestingSection: View {
    @State private var showingAPITest = false
    
    var body: some View {
        Section("API测试") {
            NavigationLink(destination: PoeAPITestView()) {
                HStack {
                    Image(systemName: "network.badge.shield.half.filled")
                        .foregroundColor(.blue)
                    Text("POE API 连接测试")
                }
            }
            
            NavigationLink(destination: CatDescriptionTestView()) {
                HStack {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundColor(.green)
                    Text("猫咪描述生成测试")
                }
            }
            
            NavigationLink(destination: PromptOptimizerTestView()) {
                HStack {
                    Image(systemName: "wand.and.stars")
                        .foregroundColor(.purple)
                    Text("AI绘画Prompt优化测试")
                }
            }
            
            NavigationLink(destination: ImageGeneratorTestView()) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(.orange)
                    Text("AI图片生成测试")
                }
            }
            
            NavigationLink(destination: AIPerformanceTestView()) {
                HStack {
                    Image(systemName: "speedometer")
                        .foregroundColor(.red)
                    Text("AI性能测试分析")
                }
            }
            
            NavigationLink(destination: CacheManagementView()) {
                HStack {
                    Image(systemName: "internaldrive")
                        .foregroundColor(.purple)
                    Text("缓存管理")
                }
            }
        }
    }
}

// MARK: - 统计行组件
struct StatRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(GameData())
}