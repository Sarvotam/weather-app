require 'net/http'

class WeatherWorker
  include Sidekiq::Worker

  LOCATIONS = [
    # Asian countries
    { lat: 39.9042, lon: 116.4074 },   # Beijing, China
    { lat: 28.6139, lon: 77.2090 },    # New Delhi, India
    { lat: 35.682839, lon: 139.759455 }, # Tokyo, Japan
    { lat: 52.5200, lon: 13.4050 },    # Berlin, Germany
    { lat: 33.6844, lon: 73.0479 },    # Islamabad, Pakistan
    { lat: 23.8103, lon: 90.4125 },    # Dhaka, Bangladesh
    { lat: 21.0285, lon: 105.8542 },   # Hanoi, Vietnam
    { lat: 13.7563, lon: 100.5018 },   # Bangkok, Thailand
    { lat: 3.1390, lon: 101.6869 },    # Kuala Lumpur, Malaysia

    # European countries
    { lat: 48.8566, lon: 2.3522 },     # Paris, France
    { lat: 51.5074, lon: -0.1278 },    # London, United Kingdom
    { lat: 55.7558, lon: 37.6176 },    # Moscow, Russia
    { lat: 52.5200, lon: 13.4050 },    # Berlin, Germany
    { lat: 41.9028, lon: 12.4964 },    # Rome, Italy
    { lat: 40.4168, lon: -3.7038 },    # Madrid, Spain
    { lat: 52.2297, lon: 21.0122 },    # Warsaw, Poland
    { lat: 47.4979, lon: 19.0402 },    # Budapest, Hungary
    { lat: 48.2082, lon: 16.3738 },    # Vienna, Austria
    { lat: 45.8150, lon: 15.9819 },    # Zagreb, Croatia
  ]

  def perform
    LOCATIONS.each do |location|
      @lat = location[:lat]
      @lon = location[:lon]
  
      url = "https://api.openweathermap.org/data/2.5/weather?lat=#{@lat}&lon=#{@lon}&units=imperial&appid=6aae25b3ecfdaaf084e3616f41079a49"
  
      # Construct a URI object from the URL
      uri = URI(url)
  
      # Make an HTTP GET request
      response = Net::HTTP.get_response(uri)
  
      if response.is_a?(Net::HTTPSuccess)
        data = JSON.parse(response.body)
        save_weather_data(data)
      else
        puts "Failed to fetch weather data. HTTP status: #{response.code}"
      end
    end
  end
  

  def save_weather_data(weather_data)
    weather = Weather.find_or_initialize_by(lat: weather_data['coord']['lat'], lon: weather_data['coord']['lon'])

    weather.update(
      weather: weather_data['weather'][0]['main'],
      description: weather_data['weather'][0]['description'],
      pressure: weather_data['main']['pressure'],
      humidity: weather_data['main']['humidity'],
      country: weather_data['sys']['country'],
      name: weather_data['name']
    )

    weather.save!
    puts "Weather data saved successfully."
  end
end
