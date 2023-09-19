class WeatherController < ApplicationController 
  def index
    @weather_data = Weather.paginate(page: params[:page], per_page: 10) # Adjust per_page as needed
  end
end
  