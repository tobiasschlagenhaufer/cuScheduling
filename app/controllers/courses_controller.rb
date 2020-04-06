class CoursesController < ApplicationController
	def index  
		if params[:auto] == "true"
			# @courses = Lecture.find(:all,:conditions => ['name LIKE ?', "#{params[:term]}%"])
			@courses = Lecture.where(["name like ? and term = ?", "#{params[:course]}%", "#{params[:term]}"]).limit(10).distinct.pluck(:name)
		else
			query = []
			params[:name] ? query.append("name = '" + params[:name] + "'") : nil
			params[:subject] ? query.append(" name LIKE '" + params[:subject] + "%%'") : nil
			params[:status] ? query.append(" status like '%%" + params[:status] + "%%'") : nil
			params[:term] ? query.append(" term = '" + params[:term] + "'") : nil
			params[:location] ? query.append(" location like '%%" + params[:location] + "%%'") : nil

			if query.size < 1 
				query.append("1 = 1")
			end
			# sub_status = params[:status].presence || '*'
			# term = params[:term].presence || '*'
			# location = params[:days].presence || '*'
			
			# subject = params[:subject].presence || '*'
			# sub_status = params[:status].presence || '*'
			# term = params[:term].presence || '*'
			# location = params[:days].presence || '*'

			print(query.join(" and"))
			
			# @courses = Lecture.where(["name like ? and status like ? and term = ? and location like ?","#{subject}%","#{sub_status}","#{term}","#{location}"]).limit(10)
			@courses = Lecture.where(["#{query.join(" and")}"]).limit(100).select(:name,:section,:days,:s_time,:e_time,:location,:status,:term)

		end
		
		respond_to do |format|  
			format.html # index.html.erb  
			# Here is where you can specify how to handle the request for "/people.json"
			format.json { render :json => @courses.to_json }
		end
	end
end
