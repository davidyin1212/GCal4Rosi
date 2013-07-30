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
	puts begT
	puts lastT
	return begT, lastT
end

elements = doc.css("table")[0].css("tr[height='60']")
timeDay = Time.now.day
day = ["", "MO", "TU", "WE", "TH", "FR"]
#puts elements.length
#puts elements

if (Time.now.day > 20)
	timeDay = timeDay - 7
end

for i in 0..elements.length - 1
	puts i
	puts row = elements[i].css('td')
	for j in 0..row.length - 1
		#puts row[j]["class"]
		if row[j]["class"] == "class2"
			puts time = Time.now.year.to_s + '/' + Time.now.month.to_s + '/' + (timeDay-(Time.now.wday-j)).to_s + 'T' + row[j].text[18..28] 
			event = Event.new(service)
			event.title = row[j].text.split('LEC')[0].strip + ' ' + row[j].text[10..17]
			event.calendar = service.calendars[0] 
			event.where = "Municipal Stadium"
			event.recurrence = Recurrence.new
			event.recurrence.start_time, event.recurrence.end_time = timeParse(time)
			event.recurrence.frequency = {"weekly" => [day[j]]} 
		 	#event.recurrence.frequency = {"interval" => "2"}
			puts DateTime.new(2013,12,31)
			event.recurrence.repeat_until = DateTime.new(2013,12,31) #Date.parse("2013-12-31") + 
			event.save 
		end
	end
end
