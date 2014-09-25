require 'omniauth-openid'
require 'openid/store/filesystem'

Rails.application.config.middleware.use OmniAuth::Builder do
	provider :developer unless Rails.env.production?
    provider :twitter, ENV['TWITTER_KEY'], ENV['TWITTER_SECRET']
    provider :facebook, '1493228840925351', '20110da7b051d5e4b188a0bbc021ed2f'
    provider :linkedin, ENV['LINKEDIN_KEY'], ENV['LINKEDIN_SECRET']
    provider :open_id, :store => OpenID::Store::Filesystem.new('/tmp')
    # Mention other providers here you want to allow user to sign in with
end
