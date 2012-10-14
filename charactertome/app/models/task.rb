class Task < ActiveRecord::Base
  attr_accessible :label
  belongs_to :goal

  def completed_status
    if accomplished
      :completed
    else
      :not_completed
    end
  end
end
