class Tome < ActiveRecord::Base
  attr_accessible :owner_id
  belongs_to :owner, :class_name => "User"
end
