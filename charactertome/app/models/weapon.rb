class Weapon < ActiveRecord::Base
  attr_accessible :label
  belongs_to :tome
end
