#!/bin/bash

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}LiveKit Client SDK 安全上下文修复版发布脚本${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""

# 检查是否已登录 npm
echo -e "${YELLOW}检查 npm 登录状态...${NC}"
if ! npm whoami &> /dev/null; then
    echo -e "${RED}错误: 未登录 npm${NC}"
    echo -e "${YELLOW}请先运行: npm login${NC}"
    exit 1
fi

NPM_USER=$(npm whoami)
echo -e "${GREEN}✓ 已登录为: $NPM_USER${NC}"
echo ""

# 确认包名
PACKAGE_NAME="@yrendaoai/livekit-client-fixed"
PACKAGE_VERSION=$(node -p "require('./package.json').version")
echo -e "${YELLOW}包名: $PACKAGE_NAME${NC}"
echo -e "${YELLOW}版本: $PACKAGE_VERSION${NC}"
echo ""

# 询问是否继续
read -p "是否继续发布? (y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}已取消发布${NC}"
    exit 1
fi

# 安装依赖
echo ""
echo -e "${YELLOW}步骤 1: 安装依赖...${NC}"
pnpm install
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: 依赖安装失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 依赖安装完成${NC}"

# 构建项目
echo ""
echo -e "${YELLOW}步骤 3: 构建项目...${NC}"
# 清理旧的构建文件
rm -rf ./dist
# 只运行基本构建，跳过 downlevel-dts
pnpm rollup --config --bundleConfigAsCjs && pnpm rollup --config rollup.config.worker.js --bundleConfigAsCjs
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: 构建失败${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 构建完成${NC}"
echo -e "${YELLOW}注意: 已跳过 TypeScript 4.2 兼容性构建${NC}"

# 发布到 npm
echo ""
echo -e "${YELLOW}步骤 4: 发布到 npm...${NC}"
npm publish --access public
if [ $? -ne 0 ]; then
    echo -e "${RED}错误: 发布失败${NC}"
    echo -e "${YELLOW}如果需要 2FA 验证码，请使用:${NC}"
    echo -e "${YELLOW}npm publish --access public --otp=YOUR_2FA_CODE${NC}"
    exit 1
fi
echo -e "${GREEN}✓ 发布成功!${NC}"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}发布完成!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "${YELLOW}包页面: https://www.npmjs.com/package/$PACKAGE_NAME${NC}"
echo ""
echo -e "${YELLOW}用户可以这样安装:${NC}"
echo -e "  npm install $PACKAGE_NAME"
echo -e "  pnpm add $PACKAGE_NAME"
echo -e "  yarn add $PACKAGE_NAME"
echo ""

