class CreateGoals < ActiveRecord::Migration
  class MigrationExperiences < ActiveRecord::Base
    self.table_name = "experiences"
  end

  def up
    # Whoops.. forgot this
    change_table :experiences do |t|
      t.timestamps
    end

    MigrationExperiences.update_all :created_at => Time.now, :updated_at => Time.now

    create_table :goals do |t|
      t.integer :tome_id, :null => false
      t.string :label, :null => false
      t.timestamps
    end
  end

  def down
    change_table :experiences do |t|
      t.remove :created_at
      t.remove :updated_at
    end

    drop_table :goals
  end
end
