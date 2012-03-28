require 'sinatra'
require 'rubygems'
require 'rest_client'
require 'rexml/document'


# Controllers
get '/' do
  @url = "http://www.weather.gov/forecasts/xml/SOAP_server/ndfdXMLclient.php?whichClient=NDFDgenLatLonList&listLatLon=38.99%2C-77.02&product=glance"
  # @result = RestClient.get(@url)
  # @xml = REXML::Document.new(@result)
end
