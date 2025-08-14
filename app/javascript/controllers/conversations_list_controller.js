import { Controller } from "@hotwired/stimulus"
import consumer from "channels/consumer"

export default class extends Controller {
  static targets = ["conversation"]
  static values = { userId: Number }

  connect() {
    console.log("Conversations list controller connected")
    this.setupNotifications()
  }

  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
    }
  }

  // 新着メッセージ通知の設定
  setupNotifications() {
    // ユーザーの全ての会話をリッスン
    this.subscription = consumer.subscriptions.create(
      { channel: "UserNotificationChannel", user_id: this.userIdValue },
      {
        connected: () => {
          console.log("Connected to user notifications")
        },

        disconnected: () => {
          console.log("Disconnected from user notifications")
        },

        received: (data) => {
          this.handleNotification(data)
        }
      }
    )
  }

  // 通知を処理
  handleNotification(data) {
    switch (data.type) {
      case 'new_message':
        this.updateConversationPreview(data)
        this.showNotificationBadge(data.conversation_id)
        break
      default:
        console.log('Unknown notification type:', data.type)
    }
  }

  // 会話プレビューを更新
  updateConversationPreview(data) {
    const conversationElement = this.conversationTargets.find(element => 
      element.dataset.conversationId === data.conversation_id.toString()
    )

    if (conversationElement) {
      const lastMessageElement = conversationElement.querySelector('.last-message')
      const timeElement = conversationElement.querySelector('.last-message-time')

      if (lastMessageElement) {
        lastMessageElement.textContent = data.message.content
      }

      if (timeElement) {
        timeElement.textContent = data.message.formatted_time
      }

      // 会話を一番上に移動
      conversationElement.parentNode.insertBefore(conversationElement, conversationElement.parentNode.firstChild)
    }
  }

  // 未読バッジを表示
  showNotificationBadge(conversationId) {
    const conversationElement = this.conversationTargets.find(element => 
      element.dataset.conversationId === conversationId.toString()
    )

    if (conversationElement) {
      let badge = conversationElement.querySelector('.unread-badge')
      if (!badge) {
        badge = document.createElement('span')
        badge.className = 'unread-badge'
        badge.textContent = '新着'
        conversationElement.appendChild(badge)
      }
    }
  }

  // バッジをクリア（会話を開いた時）
  clearBadge(event) {
    const conversationElement = event.currentTarget
    const badge = conversationElement.querySelector('.unread-badge')
    if (badge) {
      badge.remove()
    }
  }
}