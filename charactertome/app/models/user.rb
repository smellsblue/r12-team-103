class User < ActiveRecord::Base
  has_one :tome, :foreign_key => :owner_id
end
