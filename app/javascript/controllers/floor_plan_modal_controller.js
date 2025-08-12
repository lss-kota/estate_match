import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="floor-plan-modal"
export default class extends Controller {
  connect() {
    console.log("Floor plan modal controller connected")
  }

  open(event) {
    event.preventDefault()
    const modal = document.getElementById('floor-plan-modal')
    if (modal) {
      modal.classList.remove('hidden')
      // body要素のスクロールを無効化
      document.body.style.overflow = 'hidden'
    }
  }

  close(event) {
    event.preventDefault()
    event.stopPropagation()
    const modal = document.getElementById('floor-plan-modal')
    if (modal) {
      modal.classList.add('hidden')
      // body要素のスクロールを有効化
      document.body.style.overflow = ''
    }
  }

  // ESCキーでモーダルを閉じる
  closeOnEscape(event) {
    if (event.key === 'Escape') {
      this.close(event)
    }
  }

  // モーダルが表示されたときにESCキーリスナーを追加
  disconnect() {
    document.body.style.overflow = ''
    document.removeEventListener('keydown', this.closeOnEscape.bind(this))
  }

  // コントローラー接続時にESCキーリスナーを追加
  initialize() {
    document.addEventListener('keydown', this.closeOnEscape.bind(this))
  }
}