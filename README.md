# Estate Match

空き家・空き地マッチングサービス

## 概要
物件（空き家や空き地）のオーナー・不動産業者と、空き家・空き地を購入したい人を繋げるプラットフォーム。
地域の空き家問題解決と不動産の有効活用を促進することを目的とする。

## 技術スタック
- **Ruby**: 3.2.2
- **Rails**: 8.0
- **Database**: MySQL 8.0
- **Frontend**: Rails Views (ERB), Stimulus, Turbo
- **Testing**: RSpec, FactoryBot, Capybara
- **Authentication**: Devise
- **File Upload**: Active Storage
- **Styling**: Tailwind CSS

## セットアップ

### 必要な環境
- Ruby 3.2.2
- MySQL 8.0
- Node.js 18+

### インストール手順
```bash
# リポジトリをクローン
git clone [repository-url]
cd estate_match

# 依存関係をインストール
bundle install

# データベース作成・マイグレーション
rails db:create
rails db:migrate

# 開発サーバー起動
rails server
```

## テスト実行
```bash
# RSpec実行
bundle exec rspec

# カバレッジ付きテスト
bundle exec rspec --format documentation

# 特定のテストファイル実行
bundle exec rspec spec/models/user_spec.rb
```

## 主要機能
- [x] ユーザー登録・認証（オーナー/購買者別）
- [x] マイページ（オーナー/購買者別）
- [x] 物件投稿機能（オーナー向け・画像・間取り図アップロード対応）
- [x] 物件一覧・詳細表示機能
- [x] お気に入り機能（購買者向け・非同期操作・マイページで確認）
- [ ] 物件検索機能（購買者向け・タグ/フィルタ対応）
- [ ] チャット機能（購買者⇔オーナー間）

## デプロイ

### ステージング環境（Railway）

#### Railway の特徴
- **コスト**: 無料枠$5/月、従量課金制
- **Rails + MySQL対応**: ネイティブサポート
- **自動デプロイ**: GitHub連携
- **料金制御**: ハードリミット設定で予算オーバー防止

#### 料金制御設定（推奨）
```
ソフトリミット: $3/月（警告メール）
ハードリミット: $5/月（自動停止）
```

#### 設定方法
1. [Railway](https://railway.com)でアカウント作成
2. GitHubリポジトリを連携
3. 環境変数設定:
   ```
   RAILS_ENV=production
   DATABASE_URL=（Railwayが自動設定）
   RAILS_MASTER_KEY=（config/master.keyの内容）
   ```
4. Usage Limitsページで料金制限設定:
   - Custom Email Alert: $3
   - Hard Limit: $5

#### 注意事項
- ハードリミット到達時は**手動再起動**が必要
- 75%、90%到達時に警告メール送信
- 最低ハードリミット: $10（開発用途では$5推奨）

### 本番環境候補

#### 1. Heroku
- **月額**: $10-17（DB込み）
- **信頼性**: 最高
- **Rails対応**: 最高
- **学習コスト**: 最低

#### 2. Render
- **月額**: $7-
- **PostgreSQL推奨**: MySQL移行が必要
- **無料プラン**: あり（制限付き）
- **安定性**: 高

## 開発コマンド
```bash
# 開発サーバー起動
rails server

# コンソール起動
rails console

# マイグレーション実行
rails db:migrate

# テスト実行
bundle exec rspec

# RuboCop実行
bundle exec rubocop

# セキュリティチェック
bundle exec brakeman
```

## データベース
- **開発環境**: `estate_match_development`
- **テスト環境**: `estate_match_test`
- **本番環境**: 環境変数で設定

## 環境変数
```bash
# 必須
DATABASE_URL=mysql2://user:password@host:port/database
RAILS_MASTER_KEY=your_master_key

# オプション
MYSQL_HOST=localhost
MYSQL_PORT=3306
MYSQL_USER=root
MYSQL_PASSWORD=
```

## ライセンス
このプロジェクトは個人開発プロジェクトです。