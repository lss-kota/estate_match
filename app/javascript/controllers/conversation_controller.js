import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["messages", "form", "content", "submit"]
  static values = { conversationId: Number, currentUserId: Number }

  connect() {
    // ページ読み込み時は瞬間的に最下部に移動
    setTimeout(() => this.jumpToLatestMessage(), 50)
    // 保険として少し遅らせてもう一度実行
    setTimeout(() => this.jumpToLatestMessage(), 200)
  }

  disconnect() {
    // コントローラー切断時の処理
  }

  // 送信ボタンクリック時の処理
  sendMessage(event) {
    event.preventDefault()
    
    const content = this.contentTarget.value.trim()
    
    if (!content) {
      return
    }

    // 送信ボタンを無効化
    this.disableSubmitButton()
    
    const formData = new FormData(this.formTarget)
    
    fetch(this.formTarget.action, {
      method: 'POST',
      body: formData,
      headers: {
        'Accept': 'application/json',
        'X-Requested-With': 'XMLHttpRequest',
        'X-CSRF-Token': document.querySelector('[name="csrf-token"]').content
      }
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        // フォームをクリア
        this.contentTarget.value = ''
        // フォーカスを外す
        this.contentTarget.blur()
        // 新しいメッセージを動的に追加
        this.addNewMessage(data.message_html)
        // 瞬間的に最新メッセージまで移動
        this.jumpToLatestMessage()
      }
      this.enableSubmitButton()
    })
    .catch(error => {
      console.error('Message send error:', error)
      this.enableSubmitButton()
    })
  }

  // 送信ボタンの無効化
  disableSubmitButton() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = true
      this.submitTarget.textContent = '送信中...'
      this.submitTarget.classList.add('opacity-50', 'cursor-not-allowed')
    }
  }

  // 送信ボタンの有効化
  enableSubmitButton() {
    if (this.hasSubmitTarget) {
      this.submitTarget.disabled = false
      this.submitTarget.textContent = '送信'
      this.submitTarget.classList.remove('opacity-50', 'cursor-not-allowed')
    }
  }

  // 新しいメッセージを動的に追加
  addNewMessage(messageHtml) {
    if (this.hasMessagesTarget) {
      // メッセージコンテナ内のメッセージリストを取得
      const messagesList = this.messagesTarget.querySelector('.space-y-4')
      if (messagesList) {
        // 新しいメッセージを最下部に追加
        messagesList.insertAdjacentHTML('beforeend', messageHtml)
      } else {
        // 初回メッセージの場合（空状態から最初のメッセージ）
        // 空状態の内容を置き換える
        this.messagesTarget.innerHTML = `<div class="space-y-4">${messageHtml}</div>`
      }
    }
  }

  // 瞬間的に最新メッセージまで移動（LINE/SMS風）
  jumpToLatestMessage() {
    if (this.hasMessagesTarget) {
      const container = this.messagesTarget
      // behaviorを指定しない（またはinstant）で瞬間移動
      container.scrollTo({
        top: container.scrollHeight,
        behavior: 'instant'
      })
    }
  }

  // スムーススクロール版（必要な場合用）
  scrollToBottom() {
    if (this.hasMessagesTarget) {
      const container = this.messagesTarget
      container.scrollTo({
        top: container.scrollHeight,
        behavior: 'smooth'
      })
    }
  }
}