require 'rubygems'
require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri'
require 'gcal4ruby'
require 'chronic'
include GCal4Ruby

#setup file to be parsed TODO setup using uri so can parse from web page without having to download the file
doc = Nokogiri::HTML(open("TimeTable.html"))

#setup new service TODO ask input from user
service  = Service.new
username = "davidyin1212"
password = "99003344"
service.authenticate("davidyin1212", "99003344")

#local helper variables
elements = doc.css("table")[0].css("tr[height='60']")		#top level tr element
dayOfWeek = doc.css("table")[0].css("tr[height='20']")		#keeps track of the days displayed in the header provides a hash to map 
								#loop values to particular days of the week
endDay = (Time.new(Time.now.year, 12, 31) - Time.now).to_i/(24*60*60*7)		#calculates the number of days till end of semester

#setup caledndar
cal = Calendar.new(service)
cal.title = 'testcalendar'+Time.now.to_s
cal.where = "Toronto"
cal.save
roomnum = 0
periodofDay = "AM"

for i in 0..elements.length - 1
	puts i
	puts row = elements[i].css('td')
	puts row[0].text.split(':')[0]
	if row[0].text.split(':')[0].strip == "12" #when calendar reaches 12 switch periond to PM 
		periodofDay = "PM"
	end
	#iterates through all td elements look for ones with class corresponding to "class2"
	for j in 0..row.length - 1
		if row[j]["class"] == "class2"
			#make new event for each day of corrsponding week until end of semeseter
			for a in 0..endDay
				# create new time objects
				puts dayOfWeek.css('td')[j].text
				puts btime = Chronic.parse(dayOfWeek.css('td')[j].text + ' ' + row[j].text[18..29].split('-')[0].strip + periodofDay)
				puts etime = Chronic.parse(dayOfWeek.css('td')[j].text + ' ' + row[j].text[18..29].split('-')[1].strip.split(/\D/)[0] + ':' + row[j].text[18..29].split('-')[1].strip.split(/\D/)[1] + periodofDay)
				event = Event.new(service)							#create new event
				event.title = row[j].text.split('LEC')[0].strip + ' ' + row[j].text[10..17]	#and assign title, date, time
				event.calendar = cal 								#and place
				puts roomnum
				puts event.where = doc.css("span.room")[roomnum].text
				puts event.start_time = btime + (7*24*60*60*a)
				puts event.end_time = etime + (7*24*60*60*a)
				event.save
			end		
		roomnum+=1
		end
	end
end
