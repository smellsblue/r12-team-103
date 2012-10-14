class Goal < ActiveRecord::Base
  attr_accessible :label
  belongs_to :tome
  has_many :tasks

  def accomplished?
    accomplished_percent == 100
  end

  def accomplished_percent
    task_count = tasks.count

    if task_count.zero?
      0
    else
      (100 * tasks.where(:accomplished => true).count / task_count).to_i
    end
  end
end
