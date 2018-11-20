# require "faker"

if Rails.env.development?
 Flight.destroy_all
 # Accommodation.destroy_all
 # User.destroy_all
 City.destroy_all
 Country.destroy_all
 Region.destroy_all
end

#REGION: Creates 10 regions, one for each country card and city bellow.
counter = 0
regions = []
region_names = ["Asia", "Americas", "Americas", "Asia", "Europe", "Europe", "Asia", "Europe", "Americas", "Europe"]
10.times do
  region = Region.new(
    name: region_names[counter])
  region.save!
  regions << region
  counter += 1
end

#COUNTRY: Creates 10 country cards, each with respective currency, language, etc.
counter = 0
countries = []
country_names = ["Japan", "Brazil", "Bahamas", "Turkey", "France", "Germany", "China", "Spain", "United States", "Italy"]
currency_names = ["Yen", "Real", "Bahamian dollar", "Lira", "Euro", "Euro", "Yuan", "Euro", "Dollar", "Euro"]
languages_names = ["Japanese", "Brazilian Portuguese", "English", "Turkish", "French", "German", "Mandarin", "Spanish", "English", "Italian"]
levels_of_english = [3, 3, 5, 3, 3, 3, 4, 3, 5, 3]
10.times do
  country = Country.new(
    name: country_names[counter],
    language: languages_names[counter],
    english_level: levels_of_english[counter],
    currency: currency_names[counter],
    region: regions[counter])
  country.save!
  countries << country
  counter += 1
end

#CITY: Creates 10 cities, one for each country card above.
counter = 0
cities = []
city_names = ["Tokyo", "Rio de Janeiro", "Nassau", "Istanbul", "Paris", "Berlin", "Beijing", "Madrid", "Washington", "Rome"]
city_photos = ["http://i.imgur.com/tYbuMsG.jpg", "https://iso.500px.com/wp-content/uploads/2014/06/2048-4.jpg", "http://paperlief.com/images/paradise-island-nassau-wallpaper-3.jpg", "http://7wallpapers.net/wp-content/uploads/1_Istanbul.jpg", "https://worldinparis.com/wp-content/uploads/2018/06/Paris-At-Night.jpg", "https://law.depaul.edu/academics/study-abroad/berlin-germany/PublishingImages/Berlin-skyline-SpreeRiver_1600.jpg", "https://c1.staticflickr.com/8/7311/11478710913_bb2506b43c_b.jpg", "https://wallpapercave.com/wp/wp1916447.jpg", "https://s1.it.atcdn.net/wp-content/uploads/2015/08/99-Washington-DC.jpg", "https://www.tripsavvy.com/thmb/JxlppG4rgyOZbGmBP1D1sJkcto4=/960x0/filters:no_upscale():max_bytes(150000):strip_icc()/DC-Mall-589e126d3df78c4758e37e44.jpg"]
10.times do
  city = City.new(
  country: countries[counter],
  name: city_names[counter],
  photo: city_photos[counter],
  meal_average_price_cents: 15)
  #city.remote_photo_url = city_photos[counter]
  city.save!
  cities << city
  counter += 1
end

#FLIGHT: Creates 5 flights.
counter = 0
flights = []
airline_names = ["ANA", "Emirates", "Lufthansa", "Thai Airways", "Cathay Pacific Airways"]
5.times do
  flight = Flight.new(
    depart_departure_time: Time.now,
    depart_arrival_time: Time.now,
    return_departure_time: Time.now,
    return_arrival_time: Time.now,
    departure_location: city_names[counter],
    return_location: city_names[counter],
    price: 1000,
    city: cities[counter],
    airline_name: airline_names[counter],
    created_at: DateTime.now,
    updated_at: DateTime.now + 1)
  flight.save!
  flights << flight
  counter += 1
end

#ACCOMODATION: Creates 5 accomotations.
