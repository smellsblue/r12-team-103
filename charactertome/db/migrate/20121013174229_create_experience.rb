class CreateExperience < ActiveRecord::Migration
  def change
    create_table :experiences do |t|
      t.integer :tome_id, :null => false
      t.string :label, :null => false
      t.integer :value, :null => false
      t.string :source_type, :null => false
      t.integer :reference_id
    end
  end
end
