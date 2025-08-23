//
//  GameData.swift
//  CatBreeder
//
//  Created by AI Assistant on 2025/8/23.
//

import Foundation
import SwiftUI

// MARK: - 游戏数据管理器
@MainActor
class GameData: ObservableObject {
    // MARK: - 玩家基础数据
    @Published var playerLevel: Int = 1
    @Published var coins: Int = 100
    @Published var experience: Int = 0
    @Published var playerName: String = "猫咪训练师"
    
    // MARK: - 猫咪收藏
    @Published var ownedCats: [Cat] = []
    @Published var favoriteCats: Set<UUID> = []
    
    // MARK: - 游戏统计
    @Published var totalCatsGenerated: Int = 0
    @Published var raretyStats: [RarityLevel: Int] = [:]
    @Published var achievementsUnlocked: Set<String> = []
    
    // MARK: - 游戏设置
    @Published var soundEnabled: Bool = true
    @Published var animationsEnabled: Bool = true
    @Published var notifications: Bool = true
    
    // MARK: - 繁育相关
    @Published var breedingInProgress: Bool = false
    @Published var lastBreedingTime: Date?
    
    init() {
        loadGameData()
        initializeRarityStats()
    }
    
    // MARK: - 初始化稀有度统计
    private func initializeRarityStats() {
        for rarity in RarityLevel.allCases {
            if raretyStats[rarity] == nil {
                raretyStats[rarity] = 0
            }
        }
    }
}

// MARK: - 猫咪管理功能
extension GameData {
    // 添加新猫咪到收藏
    func addCat(_ cat: Cat) {
        ownedCats.append(cat)
        totalCatsGenerated += 1
        raretyStats[cat.rarity, default: 0] += 1
        
        // 根据稀有度给予经验和金币奖励
        let expReward = cat.rarity.experienceReward
        let coinReward = cat.rarity.coinReward
        
        addExperience(expReward)
        addCoins(coinReward)
        
        // 检查成就
        checkAchievements()
        
        saveGameData()
    }
    
    // 删除猫咪
    func removeCat(withId id: UUID) {
        if let index = ownedCats.firstIndex(where: { $0.id == id }) {
            let cat = ownedCats[index]
            ownedCats.remove(at: index)
            favoriteCats.remove(id)
            raretyStats[cat.rarity, default: 1] -= 1
            saveGameData()
        }
    }
    
    // 切换收藏状态
    func toggleFavorite(catId: UUID) {
        if favoriteCats.contains(catId) {
            favoriteCats.remove(catId)
        } else {
            favoriteCats.insert(catId)
        }
        saveGameData()
    }
    
    // 获取收藏的猫咪
    var favoriteCatsList: [Cat] {
        return ownedCats.filter { favoriteCats.contains($0.id) }
    }
    
    // 按稀有度排序的猫咪
    var catsSortedByRarity: [Cat] {
        return ownedCats.sorted { cat1, cat2 in
            let rarity1 = RarityLevel.allCases.firstIndex(of: cat1.rarity) ?? 0
            let rarity2 = RarityLevel.allCases.firstIndex(of: cat2.rarity) ?? 0
            return rarity1 > rarity2 // 稀有度高的在前
        }
    }
}

// MARK: - 游戏进度管理
extension GameData {
    // 添加经验值
    func addExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
        saveGameData()
    }
    
    // 检查升级
    private func checkLevelUp() {
        let requiredExp = experienceRequiredForLevel(playerLevel + 1)
        if experience >= requiredExp {
            playerLevel += 1
            experience -= requiredExp
            
            // 升级奖励
            let coinReward = playerLevel * 10
            addCoins(coinReward)
            
            // 可以添加升级通知
            print("🎉 恭喜升级到 \(playerLevel) 级！获得 \(coinReward) 金币奖励！")
        }
    }
    
    // 计算等级所需经验
    private func experienceRequiredForLevel(_ level: Int) -> Int {
        return level * 100 // 简化公式：每级需要 level * 100 经验
    }
    
    // 添加金币
    func addCoins(_ amount: Int) {
        coins += amount
        saveGameData()
    }
    
    // 花费金币
    func spendCoins(_ amount: Int) -> Bool {
        if coins >= amount {
            coins -= amount
            saveGameData()
            return true
        }
        return false
    }
}

// MARK: - 繁育功能
extension GameData {
    // 生成新猫咪
    func generateRandomCat() -> Cat {
        let genetics = GeneticsData.random()
        return Cat(genetics: genetics)
    }
    
    // 繁育两只猫咪（未来功能）
    func breedCats(_ parent1: Cat, _ parent2: Cat) -> Cat {
        // 这里是简化版本，实际会实现更复杂的遗传算法
        let genetics = GeneticsData.random()
        let newCat = Cat(genetics: genetics)  // ← 改为 let
        
        // 标记为第二代
        // newCat.generation = max(parent1.generation, parent2.generation) + 1
        
        return newCat
    }
    
    // 检查是否可以繁育
    func canBreed() -> Bool {
        // 检查冷却时间、金币等条件
        if let lastTime = lastBreedingTime {
            let cooldownMinutes = 5.0 // 5分钟冷却
            let timePassed = Date().timeIntervalSince(lastTime) / 60
            if timePassed < cooldownMinutes {
                return false
            }
        }
        
        return coins >= 50 // 繁育需要50金币
    }
    
    // 开始繁育过程
    func startBreeding() {
        guard canBreed() else { return }
        
        breedingInProgress = true
        lastBreedingTime = Date()
        
        // 模拟繁育时间（实际可能是动画时间）
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.completeBreeding()
        }
    }
    
    private func completeBreeding() {
        let newCat = generateRandomCat()
        addCat(newCat)
        _ = spendCoins(50)
        breedingInProgress = false
    }
}

