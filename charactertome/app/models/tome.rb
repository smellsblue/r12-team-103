class Tome < ActiveRecord::Base
  attr_accessible :owner_id
  belongs_to :owner, :class_name => "User"

  validates_each :intelligence, :charisma, :strength, :wisdom, :will, :confidence, :morality, :ethics do |record, attr, value|
    if value.present?
      record.errors.add attr, "can only be whole number." unless value.to_s =~ /^\d+$/
      record.errors.add attr, "must be between 0 and 100." if value < 0 || value > 100
    end
  end

  DEFAULTS = {
    :alignment => 50,
    :alignment_label => "Unknown",
    :attribute => 0,
    :name => "Anonymous",
    :profession => "Nerdist"
  }.freeze

  def value_of(attr, default_key = nil)
    result = send attr
    result = Tome::DEFAULTS[default_key || attr.to_sym] if result.blank?
    result
  end

  def update_value!(params)
    value = params[:value]
    value = nil if params[:value].blank?

    case params[:attribute]
    when "profession"
      value = self.profession = value || profession
    when "name"
      value = self.name = value || name
    when "intelligence"
      value = self.intelligence = value || intelligence
    when "charisma"
      value = self.charisma = value || charisma
    when "strength"
      value = self.strength = value || strength
    when "wisdom"
      value = self.wisdom = value || wisdom
    when "will"
      value = self.will = value || will
    when "confidence"
      value = self.confidence = value || confidence
    when "morality"
      value = self.morality = value || morality
    when "ethics"
      value = self.ethics = value || ethics
    else
      raise "Not allowed to update #{params[:attribute]}"
    end

    save!
    { :new_value => value }
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

    if ethics <= (100.0 * 1.0 / 3.0)
      "Evil"
    elsif ethics <= (100.0 * 2.0 / 3.0)
      "Neutral"
    else
      "Good"
    end
  end
end
