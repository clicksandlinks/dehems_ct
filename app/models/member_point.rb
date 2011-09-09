class MemberPoint < ActiveRecord::Base
  validates_uniqueness_of :member_id, :scope => [:week]
  belongs_to :member
end
