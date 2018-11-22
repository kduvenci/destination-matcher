# require "faker"
require 'roo'

if Rails.env.development?
 Flight.destroy_all
 Accommodation.destroy_all
 User.destroy_all
 City.destroy_all
 Country.destroy_all
 Region.destroy_all
 puts "DB destroyed!"
end

dm_db = Roo::Excelx.new(Rails.root.join('db', 'database.xlsx')).sheet('dm_db')

size = dm_db.last_row - 1
regions = dm_db.column(4).drop(1)

countries = dm_db.column(3).drop(1)
engLvl = dm_db.column(7).drop(1)
curs = dm_db.column(8).drop(1)
speakLang = dm_db.column(10).drop(1)

cities = dm_db.column(2).drop(1)
airKeys = dm_db.column(5).drop(1)
meals = dm_db.column(6).drop(1)
citiesPhoto = dm_db.column(9).drop(1)

puts "------- Regions Saving -------"
counter = 0
regions.each do |region|
  unless Region.find_by(name: region)
    reg = Region.new(name: region)
    if reg.save
      p "======== > #{reg.name} created!"
      counter += 1
    else
      p "======== > Error for degion: #{reg.errors.messages}"
    end
  end
end
puts "Total #{counter} region saved !!!"
puts ""

puts "------- Countries Saving -------"
counter = 0
countries.each_with_index do |country, i|
  unless Country.find_by(name: country)
    cou = Country.new(
      name: country,
      language: speakLang[i],
      english_level: engLvl[i],
      currency: curs[i],
      region: Region.find_by(name: regions[i])
    )
    if cou.save
      p "======== > #{cou.name} created!"
      counter += 1
    else
      p "======== > Error for country: #{cou.errors.messages}"
    end
  end
end
puts "Total #{counter} countries saved !!!"
puts ""

puts "------- Cities Saving -------"
counter = 0
cities.each_with_index do |city, i|
  unless City.find_by(name: city)
    cit = City.new(
      name: city,
      photo: citiesPhoto[i],
      meal_average_price_cents: meals[i],
      airport_key: airKeys[i],
      country: Country.find_by(name: countries[i])
    )
    if cit.save
      p "======== > #{cit.name} created!"
      counter += 1
    else
      p "======== > Error for city: #{cit.errors.messages}"
    end
  end
end
puts "Total #{counter} cities saved !!!"



# #REGION: Creates 10 regions, one for each country card and city bellow.
# counter = 0
# regions = []
# region_names = ["Asia", "Americas", "Americas", "Asia", "Europe", "Europe", "Asia", "Europe", "Americas", "Europe"]
# 10.times do
#   region = Region.new(
#     name: region_names[counter])
#   region.save!
#   regions << region
#   counter += 1
# end

# #COUNTRY: Creates 10 country cards, each with respective currency, language, etc.
# counter = 0
# countries = []
# country_names = ["Japan", "Brazil", "Bahamas", "Turkey", "France", "Germany", "China", "Spain", "United States", "Italy"]
# currency_names = ["Yen", "Real", "Bahamian dollar", "Lira", "Euro", "Euro", "Yuan", "Euro", "Dollar", "Euro"]
# languages_names = ["Japanese", "Brazilian Portuguese", "English", "Turkish", "French", "German", "Mandarin", "Spanish", "English", "Italian"]
# levels_of_english = [3, 3, 5, 3, 3, 3, 4, 3, 5, 3]
# 10.times do
#   country = Country.new(
#     name: country_names[counter],
#     language: languages_names[counter],
#     english_level: levels_of_english[counter],
#     currency: currency_names[counter],
#     region: regions[counter])
#   country.save!
#   countries << country
#   counter += 1
# end

# #CITY: Creates 10 cities, one for each country card above.
# counter = 0
# cities = []
# city_names = ["Tokyo", "Rio de Janeiro", "Nassau", "Istanbul", "Paris", "Berlin", "Beijing", "Madrid", "Washington", "Rome"]
# city_photos = ["http://i.imgur.com/tYbuMsG.jpg", "https://iso.500px.com/wp-content/uploads/2014/06/2048-4.jpg", "http://paperlief.com/images/paradise-island-nassau-wallpaper-3.jpg", "http://7wallpapers.net/wp-content/uploads/1_Istanbul.jpg", "https://worldinparis.com/wp-content/uploads/2018/06/Paris-At-Night.jpg", "https://law.depaul.edu/academics/study-abroad/berlin-germany/PublishingImages/Berlin-skyline-SpreeRiver_1600.jpg", "https://c1.staticflickr.com/8/7311/11478710913_bb2506b43c_b.jpg", "https://wallpapercave.com/wp/wp1916447.jpg", "https://s1.it.atcdn.net/wp-content/uploads/2015/08/99-Washington-DC.jpg", "https://www.tripsavvy.com/thmb/JxlppG4rgyOZbGmBP1D1sJkcto4=/960x0/filters:no_upscale():max_bytes(150000):strip_icc()/DC-Mall-589e126d3df78c4758e37e44.jpg"]
# 10.times do
#   city = City.new(
#   country: countries[counter],
#   name: city_names[counter],
#   photo: city_photos[counter],
#   meal_average_price_cents: 15)
#   #city.remote_photo_url = city_photos[counter]
#   city.save!
#   cities << city
#   counter += 1
# end

# #FLIGHT: Creates 5 flights.
# counter = 0
# flights = []
# airline_names = ["ANA", "Emirates", "Lufthansa", "Thai Airways", "Cathay Pacific Airways"]
# 5.times do
#   flight = Flight.new(
#     depart_departure_time: Time.now,
#     depart_arrival_time: Time.now,
#     return_departure_time: Time.now,
#     return_arrival_time: Time.now,
#     departure_location: city_names[counter],
#     return_location: city_names[counter],
#     price: 1000,
#     city: cities[counter],
#     airline_name: airline_names[counter])
#   flight.save!
#   flights << flight
#   counter += 1
# end

# #ACCOMMODATION: Creates 5 accommotations.
# #WARNING; No photos added yet.
# counter = 0
# accommodations = []
# accommodation_names = ["Sofitel", "Ritz Carlton", "The Westin", "Novotel", "Napoleon"]
# accommodation_photos = ["http://i.imgur.com/tYbuMsG.jpg","http://i.imgur.com/tYbuMsG.jpg","http://i.imgur.com/tYbuMsG.jpg","http://i.imgur.com/tYbuMsG.jpg","http://i.imgur.com/tYbuMsG.jpg"]
# 5.times do
#   accommodation = Accommodation.new(
#     city: cities[counter],
#     name: accommodation_names[counter],
#     price: 300,
#     star: 4,
#     photo:accommodation_photos[counter])
#   #accommodation.remote_photo_url = accommodation_photos[counter]
#   accommodation.save!
#   accommodations << accommodation
#   counter += 1
# end

# #USER: Creates 5 users.
# counter =0
# users= []
# 5.times do
#   user = User.new(
#     name: Faker::Name.name,
#     nationality: Faker::Nation.nationality,
#     email: Faker::Internet.email,
#     password: "123456")
#   user.save!
#   users << user
#   counter += 1
# end
