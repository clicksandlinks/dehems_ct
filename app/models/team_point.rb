class TeamPoint < ActiveRecord::Base
  validates_uniqueness_of :team_id, :scope => [:week]
  belongs_to :team
end
