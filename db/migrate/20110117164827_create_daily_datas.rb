class CreateDailyDatas < ActiveRecord::Migration
  def self.up
    create_table :daily_datas do |t|
      t.column :member_id,                     :integer
      t.column :total_kwh,                     :float
      t.column :sample_time,                     :date
      t.timestamps
    end
  end

  def self.down
    drop_table :daily_datas
  end
end
