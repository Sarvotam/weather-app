class WeatherController < ApplicationController
    require 'net/http'
  
    def index
        @weather_data = Weather.paginate(page: params[:page], per_page: 10) # Adjust per_page as needed
        @lat = 34.0479
      @lon = 100.6197
      url = "https://api.openweathermap.org/data/2.5/weather?lat=#{@lat}&lon=#{@lon}&units=imperial&appid=6aae25b3ecfdaaf084e3616f41079a49"
      uri = URI(url)
      
      begin
        @res = Net::HTTP.get_response(uri)
  
        if @res.is_a?(Net::HTTPSuccess)
          @data = JSON.parse(@res.body)
          save_weather_data(@data)
        else
          @error_message = "Failed to fetch weather data. HTTP status: #{@res.code}"
        end
      rescue StandardError => e
        @error_message = "An error occurred: #{e.message}"
      end
    end

    def save_weather_data(weather_data)
        begin
          existing_weather = Weather.find_by(lat: weather_data['coord']['lat'], lon: weather_data['coord']['lon'])
      
          if existing_weather
            # Update the existing record with new weather data
            existing_weather.update(
              weather: weather_data['weather'][0]['main'],
              description: weather_data['weather'][0]['description'],
              pressure: weather_data['main']['pressure'],
              humidity: weather_data['main']['humidity'],
              country: weather_data['sys']['country'],
              name: weather_data['name']
            )
      
            if existing_weather.save
              puts "Weather data updated successfully."
            else
              puts "Failed to update weather data. Validation errors: #{existing_weather.errors.full_messages}"
            end
          else
            # Create a new record if it doesn't exist
            new_weather = Weather.new(
              lat: weather_data['coord']['lat'],
              lon: weather_data['coord']['lon'],
              weather: weather_data['weather'][0]['main'],
              description: weather_data['weather'][0]['description'],
              pressure: weather_data['main']['pressure'],
              humidity: weather_data['main']['humidity'],
              country: weather_data['sys']['country'],
              name: weather_data['name']
            )
      
            if new_weather.save
              puts "New weather data saved successfully."
            else
              puts "Failed to save new weather data. Validation errors: #{new_weather.errors.full_messages}"
            end
          end
        rescue StandardError => e
          puts "An error occurred while processing weather data: #{e.message}"
        end
      end
  end
  