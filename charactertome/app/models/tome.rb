class Tome < ActiveRecord::Base
  attr_accessible :owner_id
  belongs_to :owner, :class_name => "User"

  DEFAULTS = {
    :alignment => 50,
    :alignment_label => "Unknown",
    :attribute => 0,
    :name => "Anonymous",
    :profession => "Nerdist"
  }.freeze

  def update_value(params)
  end

  def morality_label
    return nil unless morality

    if morality <= (100.0 * 1.0 / 3.0)
      "Chaotic"
    elsif morality <= (100.0 * 2.0 / 3.0)
      "Neutral"
    else
      "Lawful"
    end
  end

  def ethics_label
    return nil unless ethics

    if morality <= (100.0 * 1.0 / 3.0)
      "Evil"
    elsif morality <= (100.0 * 2.0 / 3.0)
      "Neutral"
    else
      "Good"
    end
  end
end
