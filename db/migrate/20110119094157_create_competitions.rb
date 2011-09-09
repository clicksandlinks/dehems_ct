class CreateCompetitions < ActiveRecord::Migration
  def self.up
    create_table :competitions do |t|
      t.column :start_date,                     :date
      t.timestamps
    end
    
    competition = Competition.new
    competition.save!
    
  end

  def self.down
    drop_table :competitions
  end
end
