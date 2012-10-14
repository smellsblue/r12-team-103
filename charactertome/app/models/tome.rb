require "set"

class Tome < ActiveRecord::Base
  attr_accessible :owner, :owner_id
  belongs_to :owner, :class_name => "User"
  has_many :experiences
  has_many :goals
  before_save :check_for_new_xp_and_levels

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

  def xp_total
    experiences.sum &:value
  end

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
    xp_gained = 0

    each_xp_gain :include_recent => true do |attr, xp, source, ref_id|
      xp_gained += xp
    end

    level_change = previous_changes["level"]

    if level_change
      levels_gained = level_change[1] - level_change[0]
    else
      levels_gained = 0
    end

    result = { :new_value => value, :xp_gained => xp_gained, :new_xp_total => xp_total, :levels_gained => levels_gained, :new_level => level, :new_level_label => level.ordinalize }
  end

  def create_goal!(params)
    goal = goals.create :label => params[:label]
    { :goal => goal }
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

  private
  def check_for_new_xp_and_levels
    check_xp! unless new_record?
    check_levels!
  end

  def check_xp!
    each_xp_gain do |attr, xp, source, ref_id|
      experiences.create :label => "You defined your #{attr}.", :value => xp, :source_type => source, :reference_id => ref_id
    end
  end

  def check_levels!
    current_xp_total = xp_total
    current_level = level

    until current_xp_total < Tome.xp_cutoff(current_level + 1)
      current_level += 1
    end

    self.level = current_level
  end

  def each_xp_gain(options = {})
    check = changes
    check = previous_changes if check.empty?

    check.each do |attr, values|
      if values[0].blank? && values[1].present? && [:name, :profession, :intelligence, :charisma, :strength, :wisdom, :will, :confidence, :morality, :ethics].include?(attr.to_sym)
        source = attr.to_s

        if experiences.exists?(:source_type => source)
          next unless @recent_gains && @recent_gains.include?(attr.to_sym) && options[:include_recent]
        end

        @recent_gains ||= Set.new
        @recent_gains << attr.to_sym
        yield attr, 25, source, nil
      end
    end
  end

  class << self
    def xp_cutoff(level)
      (2..level).inject 0 do |result, l|
        result + (l - 1) * 100
      end
    end
  end
end
