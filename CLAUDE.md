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
- [x] ユーザー登録・認証（オーナー/購買者別）
- [x] マイページ（オーナー/購買者別）
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
- **日本語で簡潔に記載**
- 変更内容が分かりやすいタイトルにする
- 例：「ユーザー認証システムの実装」「物件検索機能の追加」

#### 説明文
- **必ず日本語で記載**
- **Markdown形式**で記述
- **箇条書きで簡潔に**まとめる
- 以下のセクションを含める：
  - `## 概要` - 実装内容の要約
  - `## 実装内容` - 主な機能・変更点
  - `## 技術詳細` - 使用技術・設定内容
  - `## UI/UX改善` - デザイン・ユーザビリティ関連
  - `## 主要ファイル` - 変更されたファイル一覧
  - `## テスト内容` - チェックボックス形式で確認項目
  - `## 今後の拡張予定` - 将来の改善案（任意）

#### テンプレート例
```markdown
# 機能名の実装

## 概要
この機能の目的と効果を簡潔に記載

## 実装内容
- **機能A**: 具体的な説明
- **機能B**: 具体的な説明
- **機能C**: 具体的な説明

## 技術詳細
- **gem追加**: 追加したgem名
- **データベース**: テーブル・フィールド変更
- **設定**: 主要な設定変更

## UI/UX改善
- デザイン関連の改善点
- ユーザビリティ向上点

## 主要ファイル
### モデル
- `path/to/model.rb` - 説明

### コントローラー
- `path/to/controller.rb` - 説明

### ビュー
- `path/to/view.html.erb` - 説明

## テスト内容
- [x] 基本機能の動作確認
- [x] エラーハンドリングの確認
- [x] レスポンシブデザインの確認

## 今後の拡張予定
- 追加予定の機能
- 改善案

🤖 Generated with [Claude Code](https://claude.ai/code)
```

### ブランチ運用ルール
- `feature/機能名` でブランチを作成
- 機能完成後にPull Requestを作成
- レビュー後にmasterブランチにマージ

## 備考
- [その他の重要な情報を記載]