class AddDefaultPic < ActiveRecord::Migration
  def change
    change_table :tomes do |t|
      t.integer :default_pic
    end
  end
end
