class Goal < ActiveRecord::Base
  attr_accessible :label
  belongs_to :tome
  has_many :tasks

  def accomplished_percent
    if tasks.empty?
      0
    else
      42
    end
  end
end
