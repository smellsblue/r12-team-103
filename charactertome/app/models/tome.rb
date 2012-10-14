require "set"

class Tome < ActiveRecord::Base
  attr_accessible :owner, :owner_id
  belongs_to :owner, :class_name => "User"
  has_many :experiences
  has_many :goals
  has_many :weapons
  has_one :pic
  before_save :check_for_new_xp_and_levels

  validates_each :intelligence, :charisma, :strength, :wisdom, :will, :confidence, :morality, :ethics do |record, attr, value|
    if value.present?
      record.errors.add attr, "can only be whole number." unless value.to_s =~ /^\d+$/
      record.errors.add attr, "must be between 0 and 100." if value < 0 || value > 100
    end
  end

  MAX_DEFAULT_CHARACTER_IMAGE = 5

  DEFAULTS = {
    :alignment => 50,
    :alignment_label => "Unknown",
    :attribute => 0,
    :name => "Anonymous",
    :profession => "Nerdist"
  }.freeze

  def image
    if default_pic == -1 && pic && pic.content
      "/tomes/#{id}/pic.png"
    elsif default_pic && (1..MAX_DEFAULT_CHARACTER_IMAGE).include?(default_pic)
      "character#{default_pic}.png"
    else
      "character#{(id % MAX_DEFAULT_CHARACTER_IMAGE) + 1}.png"
    end
  end

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
    additional = {}

    if params[:attribute].present?
      case params[:attribute]
      when "profession"
        value = self.profession = value || profession
      when "name"
        value = self.name = value || name
      when "default_pic"
        self.default_pic = value.to_i

        if pic
          pic.filename = nil
          pic.content = nil
          pic.save!
        end
      when "upload_pic"
        file = params[:pic]
        original_filename = file.original_filename
        extension = File.extname original_filename
        filename = File.basename original_filename
        filename = nil if filename.blank?
        extension = extension[/^\.?(.*?)$/, 1].downcase if extension
        extension = nil if extension.blank?
        raise "Only PNG is accepted!" unless extension == "png"

        if pic
          pic.filename = filename
          pic.content = file.read
          pic.save!
        else
          Pic.create :tome => self, :filename => filename, :content => file.read
        end

        self.default_pic = -1
      else
        raise "Not allowed to update #{params[:attribute]}"
      end
    elsif params[:bar_attribute].present?
      case params[:adjustment]
      when "decrease"
        value = -1
      when "fast_decrease"
        value = -10
      when "increase"
        value = 1
      when "fast_increase"
        value = 10
      else
        raise "Adjust that by what?"
      end

      case params[:bar_attribute]
      when "intelligence"
        value = self.intelligence = fix_bar_value((intelligence || 0) + value)
      when "charisma"
        value = self.charisma = fix_bar_value((charisma || 0) + value)
      when "strength"
        value = self.strength = fix_bar_value((strength || 0) + value)
      when "wisdom"
        value = self.wisdom = fix_bar_value((wisdom || 0) + value)
      when "will"
        value = self.will = fix_bar_value((will || 0) + value)
      when "confidence"
        value = self.confidence = fix_bar_value((confidence || 0) + value)
      when "morality"
        value = self.morality = fix_bar_value((morality || 50) + value)
        additional = { :new_morality => value_of("morality_label", :alignment_label) }
      when "ethics"
        value = self.ethics = fix_bar_value((ethics || 50) + value)
        additional = { :new_ethics => value_of("ethics_label", :alignment_label) }
      else
        raise "Not allowed to update #{params[:bar_attribute]}"
      end
    else
      raise "What are you trying to update?"
    end

    save!
    xp_gained = 0

    each_xp_gain :include_recent => true do |attr, xp, source, ref_id|
      xp_gained += xp
    end

    result = { :new_value => value, :xp_gained => xp_gained, :new_xp_total => xp_total, :levels_gained => levels_gained, :new_level => level, :new_level_label => level.ordinalize }.merge(additional)
  end

  def create_weapon!(params)
    weapon = weapons.create :label => params[:label]
    { :weapon => weapon }
  end

  def update_weapon!(weapon, params)
    if params[:attribute] == "label"
      weapon.label = params[:value]
      weapon.save!
      return { :new_value => weapon.label }
    elsif params[:increase] == "true"
      return {} if weapon.value >= 5
      weapon.value += 1
      weapon.save!
      return { :new_weapon_bonus => "+#{weapon.value}" }
    elsif params[:decrease] == "true"
      return {} if weapon.value <= 0
      weapon.value -= 1
      weapon.save!
      return { :new_weapon_bonus => "+#{weapon.value}" }
    else
      raise "What are you trying to update?"
    end

    {}
  end

  def create_goal!(params)
    goal = goals.create :label => params[:label]
    { :goal => goal }
  end

  def update_goal!(goal, params)
    if params[:attribute] == "label"
      goal.label = params[:value]
      goal.save!
      return { :new_value => goal.label }
    else
      raise "What are you trying to update?"
    end

    {}
  end

  def create_task!(goal, params)
    task = goal.tasks.create :label => params[:label]
    { :task => task }
  end

  def update_task!(task, params)
    if params[:toggle] == "true"
      if task.accomplished
        task.unaccomplish!
      else
        task.accomplish!
        gain_for_this_task = gain_referenced_unique_xp? "You completed a task.", 25, "task", task.id
        gain_for_this_goal = gain_referenced_unique_xp? "You completed a goal.", 100, "goal", task.goal_id if task.goal.accomplished?

        if gain_for_this_task || gain_for_this_goal
          check_levels!
          save! if level_changed?
          amount = 0
          amount += 25 if gain_for_this_task
          amount += 100 if gain_for_this_goal
          return { :xp_gained => amount, :new_xp_total => xp_total, :levels_gained => levels_gained, :new_level => level, :new_level_label => level.ordinalize }
        end
      end
    elsif params[:attribute] == "label"
      task.label = params[:value]
      task.save!
      return { :new_value => task.label }
    else
      raise "What are you trying to update?"
    end

    {}
  end

  def levels_gained
    level_change = previous_changes["level"]

    if level_change
      level_change[1] - level_change[0]
    else
      0
    end
  end

  def gain_referenced_unique_xp?(label, value, source_type, ref_id)
    return false if experiences.where(:reference_id => ref_id, :source_type => source_type).count > 0
    experiences.create :label => label, :value => value, :source_type => source_type, :reference_id => ref_id
    true
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
  def fix_bar_value(value)
    if value < 0
      0
    elsif value > 100
      100
    else
      value
    end
  end

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
