include Chef::Resource::MariaDB::Database

def whyrun_supported?
  true
end

def load_current_resource
  @current_resource = Chef::Resource::MariadbLoadsql.new(@new_resource.name)
  @current_resource.name(@new_resource.name)
  @current_resource.db(@new_resource.db)

  if db_updated?(@current_resource.db)
    @current_resource.exists = true
  end
end

action :create do
  if @current_resource.exists
    Chef::Log.info "#{ @new_resource } already exists - nothing to do."
  else
    converge_by("Loading #{ @new_resource } into database.") do
      load_sql(@new_resource)
    end
  end
  new_resource.updated_by_last_action(true)
end

action :delete do

end
