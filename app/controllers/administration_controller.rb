class AdministrationController < ApplicationController
  
   before_filter :admin_required
   
   layout "admin"
   
   def delete_data
     DailyData.delete_all
     MemberPoint.delete_all
     TeamPoint.delete_all
     competition = Competition.find(:first)
     competition.start_date = nil
     competition.save
     redirect_to :action => "index"
   end
   
   def view_member_data
     @dailyData = DailyData.find(:all, :conditions => "member_id = #{params[:id]}", :order => "sample_time DESC")
   end
   
   def save_competition
     competition = Competition.find(:first)
     newStartDate = params[:competition][:start_date]
     if newStartDate == ""
       competition.start_date = nil
     else
       competition.start_date = Date::strptime(newStartDate, '%Y-%m-%d')
     end
     competition.save
     
     redirect_to :action => "index"
   end
   
   def index
     @teams = Team.find(:all)
     @competition = Competition.find(:first)
   end
 
   def add_team
      return unless request.post?
      team = Team.new(params[:team])
      team.save
      redirect_to :action => "index"
    end
  
    def remove_team
      team = Team.find(:first, :conditions => "id = #{params[:id]}")
      team.destroy
      redirect_to :action => "index"
    end
    
    def edit_team
      @id = params[:id]
      @team = Team.find(:first, :conditions => "id = #{@id}")
      return unless request.post?
      @team.update_attributes(params[:team])
      redirect_to :action => "index"
    end
  
    def view_team
      @team_id = params[:id]
      @members = Member.find(:all, :conditions => "team_id = #{@team_id}")
    end
  
    def add_member
      @team_id = params[:team_id]
      return unless request.post?
      member = Member.new(params[:member])
      member.save
      @team_id = member.team_id
      redirect_to :action => "view_team", :id => @team_id
    end
  
    def remove_member
      @team_id = params[:team_id]
      member = Member.find(:first, :conditions => "id = #{params[:id]}")
      member.destroy
      redirect_to :action => "view_team", :id => @team_id
    end
end
