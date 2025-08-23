//
//  SettingsView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 设置界面
struct SettingsView: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        NavigationView {
            List {
                GameStatsSection()
                DeveloperOptionsSection()
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
    
    var body: some View {
        Section("开发选项") {
            Button("重置游戏数据") {
                gameData.resetGameData()
            }
            .foregroundColor(.red)
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