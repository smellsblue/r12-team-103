class AddPics < ActiveRecord::Migration
  def change
    create_table :pics do |t|
      t.integer :tome_id
      t.string :filename
      t.binary :content
      t.timestamps
    end
  end
end
