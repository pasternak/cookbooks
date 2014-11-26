actions :create,  :delete
default_action  :create

attribute :name,  :name_attribute =>  true, 
                  :kind_of  =>  String,
                  :required =>  true

attribute :owner,  :kind_of  =>  String,
                  :default  =>  nil


attr_accessor :exists
