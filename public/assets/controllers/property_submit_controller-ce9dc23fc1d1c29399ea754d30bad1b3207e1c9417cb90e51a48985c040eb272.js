import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log('Property submit controller connected!')
  }

  submit(event) {
    try {
      event.preventDefault()
      event.stopPropagation()
      console.log('Stimulus submit called!')
      
      const formDiv = document.getElementById('property-submit-form')
      const submitButton = event.target
      
      console.log('Form div:', formDiv)
      console.log('Submit button:', submitButton)
      
      if (!formDiv || !submitButton) {
        console.error('Form div or button not found')
        return
      }
      
      const formAction = formDiv.getAttribute('data-form-url')
      console.log('Form action:', formAction)
      
      if (!formAction) {
        console.error('Form action URL not found')
        return
      }
      
      console.log('Form found, starting submission...')
      console.log('Original button content:', submitButton.innerHTML)
    
    // Show loading state immediately
    submitButton.disabled = true
    console.log('Button disabled:', submitButton.disabled)
    
    submitButton.innerHTML = `
      <div class="flex items-center justify-center">
        <div class="animate-spin rounded-full h-5 w-5 border-b-2 border-white mr-2"></div>
        投稿中...
      </div>
    `
    console.log('New button content:', submitButton.innerHTML)
    console.log('Loading state applied')
    
    // Prepare form data
    const formData = new FormData()
    const tokenInput = formDiv.querySelector('input[name="authenticity_token"]')
    if (tokenInput) {
      formData.append('authenticity_token', tokenInput.value)
      console.log('Added authenticity token:', tokenInput.value)
    } else {
      console.warn('Authenticity token not found')
    }
    
    // Add a longer delay to ensure loading state is visible
    setTimeout(() => {
      console.log('Starting fetch request to:', formAction)
      
      // Submit via fetch
      fetch(formAction, {
        method: 'POST',
        body: formData,
        headers: {
          'X-Requested-With': 'XMLHttpRequest'
        }
      })
      .then(response => {
        console.log('Response received:', response.status)
        
        if (response.ok) {
          console.log('Success! Property saved to database.')
          console.log('Skipping redirect for debugging...')
          
          // Temporary: Skip redirect for debugging
          // setTimeout(() => {
          //   const modal = document.querySelector('[data-property-modal-target="modal"]')
          //   if (modal) {
          //     modal.classList.add('hidden')
          //   }
          //   window.location.href = '/dashboard'
          // }, 500)
          
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
    }, 2000) // 2秒の遅延でローディング表示を確認
    
    } catch (error) {
      console.error('Error in submit method:', error)
      console.error('Stack trace:', error.stack)
    }
  }
};
