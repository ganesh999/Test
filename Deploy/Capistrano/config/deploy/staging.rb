set :deploy_to, "$HOME/staging"

role :app, "APP_DOMAIN eg:wwws.example.com"
#role :db, "fms.xminds.com", :primary => true

# Email notifications
#set :notify_emails, ["admin@xminds.com", "abcd@xminds.com" ]
set :notify_emails, ["admin@xminds.com" ]

Notifier.configure do |config|
  config[:recipient_addresses] = notify_emails
  config[:subject_prepend] = "[DEPLOY]"
  config[:site_name] = "APP_DOMAIN eg:wwws.example.com"
  config[:email_content_type] = "text/html" # OR "text/plain" if you want the plain text version of the email
  config[:sections] = %w(deployment release_data source_control latest_release previous_release)
end
