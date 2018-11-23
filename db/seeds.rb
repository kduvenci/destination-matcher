require "faker"
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

dm_db = Roo::Excelx.new(Rails.root.join('db', 'db.xlsx')).sheet('dm_db')

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
      meal_average_price_cents: meals[i],
      airport_key: airKeys[i],
      country: Country.find_by(name: countries[i])
    )
    puts "PHOTO == > #{citiesPhoto[i]}"
    cit.remote_photo_url = citiesPhoto[i]
    if cit.save
      p "======== > #{cit.name} created!"
      counter += 1
    else
      p "======== > Error for city: #{cit.errors.messages}"
    end
  end
end
puts "Total #{counter} cities saved !!!"

#1 for each city.
puts "------- Accommodations Saving -------"
accommodationPhoto = "https://media-cdn.tripadvisor.com/media/photo-s/08/34/c0/41/v-one-vogue-hotel.jpg"
  City.all.each do |city|
  accommodation = Accommodation.new(
    city: city,
    name: "#{city.name} Sofitel",
    address: Faker::Address.full_address,
    price: 35,
    star: 2
    )
  accommodation.remote_photo_url = accommodationPhoto
  accommodation.save!
  p "======== > Accommodation #{accommodation.name} Stored !"
end

# FLIGHT: Creates 5 flights.
puts "------- Flights Saving -------"
counter = 0
airline_names = ["ANA", "Emirates", "Lufthansa", "Thai Airways", "Cathay Pacific Airways"]
5.times do
  returnCity = City.find_by(name: 'Taipei')
  flight = Flight.new(
    depart_departure_time: Time.now,
    depart_arrival_time: Time.now,
    return_departure_time: Time.now,
    return_arrival_time: Time.now,
    departure_location: City.all.sample.name,
    return_location: returnCity.name,
    price: 1000,
    city: returnCity,
    airline_name: airline_names[counter])
  flight.save!
  p "======== > Flight Stored !"
  counter += 1
end



# USER: Creates 5 users.
puts "------- Users Saving -------"
counter =0
5.times do
  user = User.new(
    name: Faker::Name.name,
    nationality: Faker::Nation.nationality,
    email: Faker::Internet.email,
    password: "123456")
  user.save!
  p "======== > User #{user.name} Stored !"
  counter += 1
end
