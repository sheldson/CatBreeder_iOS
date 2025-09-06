//
//  WhiteArea.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/9/6.
//

import Foundation
import SwiftUI

// MARK: - 面部白斑区域枚举
enum WhiteArea: String, CaseIterable {
    case forehead = "额头"
    case noseBridge = "鼻梁" 
    case chin = "下巴"
    case leftEyeRing = "左眼圈"
    case rightEyeRing = "右眼圈"
    case muzzle = "嘴周"
    case leftCheek = "左脸颊"
    case rightCheek = "右脸颊"
    
    var emoji: String {
        switch self {
        case .forehead: return "🤔"
        case .noseBridge: return "👃"
        case .chin: return "😮"
        case .leftEyeRing: return "👁️"
        case .rightEyeRing: return "👁️"
        case .muzzle: return "😺"
        case .leftCheek: return "😊"
        case .rightCheek: return "😊"
        }
    }
    
    var position: CGPoint {
        // 相对于200x200猫脸的位置坐标
        switch self {
        case .forehead: return CGPoint(x: 100, y: 60)
        case .noseBridge: return CGPoint(x: 100, y: 100)
        case .chin: return CGPoint(x: 100, y: 160)
        case .leftEyeRing: return CGPoint(x: 75, y: 85)
        case .rightEyeRing: return CGPoint(x: 125, y: 85)
        case .muzzle: return CGPoint(x: 100, y: 130)
        case .leftCheek: return CGPoint(x: 60, y: 110)
        case .rightCheek: return CGPoint(x: 140, y: 110)
        }
    }
}