// MARK: - 成就系统
extension GameData {
    private func checkAchievements() {
        // 第一只猫咪
        if totalCatsGenerated == 1 && !achievementsUnlocked.contains("first_cat") {
            unlockAchievement("first_cat", "初次合成", "获得了第一只猫咪")
        }
        
        // 收集10只猫咪
        if ownedCats.count == 10 && !achievementsUnlocked.contains("ten_cats") {
            unlockAchievement("ten_cats", "小小收藏家", "收集了10只猫咪")
        }
        
        // 获得稀有猫咪
        if raretyStats[.rare, default: 0] > 0 && !achievementsUnlocked.contains("first_rare") {
            unlockAchievement("first_rare", "稀有发现", "获得了第一只稀有猫咪")
        }
        
        // 获得传说猫咪
        if raretyStats[.legendary, default: 0] > 0 && !achievementsUnlocked.contains("first_legendary") {
            unlockAchievement("first_legendary", "传说收藏家", "获得了传说级猫咪！")
        }
    }
    
    private func unlockAchievement(_ id: String, _ title: String, _ description: String) {
        achievementsUnlocked.insert(id)
        
        // 成就奖励
        addCoins(100)
        addExperience(50)
        
        print("🏆 解锁成就：\(title) - \(description)")
    }
}

// MARK: - 数据持久化
extension GameData {
    private func saveGameData() {
        // 保存基础数据到UserDefaults
        UserDefaults.standard.set(playerLevel, forKey: "playerLevel")
        UserDefaults.standard.set(coins, forKey: "coins")
        UserDefaults.standard.set(experience, forKey: "experience")
        UserDefaults.standard.set(playerName, forKey: "playerName")
        UserDefaults.standard.set(totalCatsGenerated, forKey: "totalCatsGenerated")
        UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        UserDefaults.standard.set(animationsEnabled, forKey: "animationsEnabled")
        UserDefaults.standard.set(notifications, forKey: "notifications")
        UserDefaults.standard.set(lastBreedingTime, forKey: "lastBreedingTime")
        
        // 保存集合数据
        if let favoritesData = try? JSONEncoder().encode(Array(favoriteCats)) {
            UserDefaults.standard.set(favoritesData, forKey: "favoriteCats")
        }
        
        if let achievementsData = try? JSONEncoder().encode(Array(achievementsUnlocked)) {
            UserDefaults.standard.set(achievementsData, forKey: "achievements")
        }
        
        if let rarityData = try? JSONEncoder().encode(raretyStats) {
            UserDefaults.standard.set(rarityData, forKey: "rarityStats")
        }
        
        // 保存猫咪数据
        if let catsData = try? JSONEncoder().encode(ownedCats) {
            UserDefaults.standard.set(catsData, forKey: "ownedCats")
        }
    }
    
    private func loadGameData() {
        playerLevel = UserDefaults.standard.object(forKey: "playerLevel") as? Int ?? 1
        coins = UserDefaults.standard.object(forKey: "coins") as? Int ?? 100
        experience = UserDefaults.standard.object(forKey: "experience") as? Int ?? 0
        playerName = UserDefaults.standard.object(forKey: "playerName") as? String ?? "猫咪训练师"
        totalCatsGenerated = UserDefaults.standard.object(forKey: "totalCatsGenerated") as? Int ?? 0
        soundEnabled = UserDefaults.standard.object(forKey: "soundEnabled") as? Bool ?? true
        animationsEnabled = UserDefaults.standard.object(forKey: "animationsEnabled") as? Bool ?? true
        notifications = UserDefaults.standard.object(forKey: "notifications") as? Bool ?? true
        lastBreedingTime = UserDefaults.standard.object(forKey: "lastBreedingTime") as? Date
        
        // 加载集合数据
        if let favoritesData = UserDefaults.standard.data(forKey: "favoriteCats"),
           let favorites = try? JSONDecoder().decode([UUID].self, from: favoritesData) {
            favoriteCats = Set(favorites)
        }
        
        if let achievementsData = UserDefaults.standard.data(forKey: "achievements"),
           let achievements = try? JSONDecoder().decode([String].self, from: achievementsData) {
            achievementsUnlocked = Set(achievements)
        }
        
        if let rarityData = UserDefaults.standard.data(forKey: "rarityStats"),
           let stats = try? JSONDecoder().decode([RarityLevel: Int].self, from: rarityData) {
            raretyStats = stats
        }
        
        // 加载猫咪数据
        if let catsData = UserDefaults.standard.data(forKey: "ownedCats"),
           let cats = try? JSONDecoder().decode([Cat].self, from: catsData) {
            ownedCats = cats
        }
    }
    
    // 重置游戏数据
    func resetGameData() {
        playerLevel = 1
        coins = 100
        experience = 0
        ownedCats.removeAll()
        favoriteCats.removeAll()
        totalCatsGenerated = 0
        raretyStats.removeAll()
        achievementsUnlocked.removeAll()
        lastBreedingTime = nil
        
        initializeRarityStats()
        saveGameData()
    }
}

// MARK: - 稀有度扩展
extension RarityLevel {
    var experienceReward: Int {
        switch self {
        case .common: return 10
        case .uncommon: return 20
        case .rare: return 50
        case .epic: return 100
        case .legendary: return 200
        }
    }
    
    var coinReward: Int {
        switch self {
        case .common: return 5
        case .uncommon: return 15
        case .rare: return 30
        case .epic: return 75
        case .legendary: return 150
        }
    }
}
