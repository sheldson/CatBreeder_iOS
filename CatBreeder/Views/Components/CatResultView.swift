//
//  CatResultView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 猫咪详情弹窗
struct CatResultView: View {
    let cat: Cat
    @EnvironmentObject var gameData: GameData
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 庆祝效果
                CelebrationHeader()
                
                // 猫咪展示
                CatCardView(cat: cat, size: .large)
                
                // 猫咪详细信息
                CatDetailInfo(cat: cat)
                
                Spacer()
                
                // 关闭按钮
                DismissButton {
                    dismiss()
                }
            }
            .padding()
            .navigationTitle("新猫咪")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 庆祝头部
struct CelebrationHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("🎉")
                .font(.system(size: 60))
            
            Text("恭喜获得新猫咪！")
                .font(.title2)
                .fontWeight(.bold)
        }
    }
}

// MARK: - 猫咪详细信息
struct CatDetailInfo: View {
    let cat: Cat
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRow(title: "名称", value: cat.displayName)
            InfoRow(title: "稀有度", value: cat.rarity.rawValue)
            InfoRow(title: "颜色", value: cat.colorDescription)
            InfoRow(title: "眼睛", value: cat.appearance.eyeColor.rawValue)
            
            if cat.appearance.hasSpecialEffects {
                InfoRow(title: "特效", value: "✨ 特殊效果")
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - 关闭按钮
struct DismissButton: View {
    let action: () -> Void
    
    var body: some View {
        Button("太棒了！", action: action)
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
    }
}

// MARK: - 信息行
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.medium)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
        }
    }
}

#Preview {
    let genetics = GeneticsData.random()
    let cat = Cat(genetics: genetics)
    
    return CatResultView(cat: cat)
        .environmentObject(GameData())
}