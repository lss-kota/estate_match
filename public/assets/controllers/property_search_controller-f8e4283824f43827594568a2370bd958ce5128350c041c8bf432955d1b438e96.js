import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["searchForm", "results"]

  connect() {
    console.log('Property search controller connected!')
  }

  // リアルタイム検索（オプション）
  search(event) {
    // デバウンス処理
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.performSearch()
    }, 500)
  }

  // 検索実行
  performSearch() {
    const formData = new FormData(this.searchFormTarget)
    const params = new URLSearchParams(formData)
    
    // 現在のURLを更新（履歴に残さない）
    const newUrl = `${window.location.pathname}?${params.toString()}`
    
    fetch(newUrl, {
      method: 'GET',
      headers: {
        'Accept': 'text/html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      // 結果部分のみ更新する場合
      if (this.hasResultsTarget) {
        const parser = new DOMParser()
        const doc = parser.parseFromString(html, 'text/html')
        const newResults = doc.querySelector('[data-property-search-target="results"]')
        if (newResults) {
          this.resultsTarget.innerHTML = newResults.innerHTML
        }
      } else {
        // ページ全体を更新
        document.body.innerHTML = html
      }
    })
    .catch(error => {
      console.error('Search failed:', error)
    })
  }

  // フォームリセット
  resetForm() {
    this.searchFormTarget.reset()
    // ページを初期状態に戻す
    window.location.href = window.location.pathname
  }

  // 価格入力の数値フォーマット
  formatPrice(event) {
    const input = event.target
    let value = input.value.replace(/[^\d]/g, '') // 数字以外を除去
    
    if (value) {
      // 3桁区切りのカンマを追加
      value = Number(value).toLocaleString()
    }
    
    input.value = value
  }

  // 検索条件の保存（ローカルストレージ）
  saveSearchConditions() {
    const formData = new FormData(this.searchFormTarget)
    const conditions = Object.fromEntries(formData.entries())
    localStorage.setItem('property_search_conditions', JSON.stringify(conditions))
  }

  // 検索条件の復元
  loadSearchConditions() {
    const saved = localStorage.getItem('property_search_conditions')
    if (saved) {
      try {
        const conditions = JSON.parse(saved)
        Object.entries(conditions).forEach(([key, value]) => {
          const input = this.searchFormTarget.querySelector(`[name="${key}"]`)
          if (input && value) {
            input.value = value
          }
        })
      } catch (error) {
        console.error('Failed to load search conditions:', error)
      }
    }
  }
};
