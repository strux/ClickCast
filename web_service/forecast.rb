require 'date'
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
    unless @xml and @xml.class != REXML::Document
      xpath = REXML::XPath
      forecasts = []
      @locations.each_with_index do |location, i|
        f = Forecast.new(location)
        xpath.each(@xml, "//parameters[@applicable-location='point#{i+1}']/*") do |metric| 
          times = xpath.match(@xml, "//layout-key[text()='#{metric.attributes['time-layout']}']/following-sibling::start-valid-time")
          metric_values =[]
          j=0
          metric.each_element("value") do |v| 
            metric_values << [DateTime.strptime(times[j].text,'%Y-%m-%dT%H:%M:%S%z'), v.text]
            j+=1 
          end
          iname = "@" + metric.name.gsub("-", "_")
          f.instance_variable_set(iname, metric_values)
        end
        forecasts << f
      end
      forecasts
    else    
      raise "There is a problem with the forecast data. It does not appear to be XML."
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

  attr_accessor :name, :lat, :lon, :temperature

  def initialize(location)
    @name = location[0]
    @lat = location[1]
    @lon = location[2]
  end

end
