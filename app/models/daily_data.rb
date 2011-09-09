class DailyData < ActiveRecord::Base
  validates_uniqueness_of :member_id, :scope => [:sample_time]
  belongs_to :member
end
