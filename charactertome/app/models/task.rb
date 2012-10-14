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

  def accomplish!
    self.accomplished = true
    self.accomplished_at = Time.now
    save!
  end

  def unaccomplish!
    self.accomplished = false
    self.accomplished_at = nil
    save!
  end
end
