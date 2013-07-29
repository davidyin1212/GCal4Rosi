require 'rubygems'
require 'net/http'
require 'gcal4ruby'
include GCal4Ruby

service  = Service.new
username = "davidyin1212"
password = "99003344"
service.authenticate("davidyin1212", "99003344")


puts "---Starting Event Recurrence Test---"
event = Event.new(service)
event.title = "Baseball Game"
event.calendar = service.calendars[0] 
event.where = "Municipal Stadium"
event.recurrence = Recurrence.new
event.recurrence.start_time = Time.now
event.recurrence.end_time = Time.now
event.recurrence.frequency = {"weekly" => ["SA"]}
event.save 
