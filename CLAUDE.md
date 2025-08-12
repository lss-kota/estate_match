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
- [x] 物件投稿機能（オーナー向け・画像・間取り図アップロード対応）
- [x] 物件一覧・詳細表示機能
- [x] お気に入り機能（購買者向け・非同期操作・マイページで確認）
- [ ] 物件検索機能（購買者向け・タグ/フィルタ対応）
- [ ] チャット機能（購買者⇔オーナー間）

## API仕様
### エンドポイント一覧
- `GET /properties` - 物件一覧取得
- `GET /properties/:id` - 物件詳細取得
- `POST /properties` - 物件新規作成（オーナー向け）
- `PATCH/PUT /properties/:id` - 物件更新（オーナー向け）
- `DELETE /properties/:id` - 物件削除（オーナー向け）
- `POST /properties/:id/favorite` - お気に入り追加（購買者向け）
- `DELETE /properties/:id/favorite` - お気に入り削除（購買者向け）
- `GET /favorites` - お気に入り一覧取得（購買者向け）
- `POST /users/sign_up` - ユーザー登録
- `POST /users/sign_in` - ログイン
- `DELETE /users/sign_out` - ログアウト

## データベーススキーマ
### Users テーブル
- id: Primary Key
- email: String (Unique)
- password: String (Hashed)
- user_type: String (owner/buyer)
- name: String
- created_at: DateTime
- updated_at: DateTime

### Properties テーブル
- id: Primary Key
- user_id: Integer (Foreign Key)
- title: String
- description: Text
- property_type: String (vacant_house/vacant_land)
- prefecture: String
- city: String
- address: String
- sale_price: Integer
- rental_price: Integer
- building_area: Decimal
- land_area: Decimal
- construction_year: Integer
- rooms: String
- parking: String
- status: String (active/sold/rented/draft)
- created_at: DateTime
- updated_at: DateTime

### Favorites テーブル (中間テーブル)
- id: Primary Key
- user_id: Integer (Foreign Key)
- property_id: Integer (Foreign Key)
- created_at: DateTime
- updated_at: DateTime
- **Index**: user_id, property_id (Unique)

## 開発コマンド
```bash
# 開発サーバー起動
bin/rails server

# データベース作成・マイグレーション
bin/rails db:create
bin/rails db:migrate

# アセットコンパイル
bin/rails assets:precompile

# キャッシュクリア
bin/rails tmp:clear
bin/rails assets:clobber

# テスト実行（RSpec）
bundle exec rspec

# テスト実行（従来のRails Test）
bin/rails test

# コンソール起動
bin/rails console

# リント（RuboCop）
bundle exec rubocop

# セキュリティチェック（Brakeman）
bundle exec brakeman
```

## コーディング規約
- **JavaScript**: Stimulus フレームワーク使用
- **CSS**: Tailwind CSS + カスタムCSS
- **Ruby**: RuboCop準拠
- **ファイル命名**: snake_case (Ruby), kebab-case (HTML/CSS)
- **関数命名**: snake_case (Ruby), camelCase (JavaScript)
- **クラス命名**: PascalCase (Ruby), kebab-case (CSS)

## テスト規約
- **テスト駆動開発**: 新機能実装時は必ずRSpecテストを作成する
- **テストファイル構成**:
  - `spec/models/` - モデルテスト（バリデーション、アソシエーション、メソッド）
  - `spec/requests/` - コントローラーテスト（CRUD操作、認証・認可）  
  - `spec/factories/` - FactoryBotによるテストデータ定義
- **テスト実行**: 実装後は必ず `bundle exec rspec` でテストが通ることを確認
- **テストカバレッジ**: 新規実装した機能に対して適切なテストケースを作成
- **テストの品質**:
  - 正常系・異常系の両方をテスト
  - エッジケースも考慮したテストを作成
  - 可読性の高いテストコードを心がける

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
- [x] RSpecテストの作成・実行

## 今後の拡張予定
- 追加予定の機能
- 改善案

🤖 Generated with [Claude Code](https://claude.ai/code)
```

### ブランチ運用ルール
- `feature/機能名` でブランチを作成
- 機能完成後にPull Requestを作成
- **CI/CDパイプライン**: GitHub ActionsでRSpecテストが自動実行
- **ブランチプロテクション**: テストが通らないとマージ不可
- レビュー後にmasterブランチにマージ

### GitHub Actions CI設定
- **ファイル**: `.github/workflows/ci.yml`
- **実行タイミング**: PR作成時・pushタイミング
- **テスト内容**:
  - RSpecテストの実行
  - RuboCop（リンター）の実行
  - Brakeman（セキュリティ）の実行
- **データベース**: MySQL 8.0コンテナを使用
- **Ruby**: 3.2.2, Node.js: 18を使用

### ブランチプロテクションルール設定手順
1. GitHubリポジトリの「Settings」→「Branches」
2. 「Add rule」をクリック
3. **Branch name pattern**: `main` または `master`
4. 以下の設定を有効にする：
   - ✅ **Require a pull request before merging**
     - ✅ Require approvals (1人以上)
     - ✅ Dismiss stale PR approvals when new commits are pushed
   - ✅ **Require status checks to pass before merging**
     - ✅ Require branches to be up to date before merging
     - ✅ **Status checks**: `test` (CIジョブ名)
   - ✅ **Require conversation resolution before merging**
   - ✅ **Include administrators** (管理者にもルールを適用)
5. 「Create」をクリックして保存

## 備考
- [その他の重要な情報を記載]