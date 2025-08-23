//
//  ContentView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var gameData = GameData()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 合成界面
            BreedingView()
                .environmentObject(gameData)
                .tabItem {
                    Image(systemName: "sparkles")
                    Text("合成")
                }
                .tag(0)
            
            // 猫舍界面
            CollectionView()
                .environmentObject(gameData)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("猫舍")
                }
                .tag(1)
            
            // 图鉴界面
            EncyclopediaView()
                .environmentObject(gameData)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("图鉴")
                }
                .tag(2)
            
            // 设置界面
            SettingsView()
                .environmentObject(gameData)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("设置")
                }
                .tag(3)
        }
        .accentColor(.pink)
    }
}

// MARK: - 预览
#Preview {
    ContentView()
}
