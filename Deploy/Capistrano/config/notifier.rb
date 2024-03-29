ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.raise_delivery_errors = false
ActionMailer::Base.default_charset = "utf-8"
ActionMailer::Base.smtp_settings = {
  :address  => "localhost",
  :port     => 25,
  :domain   => "APP_NAME",
#  :user_name => "projects@xminds.com",
#  :password => "UJrAqTW3kqyZF2",
#  :authentication => :login
 }

class Notifier < ActionMailer::Base

  @@default_base_config ||= {
    :sender_address           => "projects@xminds.com",
    :recipient_addresses      => [],
    # Customize the subject line
    :subject_prepend          => "[DEPLOYMENT] ",
    :subject_append           => nil,
    # Include which sections of the deployment email?
    :sections                 => %w(deployment release_data source_control latest_release previous_release other_deployment_info extra_information),
    :site_name                => "",
    :email_content_type       => "text/html",
    :template_root            => "#{File.dirname(__FILE__)}/../views",
  }

  cattr_accessor :default_base_config
  attr_accessor  :config, :options
  attr_accessor  :date, :time, :inferred_command, :task_name, :repo_end
  
  def self.configure(&block)
    yield @@default_base_config
  end

  self.template_root = default_base_config[:template_root]

  def self.reloadable?() false end


  def notification_email(cap, config = {}, *args)
    @options = { :release_data => {}, :extra_information => {}, :data => {} }.merge(args.extract_options!)
    @config  = default_base_config.merge(config.reverse_merge({
        #:host               => cap.host,
        :task_name          => cap.task_name,
        :application        => cap.application,
        :repository         => cap.repository,
        :scm                => cap.scm,
        :deploy_via         => cap.deploy_via,
        :deploy_to          => cap.deploy_to,
        :revision           => cap.revision,
        :real_revision      => cap.real_revision,
        :release_name       => cap.release_name,
        :version_dir        => cap.version_dir,
        :shared_dir         => cap.shared_dir,
        :current_dir        => cap.current_dir,
        :releases_path      => cap.releases_path,
        :shared_path        => cap.shared_path,
        :current_path       => cap.current_path,
        :release_path       => cap.release_path,
        :releases           => cap.releases,
        :current_release    => cap.current_release,
        :previous_release   => cap.previous_release,
        :current_revision   => cap.current_revision,
        :latest_revision    => cap.latest_revision,
        :previous_revision  => cap.previous_revision,
        :run_method         => cap.run_method,
        :latest_release     => cap.latest_release,
        :differences        => cap.differences
  
        #This does not appear to be a capistrano variable:
        #:site_url           => cap.site_url
    }))
    
    @date             = Date.today.to_s
    @time             = Time.now.strftime("%I:%M %p").to_s
    @inferred_command = "cap #{@config[:task_name]}"
    @task_name        = @config[:task_name] || "unknown"
        
    subject       subject_line
    recipients    @config[:recipient_addresses]
#    from          @config[:sender_address]
    from          'projects@xminds.com'
    content_type  @config[:email_content_type]
    
    body          body_data_hash
  end
  private
  
    def subject_line
      #The subject prepend and append are useful for people to setup filters in mail clients.
      user = config[:user] ? " by #{config[:user]}" : ""
      middle = config[:subject] ? config[:subject] : " #{config[:site_name]}"
      "#{config[:subject_prepend]}#{middle}#{config[:subject_append]}"
    end

    def body_data_hash
      options[:data].merge({
        :section_data     => section_data_hash,
        :date             => date,
        :time             => time,
        :task_name        => task_name,
        :inferred_command => inferred_command,
        :site_name        => config[:site_name],
        :site_url         => config[:site_url],
        :application      => config[:application],
        :sections         => config[:sections]
      })
    end

    def section_data_hash
      {
        :deployment             => section_hash_deployment,
        :source_control         => section_hash_source_control,
        :latest_release         => section_hash_latest_release,
        :previous_release       => section_hash_previous_release,
        :other_deployment_info  => section_hash_other_deployment_info,
        :release_data           => options[:release_data],
        :extra_information      => options[:extra_information]
      }
    end

    def section_hash_deployment
      {
        :date             => date,
        :time             => time,
        :rails_env        => config[:rails_env],
        :task_name        => task_name,
        :inferred_command => inferred_command,
        :host             => config[:host],
        :release_name     => config[:release_name],
        :differences      => config[:differences]
      }
    end

    def section_hash_source_control
      {
        :revision         => config[:revision],
        :released         => repo_end,
        :repository       => config[:repository],
        :branch           => config[:branch],
        :scm              => config[:scm],
        :deploy_via       => config[:deploy_via],
        :deploy_to        => config[:deploy_to]
      }
    end

    def section_hash_latest_release
      {
        :latest_release   => config[:latest_release],
        :latest_revision  => config[:latest_revision],
        :release_path     => config[:release_path],
        :real_revision    => config[:real_revision],
        :current_path     => config[:current_path],
      }
    end

    def section_hash_previous_release
      {
        :current_release    => config[:current_release],
        :current_revision   => config[:current_revision],
        :previous_release   => config[:previous_release],
        :previous_revision  => config[:previous_revision],
        :releases           => config[:releases]
      }
    end

    def section_hash_other_deployment_info
      {
        :version_dir    => config[:version_dir],
        :shared_dir     => config[:shared_dir],
        :current_dir    => config[:current_dir],
        :releases_path  => config[:releases_path],
        :shared_path    => config[:shared_path],
        :run_method     => config[:run_method],
        :ip_address     => config[:ip_address]
      }
    end

end
