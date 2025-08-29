#!/bin/bash

# 🔐 API Key 环境变量设置脚本
# 用于快速配置POE API Key环境变量

echo "🔐 CatBreeder API Key 设置向导"
echo "================================"

# 检查是否已经设置了环境变量
if [ ! -z "$POE_API_KEY" ]; then
    echo "✅ 检测到已设置的POE_API_KEY环境变量"
    echo "当前值: ${POE_API_KEY:0:8}..." 
    read -p "是否要更新API Key? (y/n): " update_key
    if [[ $update_key != "y" && $update_key != "Y" ]]; then
        echo "保持现有配置"
        exit 0
    fi
fi

echo ""
echo "📝 请获取你的API Key："
echo "1. 访问 https://poe.com/api_key"
echo "2. 登录你的Poe账户"
echo "3. 复制API Key"
echo ""

read -s -p "请输入你的POE API Key: " api_key
echo ""

if [ -z "$api_key" ]; then
    echo "❌ API Key不能为空"
    exit 1
fi

# 检测shell类型
if [[ $SHELL == *"zsh"* ]]; then
    shell_config="$HOME/.zshrc"
elif [[ $SHELL == *"bash"* ]]; then
    shell_config="$HOME/.bash_profile"
else
    shell_config="$HOME/.profile"
fi

echo ""
echo "🔧 配置环境变量到: $shell_config"

# 检查是否已经有POE_API_KEY配置
if grep -q "POE_API_KEY" "$shell_config"; then
    echo "⚠️  发现已存在的POE_API_KEY配置，正在更新..."
    # 创建备份
    cp "$shell_config" "$shell_config.backup.$(date +%Y%m%d_%H%M%S)"
    # 替换现有配置
    sed -i '' 's/export POE_API_KEY=.*/export POE_API_KEY="'$api_key'"/' "$shell_config"
else
    # 添加新配置
    echo "" >> "$shell_config"
    echo "# POE API Key for CatBreeder" >> "$shell_config"
    echo "export POE_API_KEY=\"$api_key\"" >> "$shell_config"
fi

echo "✅ API Key已成功配置到 $shell_config"
echo ""
echo "🔄 请运行以下命令使配置生效："
echo "   source $shell_config"
echo ""
echo "或者重新打开终端"
echo ""
echo "🧪 测试配置："
echo "   echo \$POE_API_KEY"
echo ""
echo "🚀 现在你可以运行CatBreeder项目了！"

# 立即加载配置到当前会话
export POE_API_KEY="$api_key"
echo "✅ 当前终端会话已加载API Key"