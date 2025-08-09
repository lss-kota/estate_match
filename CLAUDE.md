# Estate Match

## プロジェクト概要
空き家・空き地マッチングサービス

物件（空き家や空き地）のオーナー・不動産業者と、空き家・空き地を購入したい人を繋げるプラットフォーム。
地域の空き家問題解決と不動産の有効活用を促進することを目的とする。

## 技術スタック
- **フロントエンド**: Rails Views (ERB), Stimulus, Turbo, importmap-rails
- **バックエンド**: Ruby on Rails 8.0, Ruby 3.2.2
- **データベース**: MySQL 8.0
- **アセット管理**: importmap-rails, Stimulus, Turbo Rails
- **アプリケーションサーバー**: Puma

## ディレクトリ構造
```
estate_match/
├── src/
│   ├── components/     # UIコンポーネント
│   ├── pages/         # ページコンポーネント
│   ├── services/      # API通信・ビジネスロジック
│   ├── utils/         # ユーティリティ関数
│   └── types/         # TypeScript型定義
├── public/            # 静的ファイル
└── tests/             # テストファイル
```

## 主要機能
- [ ] ユーザー登録・認証（オーナー/購買者別）
- [ ] マイページ（オーナー/購買者別）
- [ ] 物件投稿機能（オーナー向け）
- [ ] 物件検索機能（購買者向け・タグ/フィルタ対応）
- [ ] お気に入り機能（購買者向け・マイページで確認）
- [ ] チャット機能（購買者⇔オーナー間）

## API仕様
### エンドポイント一覧
- `GET /api/properties` - 物件一覧取得
- `GET /api/properties/:id` - 物件詳細取得
- `POST /api/users/register` - ユーザー登録
- `POST /api/users/login` - ログイン

## データベーススキーマ
### Users テーブル
- id: Primary Key
- email: String (Unique)
- password: String (Hashed)
- created_at: DateTime
- updated_at: DateTime

### Properties テーブル
- id: Primary Key
- title: String
- description: Text
- price: Integer
- location: String
- created_at: DateTime
- updated_at: DateTime

## 開発コマンド
```bash
# 開発サーバー起動
bin/rails server

# データベース作成・マイグレーション
bin/rails db:create
bin/rails db:migrate

# テスト実行
bin/rails test

# コンソール起動
bin/rails console

# リント（RuboCop）
bundle exec rubocop

# セキュリティチェック（Brakeman）
bundle exec brakeman
```

## コーディング規約
- TypeScriptを使用
- ESLint + Prettierでコード整形
- コンポーネント名はPascalCase
- ファイル名はkebab-case
- 関数はcamelCase

## 環境変数
```
DATABASE_URL=
API_KEY=
JWT_SECRET=
```

## Git & Pull Request ルール

### Pull Request作成ルール
git pushした後、以下のルールでPull Requestを作成すること：

#### タイトル
- 日本語で簡潔に記載
- 変更内容が分かりやすいタイトルにする

#### 説明文
- **必ず日本語で記載**
- **箇条書きで簡潔に**まとめる
- 以下のセクションを含める：
  - ## 概要
  - ## 主な変更点
  - ## 実装詳細
  - ## 影響範囲
  - ## テスト方法

#### 例
```
## 概要
Estate Matchプラットフォーム向けの包括的なブランドカラーシステムを実装しました。

## 主な変更点
- カスタムブランドカラーをTailwind v4で実装
- ランディングページの全色をestate-*クラスに置換
- 美しい背景画像とアニメーション効果を追加

## 実装詳細
- Tailwind CSS v4の@themeブロックでカスタムカラー定義
- 全セクションのカラー統一とレスポンシブデザイン

## 影響範囲
- app/assets/tailwind/application.css
- app/views/pages/index.html.erb

## テスト方法
- bin/rails server でローカル確認
- http://localhost:3000 で動作チェック
```

## 備考
- [その他の重要な情報を記載]