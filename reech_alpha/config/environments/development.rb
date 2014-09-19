Reech::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  config.action_mailer.raise_delivery_errors = false

  #config.action_mailer.perform_deliveries = true
  config.action_mailer.perform_deliveries = false
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default :charset => "utf-8"

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  #config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  #config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Do not compress assets
  config.assets.compress = false

  # Expands the lines which load the assets
  config.assets.debug = true

  #required by devise. Set host to correct host in production mode

  config.middleware.insert_before "ActionDispatch::Static", "Rack::Cors" do
    allow do
      origins '*'
      resource '*', :headers => :any, :methods => [:get, :post, :options]
    end
  end

  config.action_mailer.default_url_options = { :host => 'ec2-54-201-116-44.us-west-2.compute.amazonaws.com:3000' }
  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
  address:              'smtp.gmail.com',
  port:                 587,
  domain:               'gmail.com',
  user_name:            'hello@reechout.co',
  password:             'Superhelper1!',
  authentication:       'login',
  enable_starttls_auto: true  }

 #  config.paperclip_defaults = {
 #  :storage => :s3,
 #  :s3_credentials => {
 #    :bucket => 'reechattachmentstorage',
 #    :access_key_id => 'AKIAIVK7XM7Q7YX72IDQ',
 #    :secret_access_key => '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'
    
 #  },
 #  :s3_multipart_min_part_size => 20971520
 # }
 Paperclip.options[:command_path] = "/usr/local/bin/convert"
end
