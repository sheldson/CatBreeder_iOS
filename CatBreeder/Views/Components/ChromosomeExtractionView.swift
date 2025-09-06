//
//  ChromosomeExtractionView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import SwiftUI

// MARK: - 染色体抽取界面
struct ChromosomeExtractionView: View {
    let sex: Sex
    @Binding var isExtracting: Bool
    let onExtract: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text(extractionPrompt)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onExtract) {
                HStack {
                    if isExtracting {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .scaleEffect(0.8)
                        Text("抽取中...")
                    } else {
                        Image(systemName: "shuffle")
                        Text("开始抽取染色体")
                    }
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: 200)
                .frame(height: 50)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.pink)
                )
            }
            .disabled(isExtracting)
        }
    }
    
    private var extractionPrompt: String {
        switch sex {
        case .male: return "公猫有一条X染色体\n将随机获得黑色或橘色基因"
        case .female: return "母猫有两条X染色体\n将进行两次抽取"
        }
    }
}