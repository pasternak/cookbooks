include Chef::Resource::MariaDB::Database

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::MariadbDatabase.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.owner(@new_resource.owner)

  if db_exists?(@current_resource.name)
    @current_resource.exists = true
  end
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Create #{ @new_resource } database.") do
      create_db(@new_resource)
    end
  end
  new_resource.updated_by_last_action(true)
end

action :delete do

end
