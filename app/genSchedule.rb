#some backend

def generateSchedule(classes,term,rankItems)
	time_start = Time.now
	err_msg = "" 
	defaultReturn = [ [[]], ""] #default return handle
	days = ["Mon","Tue","Wed","Thu","Fri"] #all days abbrev.
	courseColour = 1 #init course color

	#include waitlisted courses?
	if rankItems.include? "waitlist" 
		waitlisted = true
	else
		waitlisted = false
	end

	#error check for no input
	if(classes == nil) then return defaultReturn end
	
	requestedCourses = []
	for course in classes
		input = classes[course].tr(" ","").upcase
		if input != "" and classes[course] != "Enter your first course here"
			if !requestedCourses.include? input
				requestedCourses.append(input)
			else
				err_msg += "Course " + input + " already in search!%error%"
			end
		end
	end

	#check for no real strings in class field
	if requestedCourses == [] then return defaultReturn end

	### actual schedule logic ###

	lectureArr = [] #array of requested lectures
	#query to get each course
	requestedCourses.each do |lec_name|
		current_lecs = Lecture.where(name: lec_name, term: term)

		#check if lecture exists
		if current_lecs.size == 0
			err_msg += "Course " + lec_name + " does not exist!%error%"
			next 
		end

		#filter out closed
		current_lecs = current_lecs.to_a.delete_if { |lecture| !waitlisted and lecture[:status] == "Registration Closed"}

		#if now empty, means we only had closed sections
		if current_lecs.size == 0
			err_msg += "All sections for " + lec_name + " are closed!%error%"
			next
		end

		#filter out waitlist full, full no waitlist
		current_lecs = current_lecs.to_a.delete_if { |lecture| !waitlisted and (lecture[:status] == "Waitlist Full" or lecture[:status] == "Full, No Waitlist")}

		#if now empty, means we only had full sections
		if current_lecs.size == 0
			err_msg += "All sections for " + lec_name + " are full!%error%"
			next
		end

		#filter out waitlisted
		current_lecs = current_lecs.to_a.delete_if { |lecture| !waitlisted and lecture[:status] == "Waitlist Open" }

		#if now empty, means we only had waitlisted
		if current_lecs.size == 0
			err_msg += "Course " + lec_name + " has only waitlisted sections available!%error%"
			next
		end

		#lecture exists, create a spot
		lectureArr.append([])

		#go through each lecture section
		for current_lec in current_lecs
			#add also registers to tutorial query
			also_reg = current_lec.also_reg
			status_str_lec = ""
			if current_lec[:status] == "Waitlist Open" then status_str_lec = "(Waitlist)" end

			if (current_lec[:s_time] == "NA" or current_lec[:e_time] == "NA") then next end

			#query tutorials or labs if existent (also_reg)
			tutorialArr = ""
			if also_reg != ""
				tutorialArr = []
				tut_names = []

				#parse the tutorials
				tut_query = also_reg.split("and")

				tut_query.map! do |tut|
					tut[0] = ""
					tut.sub!(" ", "")
					parts = tut.split(" ",2)
					tut_names.append(parts[0].tr(" ",""))
					tut = parts[1].tr(" ","")
					tut.split("or")
				end

				#go through each tutorial queried
				tut_query.each_with_index do |query,index|
					tutorialArr.append([])
					query.each do |curr_section|
						tutorial_que = Tutorial.where(name: tut_names[index], section: curr_section, term: term).take

						if tutorial_que == nil or tutorial_que[:s_time] == "NA" or tutorial_que[:e_time] == "NA"
							next 
						end

						status_str_tut = ""
						if tutorial_que[:status] == "Waitlist Open" then status_str_tut = "(Waitlist)" end

						add_tut = {
							name: tutorial_que.name,
							section: tutorial_que.section,
							term: tutorial_que.term,
							days: tutorial_que.days,
							s_time: splitTime(tutorial_que.s_time),
							e_time: splitTime(tutorial_que.e_time),
							location: tutorial_que.location,
							colour: courseColour.to_s,
							status: status_str_tut
						}

						tutorialArr[index].append(add_tut)
					end

				end

			end

			if tutorialArr == [] then tutorialArr = "" end

			#add section to lecture array
			add_lec = {
				name: current_lec.name,
				section: current_lec.section,
				term: current_lec.term,
				days: current_lec.days,
				s_time: splitTime(current_lec.s_time),
				e_time: splitTime(current_lec.e_time),
				location: current_lec.location,
				tutorials: tutorialArr,
				colour: courseColour.to_s,
				status: status_str_lec
			}
			lectureArr[-1].append(add_lec)
			
			#puts add_lec
		end

		#increment course color for table display
		courseColour += 1

	end

	if lectureArr == [] or lectureArr == [[]] #nothing found
		return [ [[]] , err_msg ]
	end

	#some questions?
		#do all of these courses exist? -> return error not found
		#invalid course code type?
		#is one of them a tutorial?
		
	### determine all schedule combinations ###

	possibleSchedules = []
	lectureCombos = []
	lectureCombosPos = []
	#loop through each tutorial possibility for each course possibility to create array of positions
	for course in lectureArr #for every course
		lectureCombos.append([]) #make new spot in arrays
		lectureCombosPos.append([])
		counter = 0 #counter for course set to 0
		for section in course # for each section (A, B , C, etc)
			if section[:tutorials] == "" #if no tutorial in section, then just add section as a possibility
				lectureCombos[-1].append([section]) 
				lectureCombosPos[-1].append(counter)
				counter += 1
			else
				if section[:tutorials].length == 1 
					tutorialMatrix = section[:tutorials][0].each do |t| t = [t] end
				else
					tutorialMatrix = section[:tutorials][0]

					(1...section[:tutorials].length).each do |i|
						tutorialMatrix = tutorialMatrix.product(section[:tutorials][i])
					end

				end

				for tutorial in tutorialMatrix
					editSection = section
					editSection[:tutorials] = "" #free some memory in tutorial array (not needed anymore)
					lectureCombos[-1].append([editSection,tutorial].flatten)
					lectureCombosPos[-1].append(counter)
					counter += 1
				end
				
			end

		end
	end

	combinationMatrix = []
	for pos in lectureCombosPos[0] #append all combos for first course
		combinationMatrix.append([pos])
	end

	#loop through each other course, multiplying rows for each "course dimension"
	(1...lectureCombosPos.length).each do |pos| 
		#get product of both rows to get all possibilities in space
		combinationMatrix = combinationMatrix.product(lectureCombosPos[pos])
	end

	#flatten array to get single array of arrays
	for point in combinationMatrix
		point.flatten!
	end

	### save schedules with NO conflictions ###

	for point in combinationMatrix

		#get the combination from matrix
		currentSchedule = []
		#combine all courses and tutorials into a single schedule
		lectureCombos.each_index do |x|
			currentSchedule.concat(lectureCombos[x][point[x]])
		end

		#compare the combination
		flagged = false #flag marker for invalid schedule
		for day in days
			#puts day
			timesArr = []
			for block in currentSchedule #each class
				if block[:days].include? day
					if timesArr.length == 0
						timesArr.append([block[:s_time],block[:e_time]])
					else 
						#puts "	making a comparison"
						for times in timesArr
							#puts "		" + times[0].to_s + " "+ times[1].to_s + " comapred to " +block[:s_time].to_s + " " + block[:e_time].to_s
							if (block[:s_time] >= times[0] and block[:s_time] <= times[1])
								flagged = true
								#puts "		invalid!"
							end
							if (block[:e_time] >= times[0] and block[:e_time] <= times[1])
								flagged = true 
								#puts "		invalid!"
							end
						end

						timesArr.append([block[:s_time],block[:e_time]])
					end

				end
			end
			if flagged then break end

		end

		#add the schedule to possible schedules if no conflict
		if !flagged and currentSchedule != []
			possibleSchedules.append({score: 0, blocks: currentSchedule})
		end

	end

	for rankItem in rankItems
		if rankItem == "day_off" 
			possibleSchedules = rateByDaysOff(possibleSchedules)
		else rankItem == "min_time"
			possibleSchedules = rateByMinTime(possibleSchedules)
		end
	end

	if rankItems != nil && rankItems.length != 0
		#sort by score
		possibleSchedules = possibleSchedules.sort_by { |k| k[:score] }
		possibleSchedules.reverse!
	else
		possibleSchedules = possibleSchedules.shuffle
	end

	if possibleSchedules.length == 0
		err_msg = "Sorry, no schedule is possible with these classes"
	end

	puts "completed in " +(Time.now-time_start).to_s + " seconds"

	return [ possibleSchedules[0...20] , err_msg ] #[0...10]
	
