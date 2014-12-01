#
# Cookbook Name:: icinga2
# Recipe:: server
#
# Copyright (C) 2014 Karol@Pasternak.pro
#
# All rights reserved - Do Not Redistribute

=begin

  Install Icinga2 + Web2 on nginx
  this cookbook is about automatically configuring new nodes by searching them
  under chefs postgress database using 'search(:node, "recipe:icinga2::client")'.

=end


# Install Icinga2 repository
case node[:platform]
  when "redhat", "centos" then include_recipe "#{cookbook_name}::_yum"
  when "debian", "ubuntu" then include_recipe "#{cookbook_name}::_deb"
end

# Define package to install
packages = %w( icinga2 )

case node[:icinga2][:backend][:type]
when :mysql
  packages << "icinga2-ido-mysql"

  # Create database for cinga backend
  bend = node[:icinga2][:backend][:mysql]

  packages.each { |e| package e }

  icinga2_feature "ido-mysql"

  mariadb_user bend[:user] do
    host "localhost"
    passwd bend[:password]
    action :create
  end

  mariadb_database bend[:db] do
    owner "'#{bend[:user]}'@'localhost'"
    action :create
  end

  # Load initial sql structure
  mariadb_loadsql "/usr/share/icinga2-ido-mysql/schema/mysql.sql" do
    db bend[:db]
  end
end

# Finally, start icinga2 service
service "icinga2" do
  supports :status => true, :restart => true, :reload => true
  action  [ :enable, :start ]
end

