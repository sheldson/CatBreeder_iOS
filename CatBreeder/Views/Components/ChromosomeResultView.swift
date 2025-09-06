//
//  ChromosomeResultView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import SwiftUI

// MARK: - 染色体结果展示
struct ChromosomeResultView: View {
    let sex: Sex
    let chromosomes: [BaseColor]
    let isXXY: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            if isXXY {
                Text("🎉 超稀有 XXY 公猫！")
                    .font(.headline)
                    .foregroundColor(.orange)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(.orange.opacity(0.1))
                    )
            }
            
            Text("染色体抽取结果：")
                .font(.headline)
            
            HStack(spacing: 16) {
                ForEach(Array(chromosomes.enumerated()), id: \.offset) { index, chromosome in
                    ChromosomeCard(
                        chromosome: chromosome,
                        position: index + 1,
                        isXXY: isXXY
                    )
                }
            }
            
            Text(resultDescription)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    private var resultDescription: String {
        if chromosomes.count == 1 {
            return "公猫获得了\(chromosomes[0].rawValue)基因"
        } else if chromosomes.count == 2 {
            let first = chromosomes[0]
            let second = chromosomes[1]
            
            if first == second {
                return "\(sex.rawValue)获得了双\(first.rawValue)基因"
            } else {
                if sex == .male && isXXY {
                    return "XXY公猫获得了黑色+橘色基因，将表现为玳瑁色！"
                } else {
                    return "母猫获得了黑色+橘色基因，将表现为玳瑁/三花色！"
                }
            }
        }
        return ""
    }
}