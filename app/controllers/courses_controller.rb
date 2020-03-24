class CoursesController < ApplicationController
	def index  
		if params[:course]
			# @courses = Lecture.find(:all,:conditions => ['name LIKE ?', "#{params[:term]}%"])
			@courses = Lecture.where(["name like ? and term = ?", "#{params[:course]}%", "#{params[:term]}"]).limit(10).distinct.pluck(:name)
		else
			# @courses = Lecture.all
		end
		
		respond_to do |format|  
			format.html # index.html.erb  
			# Here is where you can specify how to handle the request for "/people.json"
			format.json { render :json => @courses.to_json }
		end
	end
end
