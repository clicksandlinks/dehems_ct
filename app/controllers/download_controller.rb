class DownloadController < ApplicationController
  
  require 'net/http'
  require 'json'
  require 'digest/sha2'
  
  layout nil
  
  #Download the data from DEHEMS API
  def index
    
    @message = "success"
    
    if Competition.has_started?
      
      time_now =  Time.new
      
      #time_now = Time.parse("2011-02-14 00:01:00")
      
      #Download the weekly data and calculate points at the end of 7 day period.
      date_now = Date.parse(time_now.strftime('%Y/%m/%d'))
      competition_days = (date_now - Competition.get_start_date);
      week = competition_days/7 
      pointDataTest = MemberPoint.find(:first, :order => "week DESC")
      pointDataTestFlag = (pointDataTest == nil or (time_now.day != pointDataTest.created_at.day and time_now > pointDataTest.created_at))
      if competition_days % 7 == 0 and pointDataTestFlag and week < 13
        
        #Get all users.
        members = Member.find(:all)
        
        #Download data daily data for each user from yesterday if not yet downloaded.
        for member in members
          timestamp = Time.new.to_i
          
          #Download the stream id if not done yet.
          if member.stream_id == nil or member.stream_id == ""
            hashCode = generateHashCode(timestamp,member.mac)  
            params = {
              :ap => DEHEMS::API_ID,
              :ts => timestamp,
              :householdId => member.mac,
              :dataStreamType => "AggregateElectricity",
              :hashCode => hashCode
            }
            res = Net::HTTP.post_form(URI.parse("#{DEHEMS::API_SERVER_ADDRESS}getDataStreamListJSON"),params)
            result = JSON.parse(res.body)
            member.stream_id = result["DataStreamList"][0]["StreamId"]
            member.save
          end
          
          #Download the data for the last 7 days.
          hashCode = generateHashCode(timestamp,member.stream_id)  
          params = {
            :ap => DEHEMS::API_ID,
            :ts => timestamp,
            :streamId => member.stream_id,
            :resolution => "Day",
            :numberOfPoints => "7",
            :cum => "true",
            :endTime => time_now.to_i,
            :includeCurrentPeriod => "false",
            :hashCode => hashCode
          }
          
          res = Net::HTTP.post_form(URI.parse("#{DEHEMS::API_SERVER_ADDRESS}getDataStreamJSON"),params)
          result = JSON.parse(res.body)
          saving_day = 7
          for kwhs in result["DataStream"] 
             data = DailyData.new
             data.member_id = member.id
             data.total_kwh = kwhs.to_f
             data.sample_time = (time_now - saving_day.day)
             begin
              data.save
             end
             saving_day-=1
          end
              
        end
        
        #Calculate and save points.
        teams = Team.find(:all)
        team_totals = {}
        for team in teams
          member_totals = {}
          members = Member.find(:all, :conditions => "team_id=#{team.id}") 
          for member in members
            #Check that we have no zero readings the last 7 days.
            zeroReading = DailyData.find(:all, :conditions => "member_id=#{member.id} and total_kwh<0.1 and sample_time<='#{(date_now - 1.day)}' and sample_time>='#{(date_now - 7.day)}'", :order => "sample_time DESC")
            if zeroReading and zeroReading.size > 3
              point = MemberPoint.new
              point.week = week
              point.member_id = member.id
              point.points = 0
              begin
                point.save
              end
            else
              #Calculate total usage and save in the hash for week 1 and saving after that.
              if week == 1
                weekly_average = DailyData.average("total_kwh", :conditions => "member_id=#{member.id} and total_kwh>0.1 and sample_time<='#{(date_now - 1.day)}' and sample_time>='#{(date_now - 7.day)}'")
                member_totals[member.id] = weekly_average.to_f
              else
                preZeroReading = DailyData.find(:all, :conditions => "member_id=#{member.id} and total_kwh<0.1 and sample_time<='#{(date_now - 8.day)}' and sample_time>='#{(date_now - 15.day)}'", :order => "sample_time DESC")
                if preZeroReading and preZeroReading.size > 3
                  point = MemberPoint.new
                  point.week = week
                  point.member_id = member.id
                  point.points = 0
                  begin
                    point.save
                  end
                else
                  weekly_average = DailyData.average("total_kwh", :conditions => "member_id=#{member.id} and total_kwh>0.1 and sample_time<='#{(date_now - 1.day)}' and sample_time>='#{(date_now - 7.day)}'")           
                  previous_weekly_average = DailyData.average("total_kwh", :conditions => "member_id=#{member.id} and total_kwh>0.1 and sample_time<='#{(date_now - 8.day)}' and sample_time>='#{(date_now - 15.day)}'")  
                  difference = previous_weekly_average.to_f-weekly_average.to_f
                  if difference == 0 and previous_weekly_average.to_f-weekly_average.to_f == 0
                    member_totals[member.id] = 0
                  else
                    member_totals[member.id] = difference/previous_weekly_average.to_f
                  end
                end
              end
            end
          end
          
          member_totals_sorted = member_totals.sort {|a,b| a[1]<=>b[1]}
          if week > 1
            member_totals_sorted = member_totals_sorted.reverse
          end
          member_count = 0
          team_total = 0
          points = CT::POINT_POOL_SIZE
          for value in member_totals_sorted
             #Write here the functionality to save the member points.
             point = MemberPoint.new
             point.week = week
             point.member_id = value[0]
             point.points = points
             begin
              point.save
             end
             points-=1
           
             #Add to the team total.
             member_count+=1
             team_total+=value[1]
          end
       
          #Calculate the team average and add into the hash.
          if member_count > 0
            team_totals[team.id] = team_total/member_count
          else
            team_totals[team.id] = 100000
          end
        
        end
       
        #Do not save team points from week 1 since there is not yet a comparison week data.
        if week > 1
          team_totals_sorted = team_totals.sort {|a,b| a[1]<=>b[1]}
          team_totals_sorted = team_totals_sorted.reverse
          points = CT::TEAM_POINT_POOL_SIZE
          for value in team_totals_sorted
             point = TeamPoint.new
             point.week = week
             point.team_id = value[0]
             point.points = points
             begin
              point.save
             end
             points-=1
          end
        end
      end 
    end
  end
  
end