end

def splitTime(timeStr)
	if timeStr[0] == "0" then timeStr[0] = "" end
	time = timeStr.split(":")
	timeSec = time[0].to_i * 3600
	timeSec += time[1].to_i * 60
	return timeSec
end

def rateByDaysOff(possibleSchedules)
	days = ["Mon","Tue","Wed","Thu","Fri"] #all days abbrev.

	for pSchedule in possibleSchedules
		for day in days
			flag = false
			for block in pSchedule[:blocks]
				if block[:days].include? day
					flag = true
				end
			end
			if !flag then pSchedule[:score] += 20 end
		end
	end
	
	return possibleSchedules

end

def rateByMinTime(possibleSchedules)
	days = ["Mon","Tue","Wed","Thu","Fri"] #all days abbrev.

	for pSchedule in possibleSchedules
		for day in days
			timesArr = []
			for block in pSchedule[:blocks]
				if block[:days].include? day
					timesArr.append([block[:s_time],block[:e_time]])
				end
			end
			if timesArr == [] then next end
			
			#otherwise, sort the times
			timesArr = timesArr.sort_by { |i| i[0] }

			(timesArr.length-1).times do |x|
				if  timesArr[x+1][0] - timesArr[x][1] <= 2401 #less than 40 minute slot
					#puts "times less than 40: " + (timesArr[x][1] - timesArr[x+1][0]).to_s
					pSchedule[:score] += 1
				end
			end

		end
	end

	return possibleSchedules

end