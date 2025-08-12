RSpec.configure do |config|
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::IntegrationHelpers, type: :request
  config.include Devise::Test::IntegrationHelpers, type: :feature
  
  # Ensure Warden test helpers are available
  config.include Warden::Test::Helpers
  config.after :each do
    Warden.test_reset!
  end
end