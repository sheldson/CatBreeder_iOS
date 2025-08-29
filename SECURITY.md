# 🔐 安全指南

## ⚠️ 重要提醒

**绝对不要将API Keys、密码或其他敏感信息提交到Git仓库！**

## 🛡️ 安全配置步骤

### 1. 配置API Key

#### 方法一：环境变量（推荐）
```bash
# 在你的 shell 配置文件中添加（~/.zshrc 或 ~/.bash_profile）
export POE_API_KEY="your_actual_poe_api_key"
```

#### 方法二：本地配置文件
```bash
# 复制示例配置文件
cp Config.example.swift Config.swift

# 编辑Config.swift，替换API Key
# Config.swift已被.gitignore排除，不会被提交
```

### 2. 获取API Key

1. 访问 [poe.com/api_key](https://poe.com/api_key)
2. 登录你的Poe账户
3. 获取API Key
4. 按照上述方法之一配置

### 3. 验证配置

在Xcode中运行项目，如果API配置正确，你应该能看到：
- POE API测试页面连接成功
- AI图片生成功能正常工作

## 🚨 如果API Key已经泄漏

如果你发现API Key被意外提交到Git仓库：

### 立即行动：

1. **撤销现有Key**
   - 访问 [poe.com/api_key](https://poe.com/api_key)
   - 撤销(Revoke)现有的API Key
   - 生成新的API Key

2. **清理Git历史**
   ```bash
   # ⚠️ 危险操作：重写Git历史
   # 建议创建新仓库，重新开始
   
   # 或者使用git filter-repo清理敏感信息
   pip install git-filter-repo
   git filter-repo --invert-paths --path Config.swift
   ```

3. **更新新Key**
   - 按照上述安全方法配置新的API Key
   - 确认.gitignore正确配置

## 📝 代码中的安全实践

### ✅ 正确做法

```swift
// 使用环境变量
let apiKey = ProcessInfo.processInfo.environment["POE_API_KEY"]

// 或使用安全的配置方法
let apiKey = AppConfig.getPoeAPIKey()
```

### ❌ 错误做法

```swift
// 绝对不要这样做！
static let poeAPIKey = "pk_test_1234567890abcdef"  // ❌ 硬编码API Key

// 不要在任何文件中直接写入API Key
let apiKey = "your_secret_key"  // ❌ 明文API Key
```

## 🛡️ .gitignore 配置

项目已配置了安全的.gitignore规则：

```gitignore
# 🔐 安全配置文件 - 绝对不要提交！
Config.swift
**/Config.swift
secrets.swift
**/secrets.swift
api-keys.swift
**/api-keys.swift
*.env
.env*
**/.env*
```

## 📋 安全检查清单

在提交代码前，请确认：

- [ ] 没有硬编码的API Keys
- [ ] Config.swift不在Git跟踪中
- [ ] 使用环境变量或安全配置文件
- [ ] .gitignore正确配置
- [ ] 运行`git status`确认没有敏感文件

## 🔍 检查工具

使用以下命令检查代码中的潜在敏感信息：

```bash
# 搜索可能的API Key模式
grep -r "api.*key\|API.*KEY\|token\|Token" --include="*.swift" .

# 搜索长字符串（可能是key）
grep -r "[a-zA-Z0-9]{32,}" --include="*.swift" .
```

## 📞 如需帮助

如果发现安全问题或需要帮助：

1. 立即停止使用可能泄露的API Key
2. 按照上述步骤撤销和更新Key
3. 检查Git历史确认没有其他泄露

---

> 🛡️ 安全是软件开发的基础，永远不要将敏感信息提交到公共仓库！