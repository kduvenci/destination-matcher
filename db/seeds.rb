# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Rails.env.development?
 Country.destroy_all
 City.destroy_all
end

counter = 0
countries = []
country_names = ["Japan", "Brazil", "Bahamas", "Turkey", "France", "Germany", "China", "Spain", "United States", "Italy"]
region_names = ["Asia", "Americas", "Americas", "Asia", "Europe", "Europe", "Asia", "Europe", "Americas", "Europe"]
currency_names = ["Yen", "Real", "Bahamian dollar", "Lira", "Euro", "Euro", "Yuan", "Euro", "Dollar", "Euro"]
languages_names = ["Japanese", "Brazilian Portuguese", "English", "Turkish", "French", "German", "Mandarin", "Spanish", "English", "Italian"]
levels_of_english = [3, 3, 5, 3, 3, 3, 4, 3, 5, 3]
10.times do
  country = Country.new(
    name: country_names[counter],
    language: languages_names[counter],
    english_level: levels_of_english[counter],
    currency: currency_names[counter],
    region: region_names[counter])
  country.save!
  countries << country
  counter += 1
end

counter = 0
city_names = ["Tokyo", "Rio de Janeiro", "Nassau", "Istanbul", "Paris", "Berlin", "Beijing", "Madrid", "Washington", "Rome"]
city_photos = ["http://i.imgur.com/tYbuMsG.jpg", "https://iso.500px.com/wp-content/uploads/2014/06/2048-4.jpg", "http://paperlief.com/images/paradise-island-nassau-wallpaper-3.jpg", "http://7wallpapers.net/wp-content/uploads/1_Istanbul.jpg", "https://worldinparis.com/wp-content/uploads/2018/06/Paris-At-Night.jpg", "https://law.depaul.edu/academics/study-abroad/berlin-germany/PublishingImages/Berlin-skyline-SpreeRiver_1600.jpg", "https://c1.staticflickr.com/8/7311/11478710913_bb2506b43c_b.jpg", "https://wallpapercave.com/wp/wp1916447.jpg", "https://s1.it.atcdn.net/wp-content/uploads/2015/08/99-Washington-DC.jpg"]
10.times do
  city = City.new(
  country: countries[counter],
  name: city_names[counter],
  photo: city_photos[counter],
  meal_average_price: 15)
  city.remote_photo_url = photos[counter]
  city.save!
  counter += 1
end
