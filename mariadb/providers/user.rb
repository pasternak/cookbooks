include Chef::Resource::MariaDB::User

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::MariadbUser.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.host(@new_resource.host)
  @current_resource.passwd(@new_resource.passwd)

  if user_exists?(@current_resource)
    @current_resource.exists = true
  end
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource } user in DB.") do
      create_user(@new_resource)
    end
  end
  new_resource.updated_by_last_action(true)
end

action :delete do

end
