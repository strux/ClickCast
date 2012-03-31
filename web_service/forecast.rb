require 'rubygems'
require 'rest_client'
require 'rexml/document'

class ForecastFactory

  attr_accessor :params

  # Sets up defaults
  # Params:
  # +locations+:: Hash of floating point arrays. 
  # EX. @locations = [ ["Index", 47.82398963940932, -121.54191970825195], ["Newhalem", 48.678080, -121.243545] ]
  def initialize(locations)
    @url = "http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php"

    @params ||= {
      :whichClient => "NDFDgenLatLonList", 
      :product => "time-series",
      :temp => "temp",
      :pop12 => "pop12",
      :snow => "snow",
      :wspd => "wspd",
      :sky => "sky",
    }

    @locations = locations
    @params[:listLatLon] = locations_to_query_string
  end

  # Forecast object factory
  def create_forecasts
    xpath = REXML::XPath

    @locations.each_with_index do |location, i|
      puts location[0]
      xpath.each(@xml, "//parameters[@applicable-location='point#{i+1}']/*") do |metric| 
        times = xpath.match(@xml, "//layout-key[text()='#{metric.attributes['time-layout']}']/following-sibling::start-valid-time")
        puts "\t#{metric.name} - #{metric.attributes['time-layout']}"
        j=0
        metric.each_element("value"){ |v| puts "#{v.text} @ #{times[j]}"; j+=1 }
      end
    end

  end

  # Retieves forecasts data from NOAA web service
  def get_forecast_data
    result = RestClient.get(request_url)
    @xml = REXML::Document.new(result)
  end

  private
  
  def request_url
    @url + "?" + @params.map{|k,v| "#{k}=#{v}" }.join('&')
  end

  def locations_to_query_string
    @locations.map{ |l| "#{l[1]},#{l[2]}" }.join('+')
  end

end

class Forecast

  attr_accessor :name, :lat, :lon

end
