class CreateMemberPoints < ActiveRecord::Migration
  def self.up
    create_table :member_points do |t|
      t.column :member_id,                     :integer
      t.column :week,                     :integer
      t.column :points,                     :integer
      t.timestamps
    end
  end

  def self.down
    drop_table :member_points
  end
end
