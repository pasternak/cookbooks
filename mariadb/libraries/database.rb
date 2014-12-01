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

    def db_updated?(name)
      false
      #client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password])
      #client.query("SELECT DISTINCT 1 FROM information_schema.tables WHERE TABLE_SCHEMA='#{name}'").count == 1
    end

    def load_sql(resource)
      # Chek first if file exists
      if File.exists?(resource.name)
        #Mysql2::Client.default_query_options[:connect_flags] |= Mysql2::Client::MULTI_STATEMENTS
        #client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password], :database => resource.db, :local_infile => true)
        #client.query("SOURCE #{resource.name}")
        system("mysql -u root -p#{node[:mariadb][:server][:root_password]} #{resource.db} < #{resource.name}") rescue ''
      else
        Chef::Log::error("File #{resource.name} does not exist!")
      end
    end
  end
end
