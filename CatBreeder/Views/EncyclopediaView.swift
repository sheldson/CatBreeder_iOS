//
//  EncyclopediaView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 图鉴界面
struct EncyclopediaView: View {
    var body: some View {
        NavigationView {
            PlaceholderContent(
                icon: "book",
                title: "图鉴功能",
                subtitle: "即将推出..."
            )
            .navigationTitle("图鉴")
        }
    }
}

// MARK: - 占位内容组件
struct PlaceholderContent: View {
    let icon: String
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text(title)
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    EncyclopediaView()
}