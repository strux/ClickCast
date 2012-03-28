class Forecast

  attr_accessor :lat_lon, :params

  @url = "http://graphical.weather.gov/xml/SOAP_server/ndfdXMLclient.php"
  @lat_lon = {
    :index => [47.82398963940932, -121.54191970825195], 
  }
  @params = {
    :whichClient => "NDFDgenLatLonList", 
    :product => "time-series",
    :listLatLon => @lat_lon.map{|k,v| v.join("+") }.join("%2C"), 
    :temp => "temp",
    :pop12 => "pop12",
    :snow => "snow",
    :wspd => "wspd",
    :sky => "sky",
  }

  def initialize(lat_lon=nil)
    @lat_lon = lat_lon if lat_lon
  end

  private

  def self.request_url
    @url + "?" + @params.map{|k,v| "#{k}=#{v}" }.join('&')
  end

end
