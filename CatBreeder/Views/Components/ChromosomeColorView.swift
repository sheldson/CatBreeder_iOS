//
//  ChromosomeColorView.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import SwiftUI

// MARK: - 染色体颜色显示组件
struct ChromosomeColorView: View {
    let chromosome: BaseColor
    let dilutionLevel: Double
    let tabbySubtype: TabbySubtype?
    let patternCoverage: Double
    let whitePercentage: Double
    let whiteAreas: Set<WhiteArea>
    
    init(chromosome: BaseColor, dilutionLevel: Double, tabbySubtype: TabbySubtype? = nil, patternCoverage: Double = 0.5, whitePercentage: Double = 0.0, whiteAreas: Set<WhiteArea> = []) {
        self.chromosome = chromosome
        self.dilutionLevel = dilutionLevel
        self.tabbySubtype = tabbySubtype
        self.patternCoverage = patternCoverage
        self.whitePercentage = whitePercentage
        self.whiteAreas = whiteAreas
    }
    
    var body: some View {
        let interpolatedColor = ColorInterpolator.interpolateColor(
            baseColor: chromosome, 
            dilutionLevel: dilutionLevel
        )
        
        RoundedRectangle(cornerRadius: 6)
            .fill(Color(hex: interpolatedColor))
            .frame(width: 60, height: 45)
            .overlay(
                // 斑纹叠加层
                patternOverlay
            )
            .overlay(
                // 白色叠加层
                whiteOverlay
            )
            .overlay(
                // 文字标签
                VStack(spacing: 2) {
                    Text(ColorInterpolator.getColorName(
                        baseColor: chromosome, 
                        dilutionLevel: dilutionLevel
                    ))
                        .font(.caption2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(radius: 1)
                    
                    if let tabbyType = tabbySubtype, tabbyType != .none {
                        Text(tabbyType.rawValue)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.9))
                            .shadow(radius: 1)
                    }
                }
            )
            .animation(.easeInOut(duration: 0.2), value: dilutionLevel)
            .animation(.easeInOut(duration: 0.2), value: patternCoverage)
            .animation(.easeInOut(duration: 0.2), value: whitePercentage)
            .id("\(chromosome.rawValue)-\(dilutionLevel)-\(tabbySubtype?.rawValue ?? "none")-\(patternCoverage)-\(whitePercentage)-\(whiteAreas.count)") // 强制刷新
    }
    
    @ViewBuilder
    private var patternOverlay: some View {
        if let tabbyType = tabbySubtype, tabbyType != .none {
            patternFill(for: tabbyType)
                .opacity(patternCoverage * 0.6) // 根据覆盖度调整透明度
        }
    }
    
    @ViewBuilder
    private var whiteOverlay: some View {
        if whitePercentage > 0.0 && !whiteAreas.isEmpty {
            RoundedRectangle(cornerRadius: 6)
                .fill(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            .white.opacity(whitePercentage * 0.9),
                            .white.opacity(whitePercentage * 0.5)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .opacity(0.8) // 基础透明度，让底色可见
        }
    }
    
    private func patternFill(for tabbyType: TabbySubtype) -> some View {
        RoundedRectangle(cornerRadius: 6)
            .fill(getPatternGradient(for: tabbyType))
    }
    
    private func getPatternGradient(for tabbyType: TabbySubtype) -> some ShapeStyle {
        switch tabbyType {
        case .mackerel:
            // 鲭鱼斑：垂直线条效果
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.4), location: 0.0),
                        .init(color: .clear, location: 0.1),
                        .init(color: .black.opacity(0.4), location: 0.2),
                        .init(color: .clear, location: 0.3),
                        .init(color: .black.opacity(0.4), location: 0.4),
                        .init(color: .clear, location: 0.5)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .classic:
            // 古典斑：宽条纹
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(stops: [
                        .init(color: .black.opacity(0.4), location: 0.0),
                        .init(color: .clear, location: 0.3),
                        .init(color: .black.opacity(0.4), location: 0.7),
                        .init(color: .clear, location: 1.0)
                    ]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
        case .spotted:
            // 点斑：径向渐变模拟点状
            return AnyShapeStyle(
                RadialGradient(
                    gradient: Gradient(colors: [.black.opacity(0.4), .clear]),
                    center: .center,
                    startRadius: 5,
                    endRadius: 20
                )
            )
        case .ticked:
            // 细斑纹：细腻渐变
            return AnyShapeStyle(
                LinearGradient(
                    gradient: Gradient(colors: [.clear, .black.opacity(0.2), .clear]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        case .none:
            return AnyShapeStyle(.clear)
        }
    }
}