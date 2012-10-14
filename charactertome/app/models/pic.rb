class Pic < ActiveRecord::Base
  attr_accessible :tome, :tome_id, :filename, :content
  belongs_to :tome
end
