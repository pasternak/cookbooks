module MariaDB
  module Database

    def create_db(resource)
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password])
      client.query("create database #{resource.name}") 
      client.query("GRANT all privileges on #{resource.name}.* to #{resource.owner}") if !resource.owner.nil?
      client.query("FLUSH PRIVILEGES")
    end

    def db_exists?(name)
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password])
      client.query("SELECT 1 FROM INFORMATION_SCHEMA.SCHEMATA WHERE SCHEMA_NAME = '#{name}'").count == 1
    end
  end
end
