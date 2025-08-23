//
//  CollectionView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 猫舍界面
struct CollectionView: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        NavigationView {
            VStack {
                if gameData.ownedCats.isEmpty {
                    EmptyCollectionView()
                } else {
                    CatGridView()
                }
            }
            .navigationTitle("猫舍 (\(gameData.ownedCats.count))")
        }
    }
}

// MARK: - 空收藏状态
struct EmptyCollectionView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "house")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("猫舍空空如也")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text("去合成一些猫咪吧！")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

// MARK: - 猫咪网格视图
struct CatGridView: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3)) {
                ForEach(gameData.ownedCats) { cat in
                    CatCardView(cat: cat, size: .medium)
                }
            }
            .padding()
        }
    }
}

#Preview {
    CollectionView()
        .environmentObject(GameData())
}