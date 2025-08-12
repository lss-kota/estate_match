import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Flash message controller connected!')
    this.checkForFlashMessage()
  }

  checkForFlashMessage() {
    // Check for flash messages in sessionStorage
    const notice = sessionStorage.getItem('flash_notice')
    const alert = sessionStorage.getItem('flash_alert')
    
    if (notice) {
      this.showNotice(notice)
      sessionStorage.removeItem('flash_notice')
    }
    
    if (alert) {
      this.showAlert(alert)
      sessionStorage.removeItem('flash_alert')
    }
  }

  showNotice(message) {
    const noticeElement = this.createFlashElement(message, 'success')
    document.body.appendChild(noticeElement)
    
    // Auto-hide after 5 seconds
    setTimeout(() => {
      this.removeFlashElement(noticeElement)
    }, 5000)
  }

  showAlert(message) {
    const alertElement = this.createFlashElement(message, 'error')
    document.body.appendChild(alertElement)
    
    // Auto-hide after 7 seconds
    setTimeout(() => {
      this.removeFlashElement(alertElement)
    }, 7000)
  }

  createFlashElement(message, type) {
    const div = document.createElement('div')
    
    const baseClasses = 'fixed top-4 right-4 z-50 p-4 rounded-lg shadow-lg max-w-sm transform transition-all duration-300 ease-in-out'
    const typeClasses = type === 'success' 
      ? 'bg-estate-success-100 border-estate-success-300 text-estate-success-700 border-2'
      : 'bg-red-100 border-red-300 text-red-700 border-2'
    
    div.className = `${baseClasses} ${typeClasses} translate-x-full opacity-0`
    
    div.innerHTML = `
      <div class="flex items-center justify-between">
        <div class="flex items-center">
          <span class="mr-3 text-lg">
            ${type === 'success' ? '✅' : '⚠️'}
          </span>
          <span class="font-medium">${message}</span>
        </div>
        <button onclick="this.parentElement.parentElement.remove()" 
                class="ml-4 text-gray-500 hover:text-gray-700 font-bold text-lg">
          ×
        </button>
      </div>
    `
    
    // Trigger animation after a brief delay
    setTimeout(() => {
      div.classList.remove('translate-x-full', 'opacity-0')
      div.classList.add('translate-x-0', 'opacity-100')
    }, 100)
    
    return div
  }

  removeFlashElement(element) {
    element.classList.add('translate-x-full', 'opacity-0')
    setTimeout(() => {
      if (element.parentNode) {
        element.parentNode.removeChild(element)
      }
    }, 300)
  }
};
