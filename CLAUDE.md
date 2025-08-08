# Estate Match

## プロジェクト概要
不動産マッチングサービス

## 技術スタック
- **フロントエンド**: [技術を記載]
- **バックエンド**: [技術を記載]
- **データベース**: [技術を記載]
- **インフラ**: [技術を記載]

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
- [ ] ユーザー登録・認証
- [ ] 物件検索・フィルタリング
- [ ] 物件詳細表示
- [ ] お気に入り機能
- [ ] マッチング機能
- [ ] メッセージング機能

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
npm run dev

# ビルド
npm run build

# テスト実行
npm test

# リント
npm run lint

# 型チェック
npm run typecheck
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

## 備考
- [その他の重要な情報を記載]