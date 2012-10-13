class Tome < ActiveRecord::Base
  attr_accessible :owner_id
  belongs_to :owner, :class_name => "User"

  DEFAULTS = {
    :attribute => 0,
    :name => "Anonymous",
    :profession => "Nerdist"
  }.freeze
end
