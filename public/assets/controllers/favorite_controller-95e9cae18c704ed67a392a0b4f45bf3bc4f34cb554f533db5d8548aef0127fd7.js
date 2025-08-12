import { Controller } from "@hotwired/stimulus"

// お気に入り機能のStimulusコントローラー
export default class extends Controller {
  static values = { 
    propertyId: Number,
    favorited: Boolean 
  }

  connect() {
    console.log("Favorite controller connected")
    console.log("Property ID:", this.propertyIdValue)
    console.log("Favorited:", this.favoritedValue)
  }

  // お気に入りのトグル処理
  async toggle(event) {
    console.log("Toggle method called!")
    event.preventDefault()
    event.stopPropagation()

    const propertyId = this.propertyIdValue
    const isFavorited = this.favoritedValue
    
    console.log("Toggling favorite for property:", propertyId, "currently favorited:", isFavorited)

    try {
      // ボタンの状態を一時的に変更（楽観的UI更新）
      this.updateButtonState(!isFavorited)

      let response
      if (isFavorited) {
        // お気に入りから削除
        response = await fetch(`/properties/${propertyId}/favorite`, {
          method: 'DELETE',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': this.getCSRFToken()
          }
        })
      } else {
        // お気に入りに追加
        response = await fetch(`/properties/${propertyId}/favorite`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'X-CSRF-Token': this.getCSRFToken()
          }
        })
      }

      if (response.ok) {
        const data = await response.json()
        
        // レスポンスの状態でボタンを更新
        this.updateButtonState(data.favorited)
        this.favoritedValue = data.favorited

        // 成功メッセージを表示（オプション）
        this.showMessage(data.message, 'success')
      } else {
        // エラーの場合は元の状態に戻す
        this.updateButtonState(isFavorited)
        const errorData = await response.json()
        this.showMessage(errorData.message || 'エラーが発生しました', 'error')
      }
    } catch (error) {
      console.error('Favorite toggle error:', error)
      // エラーの場合は元の状態に戻す
      this.updateButtonState(isFavorited)
      this.showMessage('ネットワークエラーが発生しました', 'error')
    }
  }

  // ボタンの表示状態を更新
  updateButtonState(isFavorited) {
    const svg = this.element.querySelector('svg')
    
    if (isFavorited) {
      this.element.classList.add('favorited')
      svg.setAttribute('fill', 'currentColor')
    } else {
      this.element.classList.remove('favorited')
      svg.setAttribute('fill', 'none')
    }
    
    // 物件詳細ページの場合はテキストとスタイルも更新
    const favoriteText = this.element.querySelector('.favorite-text')
    if (favoriteText) {
      favoriteText.textContent = isFavorited ? 'お気に入り済' : 'お気に入りに追加する'
      
      // ボタンのスタイルクラスを更新
      if (isFavorited) {
        this.element.className = this.element.className.replace(
          'bg-pink-50 border-pink-200 text-pink-700 hover:bg-pink-100 hover:border-pink-300 hover:text-pink-800',
          'bg-gray-50 border-gray-200 text-gray-700'
        )
      } else {
        this.element.className = this.element.className.replace(
          'bg-gray-50 border-gray-200 text-gray-700',
          'bg-pink-50 border-pink-200 text-pink-700 hover:bg-pink-100 hover:border-pink-300 hover:text-pink-800'
        )
      }
    }
  }

  // CSRFトークンを取得
  getCSRFToken() {
    const token = document.querySelector('meta[name="csrf-token"]')
    return token ? token.getAttribute('content') : ''
  }

  // メッセージを表示（簡易実装）
  showMessage(message, type) {
    // 簡単なトースト通知を作成
    const toast = document.createElement('div')
    toast.className = `fixed top-4 right-4 z-50 px-4 py-2 rounded-md text-white font-medium ${
      type === 'success' ? 'bg-green-500' : 'bg-red-500'
    }`
    toast.textContent = message

    document.body.appendChild(toast)

    // 3秒後に削除
    setTimeout(() => {
      if (toast.parentNode) {
        toast.parentNode.removeChild(toast)
      }
    }, 3000)
  }
};
