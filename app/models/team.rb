class Team < ActiveRecord::Base
  
   has_many :members, :dependent => :destroy, :order => 'name ASC'
   has_many :team_points, :dependent => :destroy, :order => 'week ASC'

end
