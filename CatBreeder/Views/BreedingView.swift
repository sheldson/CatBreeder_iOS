//
//  BreedingView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import SwiftUI

// MARK: - 合成界面
struct BreedingView: View {
    @EnvironmentObject var gameData: GameData
    @State private var showingResult = false
    @State private var newCat: Cat?
    @State private var isGenerating = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 顶部状态栏
                StatusBar()
                
                Spacer()
                
                // 主要合成区域
                VStack(spacing: 40) {
                    // 合成说明
                    VStack(spacing: 10) {
                        Image(systemName: "sparkles.rectangle.stack")
                            .font(.system(size: 60))
                            .foregroundColor(.pink)
                        
                        Text("猫咪合成器")
                            .font(.title)
                            .fontWeight(.bold)
                        
                        Text("消耗 50 金币生成一只随机猫咪")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    // 合成按钮
                    Button(action: generateCat) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                            }
                            
                            Text(isGenerating ? "合成中..." : "开始合成")
                                .font(.title3)
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(canGenerate ? .pink : .gray)
                        )
                    }
                    .disabled(!canGenerate || isGenerating)
                    .animation(.easeInOut(duration: 0.2), value: canGenerate)
                    
                    // 提示信息
                    if !canGenerate {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("金币不足，需要 50 金币")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 最近生成的猫咪
                if !gameData.ownedCats.isEmpty {
                    RecentCatsView()
                }
                
                Spacer()
            }
            .navigationTitle("合成")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingResult) {
                if let cat = newCat {
                    CatResultView(cat: cat)
                        .environmentObject(gameData)
                }
            }
        }
    }
    
    private var canGenerate: Bool {
        return gameData.coins >= 50 && !isGenerating
    }
    
    private func generateCat() {
        guard canGenerate else { return }
        
        isGenerating = true
        
        // 模拟合成过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let cat = gameData.generateRandomCat()
            gameData.addCat(cat)
            _ = gameData.spendCoins(50)
            
            newCat = cat
            isGenerating = false
            showingResult = true
        }
    }
}

// MARK: - 最近的猫咪
struct RecentCatsView: View {
    @EnvironmentObject var gameData: GameData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("最近获得")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(gameData.ownedCats.suffix(5).reversed(), id: \.id) { cat in
                        CatCardView(cat: cat, size: .small)
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

#Preview {
    BreedingView()
        .environmentObject(GameData())
}