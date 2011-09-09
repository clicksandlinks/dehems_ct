class CreateTeams < ActiveRecord::Migration
  def self.up
    create_table :teams do |t|
      t.column :name,                     :string
      t.column :bg_name,                  :string
      t.timestamps
    end
  end

  def self.down
    drop_table :teams
  end
end
