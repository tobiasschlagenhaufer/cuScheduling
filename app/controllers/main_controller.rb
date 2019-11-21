class MainController < ApplicationController
	attr_accessor :scheduleNum, :sceduleCount, :winScroll

	def index
		require "./app/genSchedule.rb"

		@default_classes = {"class1" => "", "class2" => "","class3" => "","class4" => "", "class5" => "","class6" => ""}
		@last_classes = ""
		@last_term = "Winter"
		if @scheduleNum == nil then @scheduleNum = 0 end

		checkParams = []
		if params["dayOffCheckbox"] != nil then checkParams.append("day_off") end
		if params["minTimeCheckbox"] != nil then checkParams.append("min_time") end
		if params["waitlistCheckbox"] != nil then checkParams.append("waitlist") end

		#save classes
		if params[:classes] != nil
			@last_classes = params[:classes]
		else
			@last_classes = @default_classes
		end

		genReturn = generateSchedule(params[:classes],params["term"],checkParams)
		@schedules = genReturn[0]
		@error_msg = genReturn[1]
		
		if @schedules != [[]] and @schedules != [{}]
			@winScroll = true
		else
			@schedules = []
			@winScroll = false
		end

		@scheduleCount = @schedules.length

		@days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"]

		#save term
		if params["term"] != nil
			@last_term = params["term"]
		end

		@all_lec = Lecture.all.size
	end
	
end
