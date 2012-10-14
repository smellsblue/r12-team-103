class Task < ActiveRecord::Base
  attr_accessible :label
  belongs_to :goal
end
