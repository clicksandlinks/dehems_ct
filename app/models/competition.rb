class Competition < ActiveRecord::Base
  
  def self.has_started?
    competition = Competition.find(:first)
    if competition.start_date
      return true
    else
      return false
    end
  end
  
  def self.get_start_date
    competition = Competition.find(:first)
    return competition.start_date
  end

end
