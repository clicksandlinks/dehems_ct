class SiteController < ApplicationController
  
  def index
     @title = t(:views__site__index__home)
     if Competition.has_started?
       @teams = Team.find(:all, :order => 'name ASC')
       start_date = Competition.get_start_date
       @start_date = start_date.strftime("%d/%m/%Y")
       @end_date = (start_date + 12.week).strftime("%d/%m/%Y")
       @week = 12 - ((start_date + 12.week) - Date.parse(Time.now.strftime('%Y/%m/%d'))).to_i/7
     end
  end
 
  def view_team
    @title = t(:views__site__index__home)
    @team = Team.find(:first, :conditions => "id=#{params[:id]}")
    start_date = Competition.get_start_date
    @week = 12 - ((start_date + 12.week) - Date.parse(Time.now.strftime('%Y/%m/%d'))).to_i/7
  end
  
  def show_history
    @teams = Team.find(:all, :order => 'name ASC')
    render :layout => "popup"
  end
  
  def show_team_history
    @team = Team.find(:first, :conditions => "id=#{params[:id]}")
    render :layout => "popup"
  end
  
end
