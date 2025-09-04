# Posifeed API - Render.com Deployment Guide

## Render.com へのデプロイ手順

### 1. GitHubリポジトリの準備

1. GitHubにて新しいリポジトリを作成
2. ローカルでGitを初期化し、プッシュ

```bash
cd /path/to/posifeed-api
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin https://github.com/YOUR_USERNAME/posifeed-api.git
git push -u origin main
```

### 2. Render.com での設定

1. [Render.com](https://render.com) にログイン
2. "New +" → "Blueprint" を選択
3. GitHubリポジトリを接続
4. `render.yaml` ファイルが自動的に認識される

### 3. 環境変数

以下の環境変数が自動設定されます：
- `DATABASE_URL`: PostgreSQL接続文字列（自動設定）
- `RAILS_ENV`: production（自動設定）
- `RAILS_SERVE_STATIC_FILES`: true（自動設定）
- `RAILS_LOG_TO_STDOUT`: true（自動設定）
- `SECRET_KEY_BASE`: 自動生成

### 4. データベース

PostgreSQL データベースが自動作成され、Rails マイグレーションが実行されます。

### 5. デプロイ後の確認

デプロイ完了後、以下のエンドポイントで動作確認：

- Health check: `https://your-app-name.onrender.com/api/v1/health`
- API endpoints: `https://your-app-name.onrender.com/api/v1/`

## 設定ファイル

- `render.yaml`: Render.com用の設定ファイル
- `Dockerfile`: Dockerコンテナの設定
- `config/environments/production.rb`: 本番環境設定
- `config/initializers/cors.rb`: CORS設定（Render.com対応）

## トラブルシューティング

### よくある問題

1. **データベース接続エラー**
   - render.yaml でデータベース設定を確認

2. **CORS エラー**
   - フロントエンドのドメインが `config/initializers/cors.rb` に含まれているか確認

3. **Secret key base エラー**
   - 環境変数 `SECRET_KEY_BASE` が設定されているか確認

### ログの確認方法

Render.com ダッシュボードの "Logs" タブでアプリケーションログを確認できます。