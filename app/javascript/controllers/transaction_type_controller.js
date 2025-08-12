import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="transaction-type"
export default class extends Controller {
  static targets = ["saleSection", "rentSection"]

  connect() {
    console.log("Transaction type controller connected")
    this.updatePriceFields()
    this.updateRadioStyles()
    
    // ラジオボタンの変更を監視
    this.element.addEventListener('change', (event) => {
      if (event.target.name === 'property[transaction_type]') {
        this.updatePriceFields()
        this.updateRadioStyles()
      }
    })
  }

  updatePriceFields(event) {
    // イベントから値を取得するか、現在選択されているラジオボタンから取得
    let transactionType
    if (event && event.target) {
      transactionType = event.target.value
    } else {
      const checkedRadio = this.element.querySelector('input[name="property[transaction_type]"]:checked')
      if (!checkedRadio) return
      transactionType = checkedRadio.value
    }
    
    console.log("Transaction type:", transactionType)
    
    // 売買セクションの表示/非表示
    const saleSection = this.element.querySelector('[data-transaction-type-target="saleSection"]')
    if (saleSection) {
      if (transactionType === 'sale' || transactionType === 'both') {
        saleSection.classList.remove('hidden')
        console.log("Showing sale section")
      } else {
        saleSection.classList.add('hidden')
        console.log("Hiding sale section")
      }
    }
    
    // 賃貸セクションの表示/非表示
    const rentSection = this.element.querySelector('[data-transaction-type-target="rentSection"]')
    if (rentSection) {
      if (transactionType === 'rent' || transactionType === 'both') {
        rentSection.classList.remove('hidden')
        console.log("Showing rent section")
      } else {
        rentSection.classList.add('hidden')
        console.log("Hiding rent section")
      }
    }
  }

  updateRadioStyles() {
    // すべてのラジオボタンラベルをリセット
    this.element.querySelectorAll('label[data-transaction-type]').forEach(label => {
      const radio = label.querySelector('input[type="radio"]')
      const checkIcon = label.querySelector('svg')
      
      if (radio && radio.checked) {
        label.classList.add('ring-2', 'ring-estate-primary-500', 'border-estate-primary-500')
        label.classList.remove('border-gray-300')
        if (checkIcon) {
          checkIcon.classList.remove('hidden')
        }
      } else {
        label.classList.remove('ring-2', 'ring-estate-primary-500', 'border-estate-primary-500')
        label.classList.add('border-gray-300')
        if (checkIcon) {
          checkIcon.classList.add('hidden')
        }
      }
    })
  }
}