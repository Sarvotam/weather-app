# config/schedule.rb

# Define a recurring job to fetch weather data periodically.
every 1.minutes do
  runner "WeatherWorker.perform_async"
end