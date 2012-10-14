class CreateWeapons < ActiveRecord::Migration
  def change
    create_table :weapons do |t|
      t.integer :tome_id, :null => false
      t.string :label, :null => false
      t.integer :value, :null => false, :default => 1
      t.timestamps
    end
  end
end
