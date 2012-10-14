class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.integer :goal_id, :null => false
      t.string :label, :null => false
      t.boolean :accomplished, :null => false, :default => false
      t.timestamp :accomplished_at
      t.timestamps
    end
  end
end
