class CreateTeamPoints < ActiveRecord::Migration
  def self.up
    create_table :team_points do |t|
       t.column :team_id,                     :integer
      t.column :week,                     :integer
      t.column :points,                     :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :team_points
  end
end
