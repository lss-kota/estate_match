import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="property-image"
export default class extends Controller {
  static targets = ["imageGrid", "floorPlanDisplay", "fileInput"]

  connect() {
    console.log("Property image controller connected")
  }

  // 既存の画像を削除する
  removeImage(event) {
    const imageId = event.currentTarget.dataset.imageId
    const imageContainer = event.currentTarget.closest('.image-container')
    
    if (confirm('この画像を削除しますか？')) {
      // 画像コンテナを非表示にする（実際の削除はフォーム送信時）
      imageContainer.style.display = 'none'
      
      // 削除対象の画像IDを隠しフィールドに追加
      this.addToDeleteList(imageId)
    }
  }

  // 間取り図を削除する
  removeFloorPlan(event) {
    const floorPlanContainer = event.currentTarget.closest('.floor-plan-container')
    
    if (confirm('間取り図を削除しますか？')) {
      floorPlanContainer.style.display = 'none'
      
      // 削除フラグを立てる
      this.addFloorPlanDeleteFlag()
    }
  }

  // ファイル選択時のプレビュー表示
  previewImages(event) {
    const files = event.target.files
    const previewContainer = document.getElementById('image-preview')
    
    if (!previewContainer) {
      // プレビューコンテナを作成
      const container = document.createElement('div')
      container.id = 'image-preview'
      container.className = 'mt-4 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-4 gap-4'
      event.target.closest('.space-y-6').appendChild(container)
    }
    
    // 既存のプレビューをクリア
    document.getElementById('image-preview').innerHTML = ''
    
    // 各ファイルのプレビューを作成
    Array.from(files).forEach((file, index) => {
      if (file.type.startsWith('image/')) {
        const reader = new FileReader()
        reader.onload = (e) => {
          const previewElement = this.createPreviewElement(e.target.result, file.name, index)
          document.getElementById('image-preview').appendChild(previewElement)
        }
        reader.readAsDataURL(file)
      }
    })
  }

  // プレビュー要素を作成
  createPreviewElement(src, fileName, index) {
    const div = document.createElement('div')
    div.className = 'relative group'
    div.innerHTML = `
      <img src="${src}" alt="${fileName}" class="w-full h-24 object-cover rounded-lg border border-gray-200">
      <div class="absolute inset-0 bg-black bg-opacity-0 group-hover:bg-opacity-30 transition-all duration-200 rounded-lg flex items-center justify-center">
        <button type="button" 
                class="opacity-0 group-hover:opacity-100 bg-red-500 text-white rounded-full p-1 text-xs hover:bg-red-600 transition-all duration-200"
                data-action="click->property-image#removePreview"
                data-index="${index}">
          <svg class="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M6 18L18 6M6 6l12 12"></path>
          </svg>
        </button>
      </div>
    `
    return div
  }

  // プレビュー画像を削除
  removePreview(event) {
    const index = parseInt(event.currentTarget.dataset.index)
    const fileInput = this.fileInputTarget
    
    // FileListから指定のファイルを削除（新しいFileListを作成）
    const dt = new DataTransfer()
    const files = fileInput.files
    
    for (let i = 0; i < files.length; i++) {
      if (i !== index) {
        dt.items.add(files[i])
      }
    }
    
    fileInput.files = dt.files
    
    // プレビューを再生成
    this.previewImages({ target: fileInput })
  }

  // 削除対象画像IDを隠しフィールドに追加
  addToDeleteList(imageId) {
    // 削除用の隠しフィールドを作成（複数の画像削除に対応するため個別のフィールドを作成）
    const deleteField = document.createElement('input')
    deleteField.type = 'hidden'
    deleteField.name = 'property[delete_image_ids][]'
    deleteField.value = imageId
    this.element.appendChild(deleteField)
  }

  // 間取り図削除フラグを立てる
  addFloorPlanDeleteFlag() {
    let deleteField = document.querySelector('input[name="property[delete_floor_plan]"]')
    
    if (!deleteField) {
      deleteField = document.createElement('input')
      deleteField.type = 'hidden'
      deleteField.name = 'property[delete_floor_plan]'
      deleteField.value = '1'
      this.element.appendChild(deleteField)
    }
  }

  // ドラッグ&ドロップ処理
  handleDrop(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const files = event.dataTransfer.files
    const fileInput = this.fileInputTarget
    
    if (files.length > 0) {
      // DataTransferを使用してFileInputにファイルを設定
      const dt = new DataTransfer()
      
      // 既存のファイルを保持
      Array.from(fileInput.files).forEach(file => dt.items.add(file))
      
      // 新しいファイルを追加
      Array.from(files).forEach(file => {
        if (file.type.startsWith('image/')) {
          dt.items.add(file)
        }
      })
      
      fileInput.files = dt.files
      this.previewImages({ target: fileInput })
    }
    
    this.removeDragStyles(event.currentTarget)
  }

  handleDragOver(event) {
    event.preventDefault()
    event.stopPropagation()
    this.addDragStyles(event.currentTarget)
  }

  handleDragLeave(event) {
    event.preventDefault()
    event.stopPropagation()
    this.removeDragStyles(event.currentTarget)
  }

  addDragStyles(element) {
    element.classList.add('border-estate-primary-400', 'bg-estate-primary-50')
  }

  removeDragStyles(element) {
    element.classList.remove('border-estate-primary-400', 'bg-estate-primary-50')
  }
}