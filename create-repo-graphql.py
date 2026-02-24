#!/usr/bin/env python3
"""
使用GitHub GraphQL API创建仓库
"""

import json
import subprocess
import sys

def run_graphql_query(token, query):
    """运行GraphQL查询"""
    cmd = [
        'curl', '-s', '-X', 'POST',
        '-H', 'Authorization: bearer ' + token,
        '-H', 'Content-Type: application/json',
        'https://api.github.com/graphql',
        '-d', json.dumps({'query': query})
    ]
    
    try:
        result = subprocess.run(cmd, capture_output=True, text=True)
        return json.loads(result.stdout)
    except Exception as e:
        return {'errors': [{'message': str(e)}]}

def main():
    # 读取Token
    try:
        with open('/root/.github_token', 'r') as f:
            token = f.read().strip()
    except:
        print("❌ 无法读取GitHub Token")
        return 1
    
    print("🔑 使用GitHub Token创建仓库...")
    
    # GraphQL查询：创建仓库
    query = """
    mutation {
      createRepository(input: {
        name: "notebook-app",
        description: "一个简单易用的想法记录Web应用",
        visibility: PUBLIC,
        hasIssuesEnabled: false,
        hasWikiEnabled: false,
        hasProjectsEnabled: false
      }) {
        repository {
          id
          name
          url
          sshUrl
        }
      }
    }
    """
    
    print("🔄 发送GraphQL请求...")
    result = run_graphql_query(token, query)
    
    if 'errors' in result:
        print("❌ GraphQL错误:")
        for error in result['errors']:
            print(f"  - {error.get('message', '未知错误')}")
        
        # 检查权限
        print("\n🔍 检查Token权限...")
        check_query = """
        query {
          viewer {
            login
          }
        }
        """
        check_result = run_graphql_query(token, check_query)
        if 'data' in check_result and check_result['data']['viewer']:
            print(f"✅ Token有效，用户: {check_result['data']['viewer']['login']}")
            print("⚠️  Token可能缺少 'repo' 权限")
        return 1
    
    if 'data' in result and result['data']['createRepository']:
        repo = result['data']['createRepository']['repository']
        print("✅ 仓库创建成功！")
        print(f"📦 仓库名: {repo['name']}")
        print(f"🔗 URL: {repo['url']}")
        print(f"🔑 SSH URL: {repo['sshUrl']}")
        return 0
    else:
        print("❌ 创建失败，未知错误")
        print(f"响应: {json.dumps(result, indent=2)}")
        return 1

if __name__ == "__main__":
    sys.exit(main())