nginxtra.simple_config :run_as => "www-data" do
  @config.require_root!
  rails :server_name => "charactertome.r12.railsrumble.com", :root => "/home/charactertome/r12-team-103/charactertome"
end
