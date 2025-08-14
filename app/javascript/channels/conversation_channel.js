import consumer from "channels/consumer"

// 会話チャンネル管理
class ConversationChannelManager {
  constructor() {
    this.subscription = null
    this.conversationId = null
  }

  // チャンネルに接続
  connect(conversationId) {
    if (this.subscription) {
      this.disconnect()
    }

    this.conversationId = conversationId
    this.subscription = consumer.subscriptions.create(
      { channel: "ConversationChannel", conversation_id: conversationId },
      {
        connected: () => {
          console.log(`Connected to conversation ${conversationId}`)
        },

        disconnected: () => {
          console.log(`Disconnected from conversation ${conversationId}`)
        },

        received: (data) => {
          this.handleMessage(data)
        }
      }
    )
  }

  // チャンネルから切断
  disconnect() {
    if (this.subscription) {
      this.subscription.unsubscribe()
      this.subscription = null
      this.conversationId = null
    }
  }

  // メッセージ受信時の処理
  handleMessage(data) {
    switch (data.type) {
      case 'new_message':
        this.appendNewMessage(data)
        break
      case 'message_read':
        this.updateMessageReadStatus(data)
        break
      default:
        console.log('Unknown message type:', data.type)
    }
  }

  // 新しいメッセージを画面に追加
  appendNewMessage(data) {
    const messagesContainer = document.querySelector('#messages-container')
    if (messagesContainer) {
      // メッセージを追加
      const messagesList = messagesContainer.querySelector('.space-y-4')
      if (messagesList) {
        messagesList.insertAdjacentHTML('beforeend', data.message_html)
      } else {
        messagesContainer.insertAdjacentHTML('beforeend', data.message_html)
      }
      this.scrollToBottom()
      this.playNotificationSound()
    }
  }

  // メッセージの既読状態を更新
  updateMessageReadStatus(data) {
    const messageElement = document.querySelector(`[data-message-id="${data.message_id}"]`)
    if (messageElement) {
      const readIndicator = messageElement.querySelector('.read-indicator')
      if (readIndicator) {
        readIndicator.textContent = '既読'
        readIndicator.classList.add('read')
      }
    }
  }

  // メッセージ一覧を最下部までスクロール
  scrollToBottom() {
    const messagesContainer = document.querySelector('#messages-container')
    if (messagesContainer) {
      // 少し遅延を入れてDOMの更新を待つ
      setTimeout(() => {
        messagesContainer.scrollTo({
          top: messagesContainer.scrollHeight,
          behavior: 'smooth'
        })
      }, 100)
    }
  }

  // 通知音を再生（オプション）
  playNotificationSound() {
    // 必要に応じて通知音を追加
    console.log('New message received')
  }

  // メッセージを既読にマーク
  markAsRead(messageId) {
    if (this.subscription) {
      this.subscription.perform('mark_as_read', { message_id: messageId })
    }
  }
}

// グローバルに公開
window.ConversationChannelManager = ConversationChannelManager

export default ConversationChannelManager