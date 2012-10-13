class CreateTomes < ActiveRecord::Migration
  def change
    create_table :tomes do |t|
      t.integer :owner_id, :null => false
      t.integer :level, :default => 1, :null => false
      t.string :profession
      t.string :name
      t.string :real_name
      t.integer :intelligence
      t.integer :charisma
      t.integer :strength
      t.integer :wisdom
      t.integer :will
      t.integer :confidence
      t.integer :morality
      t.integer :ethics
      t.boolean :publicly_available, :default => true, :null => false
      t.timestamps
    end
  end
end
