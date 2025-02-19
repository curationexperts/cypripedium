# frozen_string_literal: true

# Setup chrome headless driver
Capybara.register_driver :chrome_headless do |app|
  client = Selenium::WebDriver::Remote::Http::Default.new
  client.read_timeout = 120

  options = ::Selenium::WebDriver::Chrome::Options.new
  options.add_argument('--headless=new')
  options.add_argument('--no-sandbox')
  options.add_argument('--disable-dev-shm-usage')
  options.add_argument('--window-size=1400,1400')

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options, http_client: client)
end

# Configure Capybara
Capybara.server = :puma, { Silent: true }
Capybara.javascript_driver = :chrome_headless

# Disable animations during test suite, this helps make testing certain bootstrap elements like modals more reliable
Capybara.disable_animation

# Override Rails System Test default driver - driven_by(:selenium)
RSpec.configure do |config|
  config.before(:each, type: :system) do
    driven_by :rack_test
  end

  config.before(:each, type: :system, js: true) do
    driven_by :chrome_headless
  end
end
