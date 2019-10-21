class MainController < ApplicationController
	def index
		require "./app/genSchedule.rb"
		schedule = generateSchedule(params[:classes])


		@title = 'Welcome to CuScheduling'

		@submitted = schedule

		@some_lecture = Lecture.first.name

		@lec_size = Lecture.all.size

		@tut_size = Tutorial.all.size
	end
	
end
