namespace :sidekiq do
  task :quiet do
    on roles(:app) do
      puts capture("pgrep -f 'workers' | xargs kill -USR1")
    end
  end
  task :restart do
    on roles(:app) do
      execute :sudo, :initctl, :restart, :workers
    end
  end
end

after 'deploy:starting', 'sidekiq:quiet'
after 'deploy:reverted', 'sidekiq:restart'
after 'deploy:published', 'sidekiq:restart'
