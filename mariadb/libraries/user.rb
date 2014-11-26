module MariaDB
  module User

    def create_user(resource)
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password])
      resource.host.nil? ? client.query("create user #{resource.name} identified by '#{resource.passwd}'") 
                         : client.query("create user '#{resource.name}'@'#{resource.host}' identified by '#{resource.passwd}'")
    end

    def user_exists?(resource)
      client = Mysql2::Client.new(:host => "localhost", :username => "root", :password => node[:mariadb][:server][:root_password])
      resource.host.nil? ? client.query("SELECT distinct 1 FROM mysql.user WHERE user = '#{resource.name}'").count == 1
                         : client.query("SELECT distinct 1 FROM mysql.user WHERE user = '#{resource.name}' and host = '#{resource.host}'").count == 1 
    end
  end
end
