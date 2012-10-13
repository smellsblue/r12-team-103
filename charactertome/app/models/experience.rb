class Experience < ActiveRecord::Base
  attr_accessible :label, :value, :source_type, :reference_id
  belongs_to :tome
end
