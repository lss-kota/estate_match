import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="property-modal"
export default class extends Controller {
  static targets = ["modal", "backdrop", "content", "progressBar", "stepIndicator"]
  static values = { 
    currentStep: Number,
    totalSteps: Number
  }

  connect() {
    this.currentStepValue = 1
    this.totalStepsValue = 5
    console.log("Property modal controller connected!")
  }

  open() {
    console.log("Opening modal...")
    this.modalTarget.classList.remove("hidden")
    document.body.classList.add("overflow-hidden")
    this.updateProgress()
  }

  close() {
    console.log("Closing modal...")
    this.modalTarget.classList.add("hidden")
    document.body.classList.remove("overflow-hidden")
    // セッションクリア
    fetch('/properties/clear_session', { method: 'DELETE' })
  }

  closeOnBackdrop(event) {
    if (event.target === this.backdropTarget) {
      this.close()
    }
  }

  closeOnEscape(event) {
    if (event.key === "Escape") {
      this.close()
    }
  }

  nextStep() {
    if (this.currentStepValue < this.totalStepsValue) {
      this.currentStepValue++
      this.updateProgress()
    }
  }

  previousStep() {
    if (this.currentStepValue > 1) {
      this.currentStepValue--
      this.updateProgress()
    }
  }

  updateProgress() {
    const progressPercentage = (this.currentStepValue / this.totalStepsValue) * 100
    
    if (this.hasProgressBarTarget) {
      this.progressBarTarget.style.width = `${progressPercentage}%`
    }

    if (this.hasStepIndicatorTarget) {
      this.stepIndicatorTarget.textContent = `${this.currentStepValue} / ${this.totalStepsValue}`
    }
  }

  currentStepValueChanged() {
    this.updateProgress()
  }

  // Handle radio button changes
  handleRadioChange(event) {
    console.log("Radio changed:", event.target.value)
    
    // Update visual state for all radio buttons
    const allRadioOptions = this.element.querySelectorAll('.radio-option')
    
    allRadioOptions.forEach(option => {
      const radio = option.querySelector('input[type="radio"]')
      const card = option.querySelector('.radio-card')
      const button = option.querySelector('.radio-button')
      const dot = option.querySelector('.radio-dot')
      
      if (radio.checked) {
        // Selected state
        card.classList.remove('border-estate-warm-300')
        card.classList.add('border-estate-primary-600', 'bg-estate-primary-50')
        button.classList.remove('border-estate-warm-400')
        button.classList.add('border-estate-primary-600', 'bg-estate-primary-600')
        dot.classList.remove('opacity-0')
        dot.classList.add('opacity-100')
      } else {
        // Unselected state
        card.classList.remove('border-estate-primary-600', 'bg-estate-primary-50')
        card.classList.add('border-estate-warm-300')
        button.classList.remove('border-estate-primary-600', 'bg-estate-primary-600')
        button.classList.add('border-estate-warm-400')
        dot.classList.remove('opacity-100')
        dot.classList.add('opacity-0')
      }
    })
    
    // Update submit button
    this.updateSubmitButton()
  }

  updateSubmitButton() {
    const submitButton = this.element.querySelector('#step1_submit')
    if (!submitButton) return
    
    const selectedRadio = this.element.querySelector('input[name="transaction_type"]:checked')
    
    if (selectedRadio) {
      submitButton.disabled = false
      submitButton.classList.remove('opacity-50', 'cursor-not-allowed')
      submitButton.classList.add('cursor-pointer')
    } else {
      submitButton.disabled = true
      submitButton.classList.add('opacity-50', 'cursor-not-allowed')
      submitButton.classList.remove('cursor-pointer')
    }
  }

  // Navigation methods
  goToStep2(event) {
    console.log('Going to step 2 via Stimulus')
    fetch('/properties/new_step2', {
      method: 'GET',
      headers: {
        'Accept': 'text/vnd.turbo-stream.html',
        'X-Requested-With': 'XMLHttpRequest'
      }
    })
    .then(response => response.text())
    .then(html => {
      // Update the turbo frame content
      const frame = document.querySelector('turbo-frame[id="property_modal_content"]')
      if (frame) {
        frame.innerHTML = html
      }
    })
    .catch(error => console.error('Error:', error))
  }

  // Handle property submission
  submitProperty(event) {
    console.log('Stimulus submitProperty called!')
    
    const form = document.getElementById('property-submit-form')
    const submitButton = event.target
    
    if (!form || !submitButton) {
      console.error('Form or button not found')
      return
    }
    
    console.log('Form found, starting submission...')
    
    // Show loading state immediately
    submitButton.disabled = true
    submitButton.innerHTML = `
      <div class="flex items-center justify-center">
        <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
        投稿中...
      </div>
    `
    console.log('Loading state applied')
    
    // Prepare form data
    const formData = new FormData(form)
    
    // Add a small delay to ensure loading state is visible
    setTimeout(() => {
      console.log('Starting fetch request to:', form.action)
      
      // Submit via fetch
      fetch(form.action, {
        method: 'POST',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      .then(response => {
        console.log('Response received:', response.status)
        
        if (response.ok) {
          console.log('Success! Closing modal and redirecting...')
          
          // Success - close modal and redirect after short delay
          setTimeout(() => {
            this.close()
            window.location.href = '/dashboard'
          }, 500)
          
        } else {
          console.error('Form submission failed with status:', response.status)
          // Error - re-enable button
          submitButton.disabled = false
          submitButton.innerHTML = '🚀 物件を投稿する'
        }
      })
      .catch(error => {
        console.error('Error submitting form:', error)
        // Re-enable button on error
        submitButton.disabled = false
        submitButton.innerHTML = '🚀 物件を投稿する'
      })
    }, 100)
  }
};
