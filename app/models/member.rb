class Member < ActiveRecord::Base
  belongs_to :team
  has_many :daily_datas, :dependent => :destroy
  has_many :member_points, :dependent => :destroy, :order => 'week ASC'
end
