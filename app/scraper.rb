def scrape
	require 'mechanize'
	Lecture.connection
	Tutorial.connection

	days = ["Mon","Tue","Wed","Thu","Fri"]
	class_type = ["Lecture","Tutorial","Labratory"] #add more later
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

			course_pos = [0]
			all_tr = table.xpath("tr")
			all_tr.pop #removes last empty tr

			all_tr.each_with_index do |tr,index|
				if tr.xpath("td").length == 1 then course_pos.push(index+1) end
			end

			course_pos.each do |index|
				begin
					info1 = all_tr[index].xpath("td")
					info2 = all_tr[index+1].content.to_s

					#info1 = line1.xpath("td")
					if info1.size < 10 then next end
					info1 = info1.map do |s| 
						s = s.text.to_s.tr("\n","")
					end
					course_name = info1[3].tr(" ","")
					section = info1[4]
					course_type = info1[7]
					prof = info1[10]

					#info2 = line2.content.to_s
					course_days = ""
					days.each do |day|
						if info2.include? day then course_days += day + " " end
					end
					time_str = info2.split("Time: ")[1].split(" ")
					start_time = time_str[0]
					end_time = time_str[2]

					location = info2.split("Building: ")[1]
					#puts "\t"+course_name

					info3 = all_tr[index+2].xpath("td");
					also_reg = "";
					if info3.length > 1 and info3[1].content.to_s.include? "Also Register in:"
						also_reg = info3[1].content.to_s
						also_reg = also_reg.split("Register in:")[1][1...-1]
					end
					#$num_classes += 1

					if course_type == "Lecture" || course_type == "Seminar"
						lecture = Lecture.create(name:course_name,section:section,term:term_name,days:course_days,s_time:start_time,e_time:end_time,location:location,also_reg:also_reg)
						lecture.save
					elsif course_type == "Tutorial" or course_type == "Laboratory"
						tutorial = Tutorial.create(name:course_name,section:section,term:term_name,days:course_days,s_time:start_time,e_time:end_time,location:location)
						tutorial.save
					end
				rescue
					puts "error getting a course here, skipped class: "
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