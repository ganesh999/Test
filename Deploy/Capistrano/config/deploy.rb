# Deployment Recipe
set :application, "install"
set :repository, "git@github.com:ganesh999/Test.git"
#
set :user, "install"
#
set :scm, :git
# # Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`
#
# # We set normalize_asset_timestamps to false because we don't want the
# # railties of touching the asset directories (which don't exist in our
# # application)
set :normalize_asset_timestamps, false

#Add your shared folder here
images_to_link = ['uploads']

desc "After update_code, links the folders from the shared directory"
after "deploy:update_code" do
  images_to_link.each do |file|
    # We remove the folders that are coming from the repository
    # since we are linking them to the shared folder to preserve
    # them across deployments
    # Note: this is a non-reversible action! Be careful!
    ##run "cd #{release_path}/website ; if [ ! -h #{file} ]; then rm -rf #{release_path}/website/#{file}; fi;"
    ##run "ln -nfs #{shared_path}/website/#{file} #{release_path}/website/#{file}"
  end
    #  run "chmod -R 777 #{release_path}/web-app/application/logs"
    # run "chmod -R 777 #{release_path}/web-app/public/images/profilephotos"
end

desc "Setups the basic folder structure for a first deployment"
after "deploy:setup" do
  # Create the default shared folders
  # config/ will store our configuration files
  # system/ will store the maintenance page (for now)
  run "mkdir -p #{shared_path}/config #{shared_path}/system #{shared_path}/log"
  # Create the folder for the shared images
  images_to_link.each do |file|
    run "mkdir -p #{shared_path}/website/#{file}"
    run "chmod 777 -R #{shared_path}/website/#{file}"
  end
end


# We override the default deploy task to avoid triggering deploy:restart
namespace :deploy do
  task :default do
    update_code
    symlink
  end
  
  desc "Afer every deployment, send a notification"
  after "deploy", "differences_since_last_deploy", "deploy:notify", "deploy:cleanup"
  
  desc "Will send a notification with details on the release"
  task :notify do
    # args = ['--pretty=format:"Commit %h by %an, %ar%n%s%n"']
    # set :extra_information, capture("cd #{current_path}; #{source.command} log #{args.join(' ')} #{previous_revision}..#{current_revision}")
    show.me
    Notifier.deliver_notification_email(self)
  end

end

namespace :show do
  desc "Show some internal Cap-Fu: What's mah NAYM?!?"
  task :me do
    set :task_name, task_call_frames.first.task.fully_qualified_name
    #puts "Running #{task_name} task"
  end
end

# Default test task
task :uname do
  run "uname -a"
end

# Default test task
namespace :conditional_deploy do
  desc "Deploys only if HEAD is newer than our last deployment"
  task :default do
    if (real_revision != current_revision)
      deploy.default
    end
  end
end

desc "Show me the differences between the last deploy and the current one"
  task :differences_since_last_deploy do
    set :differences, capture("cd #{current_path}; #{source.command} diff --name-only #{previous_revision}..#{real_revision}")
    puts "#{differences}"
  end
