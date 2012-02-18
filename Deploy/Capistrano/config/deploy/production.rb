set :deploy_to, "$HOME/production"

role :app, "localhost"
#role :db, "www.dashluxe.com", :primary => true

# Email notifications
set :notify_emails, ["ganesh.gk@xminds.in" ]

Notifier.configure do |config|
  config[:recipient_addresses] = notify_emails
  config[:subject_prepend] = "[DEPLOY]"
  config[:site_name] = "APP_DOMAIN eg: www.exapmple.com"
  config[:email_content_type] = "text/html" # OR "text/plain" if you want the plain text version of the email
  config[:sections] = %w(deployment release_data source_control latest_release previous_release)
end
