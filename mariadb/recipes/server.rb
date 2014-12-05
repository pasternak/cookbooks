#
# Cookbook Name:: mariadb
# Recipe:: server
#
# Copyright (C) 2014 Karol Pasternak
#
# All rights reserved - Do Not Redistribute
#

# Build reposiroty and install packages
case node[:platform]
when "redhat", "centos" then include_recipe "#{cookbook_name}::_yum"
when "debian", "ubuntu" then include_recipe "#{cookbook_name}::_deb"
end

# Required for MariaDB LWRP
# Include this recipe in every cookbook you want to use this resources
#
%w(gcc make ruby-devel MariaDB-devel MariaDB-compat).each do |pkg|
  package pkg do
    action  :nothing
  end.run_action :install
end

chef_gem "mysql2" do
  action  :nothing
end.run_action(:install)

# Install server package
package "MariaDB-server" do
  action :install
end

# Start server [mysql if installed from mariadb repo/mariadb if from centos/rhel]
service "mysql" do
  action  :start
end

# Process mysql_secure_installation
ruby_block "mysql_secure_installation" do
  block do
    require 'mysql2'

    # Make connection to MariaDB server instance
    begin
      client = node[:mariadb][:server][:root_password].nil? \
        ? Mysql2::Client.new(:host => "localhost", :username => "root") \
        : Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password])
    rescue
      client = Mysql2::Client.new(:host => "localhost", :username => "root")
    end
    client.query("DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1')") if node[:mariadb][:server][:remove][:remote_root]
    client.query("DROP DATABASE IF EXISTS test") if node[:mariadb][:server][:remove][:test_db]
    client.query("DELETE FROM mysql.user WHERE User=''") if node[:mariadb][:server][:remove][:anon_users]
    client.query("FLUSH PRIVILEGES")
  end
  action :run
end

ruby_block "setting root password" do
  block do
    begin 
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password])
    rescue 
      client = Mysql2::Client.new(:host => "localhost", :username => "root") 
    end
    node.set[:mariadb][:server][:root_password] = rand(36**20).to_s(36) if node[:mariadb][:server][:root_password].nil?
    node.save
    client.query("set password for 'root'@'localhost' = PASSWORD('#{node[:mariadb][:server][:root_password]}')")
    client.query("FLUSH PRIVILEGES")
  end
  action :run
end

#mariadb_user "test-user" do
#  passwd "test"
#  action :create
#end

#mariadb_database "oko" do
#  action :create
#end

#mariadb_database "nos" do
#  owner "'test-user'@'localhost'"
#  action :create
#end
