require 'rubygems'
require 'selenium-webdriver'
require 'open-uri'
require 'nokogiri'

url = 'https://sws.rosi.utoronto.ca/sws/welcome.do?welcome.dispatch'

doc = Nokogiri::HTML(open(url))
puts doc.at_css("title").text
