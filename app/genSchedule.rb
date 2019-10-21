def generateSchedule(classes)
	#error check for no input
	if(classes == nil) then return "nothing yet!" end
	
	coursesArr = []
	for course in classes
		if classes[course].tr(" ","") != ""
			coursesArr.append(classes	[course].tr(" ",""))
		end
	end

	#@ actual schedule logic @#

	#query to get each course

	#query tutorials or labs if existent (also_reg)

	#some questions?
		#do all of these courses exist? -> return error not found
		#invalid course code type?
		#is one of them a tutorial?
		

	#loop through each tutorial possibility for each course possibility

	#save schedules with NO conflictions

	return coursesArr.to_s
	
end