require 'rubygems'
require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri'
require 'gcal4ruby'
include GCal4Ruby

doc = Nokogiri::HTML(open("TimeTable.html"))
service  = Service.new
username = "davidyin1212"
password = "99003344"
service.authenticate("davidyin1212", "99003344")

def timeParse (time)
	begT = Time.parse(time.split('-')[0].strip)
	lastT = Time.parse(time.split('T')[0].strip + 'T' + time.split('-')[1].strip)
	return begT, lastT
end

elements = doc.css("table")[0].css("tr[height='60']")
timeDay = Time.now.day
endDay = (Time.new(Time.now.year, 12, 31) - Time.now).to_i/(24*60*60*7)
puts endDay
day = ["", "MO", "TU", "WE", "TH", "FR"]
cal = Calendar.new(service)
cal.title = 'testcalendar'+Time.now.to_s
cal.save
roomnum = 0
#puts elements.length
#puts elements

if (Time.now.day > 20)
	timeDay = timeDay - 7
end

for i in 0..elements.length - 1
	puts i
	puts row = elements[i].css('td')
	for j in 0..row.length - 1
		puts row[j]["class"]
		if row[j]["class"] == "class2"
			for a in 0..endDay
				puts time = Time.now.year.to_s + '/' + Time.now.month.to_s + '/' + (timeDay-(Time.now.wday-j)).to_s + 'T' + row[j].text[18..28] 
				event = Event.new(service)
				event.title = row[j].text.split('LEC')[0].strip + ' ' + row[j].text[10..17]
				event.calendar = cal 
				puts roomnum
				puts event.where = doc.css("span.room")[roomnum].text
				#event.recurrence = Recurrence.new
				puts event.start_time = timeParse(time)[0] + (7*24*60*60*a)
				puts event.end_time = timeParse(time)[1] + (7*24*60*60*a)
				#event.recurrence.frequency = {"weekly" => [day[j]]} 
				event.save
			end		
		roomnum+=1
		end
	end
end
