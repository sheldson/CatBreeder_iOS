//
//  CatCardView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 猫咪卡片
struct CatCardView: View {
    let cat: Cat
    let size: CardSize
    @EnvironmentObject var gameData: GameData
    
    enum CardSize {
        case small, medium, large
        
        var dimensions: CGSize {
            switch self {
            case .small: return CGSize(width: 80, height: 100)
            case .medium: return CGSize(width: 120, height: 150)
            case .large: return CGSize(width: 160, height: 200)
            }
        }
        
        var fontSize: Font {
            switch self {
            case .small: return .caption2
            case .medium: return .caption
            case .large: return .footnote
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 6) {
            // 猫咪主体区域
            CatDisplayArea(cat: cat, size: size)
            
            // 猫咪信息
            CatInfoSection(cat: cat, fontSize: size.fontSize)
        }
        .frame(width: size.dimensions.width)
    }
}

// MARK: - 猫咪显示区域
struct CatDisplayArea: View {
    let cat: Cat
    let size: CatCardView.CardSize
    
    var body: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(cat.appearance.mainDisplayColor.opacity(0.8))
            .overlay(
                VStack {
                    // 简化的猫咪表示
                    Text("🐱")
                        .font(.system(size: size.dimensions.width * 0.4))
                    
                    if cat.appearance.hasSpecialEffects {
                        Text("✨")
                            .font(.caption)
                    }
                }
            )
            .frame(width: size.dimensions.width, height: size.dimensions.height * 0.7)
    }
}

// MARK: - 猫咪信息区域
struct CatInfoSection: View {
    let cat: Cat
    let fontSize: Font
    
    var body: some View {
        VStack(spacing: 2) {
            Text(cat.displayName)
                .font(fontSize)
                .fontWeight(.medium)
                .lineLimit(1)
            
            HStack(spacing: 4) {
                Circle()
                    .fill(cat.rarity.color)
                    .frame(width: 6, height: 6)
                
                Text(cat.rarity.rawValue)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
}

#Preview {
    let genetics = GeneticsData.random()
    let cat = Cat(genetics: genetics)
    
    return CatCardView(cat: cat, size: .medium)
        .environmentObject(GameData())
}