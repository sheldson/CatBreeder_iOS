//
//  ChromosomeCard.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import SwiftUI

// MARK: - 染色体卡片
struct ChromosomeCard: View {
    let chromosome: BaseColor
    let position: Int
    let isXXY: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text("X\(position)")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            RoundedRectangle(cornerRadius: 8)
                .fill(chromosomeColor)
                .frame(width: 60, height: 80)
                .overlay(
                    VStack {
                        Text(chromosome.rawValue)
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        if isXXY && position == 2 {
                            Text("Y")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                )
        }
    }
    
    private var chromosomeColor: Color {
        switch chromosome {
        case .black: return .black
        case .red: return .red
        default: return .gray
        }
    }
}