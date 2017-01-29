Yt.configure do |config|
  config.api_key = ENV.fetch('YOUTUBE_ACCESS_TOKEN')
  config.log_level = :debug if Rails.env.development?
end
