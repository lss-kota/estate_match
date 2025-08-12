import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="toggle"
export default class extends Controller {
  static targets = ["content", "icon"]

  connect() {
    console.log('Toggle controller connected!')
    // デフォルトで閉じた状態にする
    if (this.hasContentTarget) {
      this.contentTarget.classList.add("hidden")
      this.updateIcon(false)
    }
  }

  toggle(event) {
    console.log('Toggle method called!')
    
    if (event) {
      event.preventDefault()
    }
    
    if (!this.hasContentTarget) {
      console.error('Content target not found!')
      return
    }
    
    const isHidden = this.contentTarget.classList.contains("hidden")
    
    if (isHidden) {
      this.contentTarget.classList.remove("hidden")
      this.updateIcon(true)
      console.log('Opened search panel')
    } else {
      this.contentTarget.classList.add("hidden")
      this.updateIcon(false)
      console.log('Closed search panel')
    }
  }

  updateIcon(isExpanded) {
    if (this.hasIconTarget) {
      if (isExpanded) {
        // 展開時：矢印を上向きに回転
        this.iconTarget.style.transform = "rotate(180deg)"
      } else {
        // 閉じた時：矢印を下向きに戻す
        this.iconTarget.style.transform = "rotate(0deg)"
      }
    }
  }
}