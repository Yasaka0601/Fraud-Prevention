# JS を使った system spec で使う remote_chrome ドライバの定義
Capybara.register_driver :remote_chrome do |app|
  options = Selenium::WebDriver::Chrome::Options.new
  options.add_argument('no-sandbox')
  options.add_argument('headless')
  options.add_argument('disable-gpu')
  options.add_argument('window-size=1680,1050')

  Capybara::Selenium::Driver.new(
    app,
    browser: :remote,
    # 将来 SELENIUM_DRIVER_URL を docker compose に設定したときにここで拾う
    url: ENV.fetch('SELENIUM_DRIVER_URL', 'http://chrome:4444/wd/hub'),
    capabilities: options
  )
end

Capybara.default_max_wait_time = 5
Capybara.javascript_driver = :remote_chrome