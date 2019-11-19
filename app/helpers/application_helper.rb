module ApplicationHelper

	def timeToString(timeInt)
		hour = timeInt / 3600
		timeInt -= (hour*3600)
		minute = timeInt / 60
		if minute < 10 then minute = ('0' + minute.to_s) end
		timeStr = hour.to_s + ":" + minute.to_s
	end
	
end
