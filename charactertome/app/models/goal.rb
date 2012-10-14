class Goal < ActiveRecord::Base
  attr_accessible :label
  belongs_to :tome

  def accomplished_percent
    42
  end
end
