def scrape
	require 'mechanize'
	Lecture.connection
	Tutorial.connection

	days = ["Mon","Tue","Wed","Thu","Fri"]
	lecture_group = ["Lecture","Seminar","Research Essay"]
	tutorial_group = ["Tutorial","Laboratory","Discussion Group","Problem Analysis",] #add more later
	terms_list = ["Winter","Summer","Fall"]
	
	#Browser
	br = Mechanize.new

	#Proper Certificates
	br.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	br.user_agent_alias = "Windows IE 7"

	url = 'https://central.carleton.ca/prod/bwysched.p_select_term?wsea_code=EXT'
	begin
		page = br.get(url)
	rescue => error
		puts "Error accessing carleton page, "
		sleep(2)
		#!! add protection from network error, abort or timeout, add timer delay
		scrape
		return
	end

	#clear db when connection is established
	Lecture.delete_all
	Tutorial.delete_all

	form = page.forms.first

	##stuff from here
	for term in form.field_with(:name => 'term_code').options
		form['term_code'] = term
		search_page = form.submit

		term_name = terms_list[(term.value[4].to_i) -1]
		puts term_name

		#if term_name == "Summer" then next end

		search_form = search_page.forms.first
		#search_form['sel_levl'] = "UG"

		numOption = search_form.field_with(:id => "subj_id").options.length
		#puts numOption

		(numOption-1).times do |i|

			search_form.field_with(:id => 'subj_id').options[i].click
			search_form.field_with(:id => 'subj_id').options[i+1].click
			
			curr_class = "looking at "+search_form.field_with(:id => 'subj_id').options[i+1].value 
			#puts curr_class

			c_page = search_form.submit

			#catch no classes error
			no_courses = Nokogiri::HTML(c_page.body).xpath("//table[@class='plaintable' and @summary='This layout table holds message information']")
			if no_courses.length >= 1 then next end

			table = Nokogiri::HTML(c_page.body).xpath("//table[@width='883']")[1]

			course_pos = []
			all_tr = table.xpath("tr")
			all_tr.pop #removes last empty tr

			all_tr.each_with_index do |tr,index|
				#if tr.xpath("td").length == 1 then course_pos.push(index+1) end
				first_td = tr.xpath("td")[0]
				if first_td.to_s[0...30] == '<td align="center" width="5%">' then course_pos.push(index) end
			end

			#puts course.to_s

			course_pos.each do |index|

				#first line
				info1 = all_tr[index].xpath("td")

				if info1.size < 10 then next end
				info1 = info1.map do |s| 
					s = s.text.to_s.tr("\n","")
				end
				status = info1[1]
				course_name = info1[3].tr(" ","")
				section = info1[4]
				course_type = info1[7]
				prof = info1[10]

				#second line
				course_days = ""
				if all_tr[index+1] !=nil
					info2 = all_tr[index+1].content.to_s

					unless info2.include? "Meeting Date"
						next
					end

					days.each do |day|
						if info2.include? day then course_days += day + " " end
					end
					time_str = info2.split("Time: ")[1].split(" ")
					start_time = time_str[0]
					end_time = time_str[2]

					location = info2.split("Building: ")[1].chomp("\n")

					if start_time == "Building:"
						start_time = "NA"
						end_time = "NA"
					end

					if location == " Room:"
						location = "NA"
					end

				#no info on that line found
				elsif all_tr[index+1] == nil
					start_time = "NA"
					end_time = "NA"
					location = "NA"
					puts "no info for: " + course_name 
				end
			
				#third line
				also_reg = "";
				if(all_tr[index+2] != nil)
					info3 = all_tr[index+2].xpath("td");

					if info3.length > 1 and info3[1].content.to_s.include? "Also Register in:"
						also_reg = info3[1].content.to_s
						also_reg = also_reg.split("Register in:")[1]#[1...-1]
					end
				end
					
				#commit to DB
				if status != "Registration Closed" and status != "Waitlist Full" and status != "Full, No Waitlist"
					if lecture_group.include? course_type or also_reg == "" #any class with no tutorial will be considered a lecture type
						lecture = Lecture.create(name:course_name,section:section,term:term_name,days:course_days,s_time:start_time,e_time:end_time,location:location,also_reg:also_reg,status:status)
						lecture.save
					elsif tutorial_group.include? course_type
						tutorial = Tutorial.create(name:course_name,section:section,term:term_name,days:course_days,s_time:start_time,e_time:end_time,location:location,status:status)
						tutorial.save
					end
				end

			end
			
			
		end
	
	end	
 
end

# start = Time.now
# $num_classes = 0
# scrape
# finish = Time.now

# puts "took: " + (finish - start).to_s
# puts "average of " + ((finish - start)/$num_classes).to_s + " seconds per class"