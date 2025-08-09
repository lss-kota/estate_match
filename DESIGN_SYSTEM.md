# Estate Match デザインシステム

## 概要

Estate Matchは空き家・空き地マッチングサービスのためのプロフェッショナルなデザインシステムです。信頼性、安心感、そして不動産業界の専門性を表現する洗練されたブランディングを提供します。

## ブランドカラー

### メインカラーパレット

#### Primary Colors（プライマリ）
**Deep Slate Blue (#5A7194)** - メインブランドカラー
- 信頼性と専門性を表現
- ヘッダー、主要ボタン、強調要素に使用

```css
--color-estate-primary-50: #f1f4f8;
--color-estate-primary-100: #e3e9f1;
--color-estate-primary-200: #cad6e5;
--color-estate-primary-300: #a8bbd3;
--color-estate-primary-400: #7f9bc1;
--color-estate-primary-500: #5a7194;  /* Base color */
--color-estate-primary-600: #4a5e7c;
--color-estate-primary-700: #3d4d65;
--color-estate-primary-800: #313f54;
--color-estate-primary-900: #293446;
```

#### Secondary Colors（セカンダリ）
**Light Slate Blue (#A6AFC1)** - サポートカラー
- 調和とバランスを提供
- サブテキスト、アイコン、境界線に使用

```css
--color-estate-secondary-50: #f8f9fb;
--color-estate-secondary-100: #f1f3f7;
--color-estate-secondary-200: #e6eaef;
--color-estate-secondary-300: #d2d9e3;
--color-estate-secondary-400: #b8c3d1;
--color-estate-secondary-500: #a6afc1;  /* Base color */
--color-estate-secondary-600: #8792a8;
--color-estate-secondary-700: #6d7a91;
--color-estate-secondary-800: #596377;
--color-estate-secondary-900: #4a5262;
```

#### Warm Colors（暖色）
**Warm Beige (#E8E6DB)** - 背景カラー
- 温かみと親しみやすさを演出
- 背景、カード、セクション区切りに使用

```css
--color-estate-warm-50: #fefefe;
--color-estate-warm-100: #fafaf8;
--color-estate-warm-200: #f5f4f0;
--color-estate-warm-300: #eeede6;
--color-estate-warm-400: #e8e6db;  /* Base color */
--color-estate-warm-500: #d6d2c1;
--color-estate-warm-600: #beb8a4;
--color-estate-warm-700: #a19688;
--color-estate-warm-800: #877b6f;
--color-estate-warm-900: #6b5f56;
```

#### Dark Colors（ダーク）
**Dark Navy (#233858)** - アクセントカラー
- 権威性と安定感を表現
- フッター、濃い背景、重要な見出しに使用

```css
--color-estate-dark-50: #f0f2f5;
--color-estate-dark-100: #e1e6eb;
--color-estate-dark-200: #c6cfd8;
--color-estate-dark-300: #a0aec0;
--color-estate-dark-400: #718096;
--color-estate-dark-500: #4a5568;
--color-estate-dark-600: #2d3748;
--color-estate-dark-700: #233858;  /* Base color */
--color-estate-dark-800: #1a202c;
--color-estate-dark-900: #171923;
```

### アクセントカラー

#### Gold Colors（ゴールド）
**Accent Gold** - CTA・ハイライト用
- 高級感と成功を象徴
- 主要CTA、価格表示、アワード要素に使用

```css
--color-estate-gold-300: #edcc9b;
--color-estate-gold-400: #e4b870;  /* Primary gold */
--color-estate-gold-500: #d4a574;
```

#### Success Colors（サクセス）
**Success Green** - 成功状態表示用
- 安全性と成功を表現
- 成功メッセージ、承認状態、完了インジケーターに使用

```css
--color-estate-success-100: #dcf2e3;
--color-estate-success-600: #22563b;
```

## カラー使用ガイドライン

### Hero Section
- **背景**: `bg-gradient-to-br from-estate-primary-600 via-estate-primary-700 to-estate-dark-700`
- **メインテキスト**: `text-white`
- **アクセント**: `text-estate-gold-300`
- **サブテキスト**: `text-estate-primary-100`

### Stats Section
- **背景**: `bg-estate-warm-100`
- **数値**: `text-estate-primary-600`、`text-estate-success-600`、`text-estate-secondary-600`
- **ラベル**: `text-estate-dark-500`

### Features Section
- **背景**: `bg-estate-warm-200`
- **カード背景**: `bg-white`
- **アイコン背景**: 各機能別（Primary、Success、Secondary）の100番台
- **見出し**: `text-estate-dark-800`
- **本文**: `text-estate-dark-500`

### CTA Section
- **背景**: `bg-gradient-to-r from-estate-primary-600 to-estate-secondary-600`
- **メインボタン**: `bg-estate-gold-400 hover:bg-estate-gold-500`
- **サブボタン**: `bg-white hover:bg-estate-warm-200`

### Footer
- **背景**: `bg-estate-dark-800`
- **メインテキスト**: `text-white`
- **サブテキスト**: `text-estate-dark-300`
- **境界線**: `border-estate-dark-700`

## レスポンシブデザイン

### ブレイクポイント
- **sm**: 40rem (640px)
- **md**: 48rem (768px)
- **lg**: 64rem (1024px)
- **xl**: 80rem (1280px)

### コンテナサイズ
- **max-w-3xl**: 48rem
- **max-w-4xl**: 56rem
- **max-w-7xl**: 80rem

## タイポグラフィ

### フォントスケール
```css
--text-lg: 1.125rem;     /* 18px */
--text-xl: 1.25rem;      /* 20px */
--text-2xl: 1.5rem;      /* 24px */
--text-3xl: 1.875rem;    /* 30px */
--text-4xl: 2.25rem;     /* 36px */
--text-6xl: 3.75rem;     /* 60px */
```

### フォントウェイト
- **font-semibold**: 600
- **font-bold**: 700

### 行間
- **leading-tight**: 1.25
- **leading-relaxed**: 1.625

## アニメーション

### 背景画像アニメーション
```css
.hero-bg-animate {
  animation: subtle-zoom 20s ease-in-out infinite;
}

@keyframes subtle-zoom {
  0%, 100% { transform: scale(1); }
  50% { transform: scale(1.05); }
}
```

### ホバーエフェクト
```css
.float-animation {
  animation: float 6s ease-in-out infinite;
}

@keyframes float {
  0%, 100% { transform: translateY(0px); }
  50% { transform: translateY(-10px); }
}
```

## コンポーネント別デザインパターン

### ボタン
#### プライマリボタン
```html
<button class="bg-estate-gold-400 hover:bg-estate-gold-500 text-estate-dark-900 font-bold px-8 py-4 rounded-full text-lg transition duration-300 transform hover:scale-105">
```

#### セカンダリボタン
```html
<button class="border-2 border-white hover:bg-white hover:text-estate-primary-700 text-white font-bold px-8 py-4 rounded-full text-lg transition duration-300">
```

### カード
```html
<div class="bg-white rounded-2xl shadow-lg p-8 text-center hover:shadow-xl transition duration-300">
```

### アイコン背景
```html
<div class="w-20 h-20 bg-estate-primary-100 rounded-full flex items-center justify-center mx-auto mb-6">
```

## アクセシビリティ

### カラーコントラスト
- すべてのテキストと背景の組み合わせはWCAG AA基準（4.5:1以上）を満たします
- 重要な情報は色だけに依存せず、アイコンやテキストでも表現

### フォーカス状態
- すべてのインタラクティブ要素に明確なフォーカス状態を提供
- キーボードナビゲーションをサポート

## 実装方法

### Tailwind CSS v4での実装
カスタムカラーは `app/assets/tailwind/application.css` の `@theme` ブロックで定義されています：

```css
@theme {
  /* Estate Match Brand Colors */
  --color-estate-primary-500: #5a7194;
  --color-estate-secondary-500: #a6afc1;
  --color-estate-warm-400: #e8e6db;
  --color-estate-dark-700: #233858;
  /* ... */
}
```

### 使用方法
```html
<!-- プライマリカラー使用例 -->
<div class="bg-estate-primary-600 text-white">
  <h1 class="text-estate-gold-300">Estate Match</h1>
</div>

<!-- グラデーション使用例 -->
<section class="bg-gradient-to-br from-estate-primary-600 via-estate-primary-700 to-estate-dark-700">
</section>
```

## ブランド価値の表現

### 信頼性
- ダークブルー系の色合いで専門性を表現
- 一貫したカラーパレットで統一感を演出

### 親しみやすさ
- 暖色系（ベージュ）で温かみを提供
- 丸みを帯びたコンポーネントで優しい印象

### プロフェッショナル
- 洗練されたカラーハーモニー
- 適切な余白とタイポグラフィ

### 安心感
- 緑色（サクセスカラー）で安全性を表現
- 明確な視覚的階層で分かりやすいUI

---

*このデザインシステムは Estate Match プロジェクト専用に設計されており、不動産マッチングサービスのブランド価値を最大化するための包括的なガイドラインです。*