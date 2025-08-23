//
//  StatusBar.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 状态栏
struct StatusBar: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        HStack(spacing: 20) {
            // 等级
            StatusItem(
                icon: "star.fill",
                iconColor: .yellow,
                text: "Lv.\(gameData.playerLevel)"
            )
            
            Spacer()
            
            // 金币
            StatusItem(
                icon: "dollarsign.circle.fill",
                iconColor: .green,
                text: "\(gameData.coins)"
            )
            
            // 经验
            StatusItem(
                icon: "flame.fill",
                iconColor: .orange,
                text: "\(gameData.experience)"
            )
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .padding(.horizontal)
    }
}

// MARK: - 状态项组件
struct StatusItem: View {
    let icon: String
    let iconColor: Color
    let text: String
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(iconColor)
            Text(text)
                .font(.caption)
                .fontWeight(.semibold)
                .monospacedDigit()
        }
    }
}

#Preview {
    StatusBar()
        .environmentObject(GameData())
}