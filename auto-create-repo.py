#!/usr/bin/env python3
"""
自动创建GitHub仓库脚本
使用SSH密钥通过GitHub API创建仓库
"""

import os
import sys
import json
import subprocess
import tempfile
import hmac
import hashlib
import time
from pathlib import Path

def run_command(cmd, cwd=None):
    """运行命令并返回输出"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, cwd=cwd)
        return result.returncode, result.stdout, result.stderr
    except Exception as e:
        return 1, "", str(e)

def check_ssh_auth():
    """检查SSH认证"""
    print("🔑 检查SSH认证...")
    code, out, err = run_command("ssh -T git@github.com")
    if "successfully authenticated" in out or "successfully authenticated" in err:
        print("✅ SSH认证成功")
        return True
    else:
        print("❌ SSH认证失败")
        print(f"错误: {err}")
        return False

def get_ssh_public_key():
    """获取SSH公钥"""
    ssh_dir = Path.home() / ".ssh"
    key_files = list(ssh_dir.glob("*.pub"))
    
    if not key_files:
        print("❌ 未找到SSH公钥")
        return None
    
    # 使用第一个找到的公钥
    key_file = key_files[0]
    with open(key_file, 'r') as f:
        key = f.read().strip()
    
    print(f"🔑 找到SSH公钥: {key_file.name}")
    return key

def try_github_api_with_ssh():
    """尝试使用SSH密钥调用GitHub API"""
    print("🔄 尝试使用SSH密钥调用GitHub API...")
    
    # GitHub API端点
    api_url = "https://api.github.com/user/repos"
    
    # 尝试使用curl的--key选项（如果支持）
    payload = json.dumps({
        "name": "notebook-app",
        "description": "一个简单易用的想法记录Web应用",
        "private": False,
        "auto_init": False
    })
    
    # 尝试多种方法
    methods = [
        # 方法1：尝试使用现有的GitHub Token
        f'curl -s -X POST -H "Accept: application/vnd.github.v3+json" '
        f'-H "Authorization: token $(cat ~/.github_token 2>/dev/null || echo \'\')" '
        f'{api_url} -d \'{payload}\'',
        
        # 方法2：尝试使用GitHub CLI模拟
        'which gh >/dev/null 2>&1 && gh repo create notebook-app --public --description "一个简单易用的想法记录Web应用" --push --source=. --remote=origin || echo "GitHub CLI未安装"',
    ]
    
    for method in methods:
        print(f"尝试方法: {method[:50]}...")
        code, out, err = run_command(method)
        if code == 0 and out and "notebook-app" in out:
            print("✅ API调用成功")
            return True, out
    
    print("❌ 所有API方法都失败")
    return False, None

def try_git_push_create():
    """尝试通过git push自动创建仓库"""
    print("🔄 尝试通过git push自动创建仓库...")
    
    # 先确保远程仓库配置正确
    code, out, err = run_command("git remote get-url origin", cwd="/home/notebook-app")
    if code != 0 or not out:
        print("❌ 未配置远程仓库")
        run_command("git remote add origin git@github.com:gosunny2050/notebook-app.git", cwd="/home/notebook-app")
    
    # 尝试推送
    print("📤 尝试推送代码...")
    code, out, err = run_command("git push -u origin main 2>&1", cwd="/home/notebook-app")
    
    if code == 0:
        print("✅ 推送成功！")
        return True, out
    
    # 分析错误信息
    error_msg = out + err
    if "Repository not found" in error_msg:
        print("❌ 仓库不存在，需要先创建")
    elif "Permission denied" in error_msg:
        print("❌ 权限被拒绝")
    else:
        print(f"❌ 推送失败: {error_msg[:100]}")
    
    return False, error_msg

def create_repo_via_github_site():
    """提供手动创建指南"""
    print("\n" + "="*60)
    print("📝 手动创建GitHub仓库指南")
    print("="*60)
    print("\n由于自动创建需要GitHub Token，请手动创建：")
    print("\n1. 访问: https://github.com/new")
    print("2. 填写:")
    print("   - Repository name: notebook-app")
    print("   - Description: 一个简单易用的想法记录Web应用")
    print("   - Public (公开)")
    print("   - 不要初始化任何文件")
    print("3. 点击 'Create repository'")
    print("\n创建后，运行: ./push-to-github.sh")
    print("\n" + "="*60)
    return False

def main():
    print("🚀 自动创建GitHub仓库脚本")
    print("="*60)
    
    # 检查是否在项目目录
    if not Path("/home/notebook-app/index.html").exists():
        print("❌ 错误：请在项目根目录运行")
        return 1
    
    # 检查SSH认证
    if not check_ssh_auth():
        return 1
    
    # 获取SSH公钥
    ssh_key = get_ssh_public_key()
    if not ssh_key:
        return 1
    
    print(f"\n👤 GitHub用户: gosunny2050")
    print(f"🔑 SSH密钥: {ssh_key[:50]}...")
    
    # 尝试多种方法
    print("\n" + "="*60)
    print("尝试自动创建仓库...")
    print("="*60)
    
    # 方法1：尝试GitHub API
    success, result = try_github_api_with_ssh()
    if success:
        print(f"✅ 成功: {result[:100]}...")
        return 0
    
    # 方法2：尝试git push创建
    success, result = try_git_push_create()
    if success:
        print(f"✅ 成功: {result[:100]}...")
        return 0
    
    # 方法3：提供手动指南
    print("\n" + "="*60)
    print("自动创建失败，请手动创建")
    print("="*60)
    create_repo_via_github_site()
    
    return 1

if __name__ == "__main__":
    sys.exit(main())