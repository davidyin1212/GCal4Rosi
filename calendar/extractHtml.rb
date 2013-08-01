require 'rubygems'
require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri'
require 'gcal4ruby'
require 'chronic'
include GCal4Ruby

doc = Nokogiri::HTML(open("TimeTable.html"))
service  = Service.new
username = "davidyin1212"
password = "99003344"
service.authenticate("davidyin1212", "99003344")

def timeParse (time, periodofDay)
	puts begT = Time.parse(time.split('-')[0].strip) + (periodofDay ? 12*60*60:0)
	puts lastT = Time.parse(time.split('T')[0].strip + 'T' + time.split('-')[1].strip) + (periodofDay ? 12*60*60:0)
	return begT, lastT
end

elements = doc.css("table")[0].css("tr[height='60']")
dayOfWeek = doc.css("table")[0].css("tr[height='20']")
endDay = (Time.new(Time.now.year, 12, 31) - Time.now).to_i/(24*60*60*7)
puts endDay
cal = Calendar.new(service)
cal.title = 'testcalendar'+Time.now.to_s
cal.where = "Toronto"
cal.save
roomnum = 0
periodofDay = "AM"
#puts elements.length
#puts elements

for i in 0..elements.length - 1
	puts i
	puts row = elements[i].css('td')
	puts row[0].text.split(':')[0]
	if row[0].text.split(':')[0].strip == "12"
		periodofDay = "PM"
	end
	for j in 0..row.length - 1
		puts row[j]["class"]
		if row[j]["class"] == "class2"
			for a in 0..endDay
				#puts time = Time.now.year.to_s + '/' + Time.now.month.to_s + '/' + (timeDay-(Time.now.wday-j)).to_s + 'T' + row[j].text[18..28]
				puts dayOfWeek.css('td')[j].text
				puts btime = Chronic.parse(dayOfWeek.css('td')[j].text + ' ' + row[j].text[18..29].split('-')[0].strip + periodofDay)
				puts etime = Chronic.parse(dayOfWeek.css('td')[j].text + ' ' + row[j].text[18..29].split('-')[1].strip.split(/\D/)[0] + ':' + row[j].text[18..29].split('-')[1].strip.split(/\D/)[1] + periodofDay)
				event = Event.new(service)
				event.title = row[j].text.split('LEC')[0].strip + ' ' + row[j].text[10..17]
				event.calendar = cal 
				puts roomnum
				puts event.where = doc.css("span.room")[roomnum].text
				#event.recurrence = Recurrence.new
				puts event.start_time = btime + (7*24*60*60*a)
				puts event.end_time = etime + (7*24*60*60*a)
				#event.recurrence.frequency = {"weekly" => [day[j]]} 
				event.save
			end		
		roomnum+=1
		end
	end
end
