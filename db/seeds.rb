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

#===========================================================================================
dm_db = Roo::Excelx.new(Rails.root.join('db', 'db.xlsx')).sheet('dm_db')

# dm_db column definations ==========================
size = dm_db.last_row - 1
# for cities
cities = dm_db.column(2).drop(1)
meals = dm_db.column(3).drop(1)
airKeys = dm_db.column(4).drop(1)
citiesPhoto = dm_db.column(5).drop(1)
latitude = dm_db.column(6).drop(1)
longitude = dm_db.column(7).drop(1)
# for countries
countries = dm_db.column(8).drop(1)
nationality = dm_db.column(9).drop(1)
eng_lvl = dm_db.column(10).drop(1)
speaking_lang = dm_db.column(11).drop(1)
currency = dm_db.column(12).drop(1)
# for regions
regions = dm_db.column(13).drop(1)

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
      nationality: nationality[i],
      english_level: eng_lvl[i],
      language: speaking_lang[i],
      currency: currency[i],
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
      meal_average_price_cents: meals[i].to_f,
      airport_key: airKeys[i],
      latitude: latitude[i],
      longitude: longitude[i],
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

#===========================================================================================

risks_db = Roo::Excelx.new(Rails.root.join('db', 'risks_db.xlsx')).sheet('riskDb')

# risks_db column definations ==========================
size = risks_db.last_row - 1
cities = risks_db.column(1).drop(1)
safety_rank = risks_db.column(2).drop(1)
overrall_risk = risks_db.column(3).drop(1)
pickpoket_risk = risks_db.column(4).drop(1)
mugging_risk = risks_db.column(5).drop(1)
scams_risk = risks_db.column(6).drop(1)
transport_and_taxis_risk = risks_db.column(7).drop(1)
natural_disasters_risk = risks_db.column(8).drop(1)
terrorism_risk = risks_db.column(9).drop(1)
women_travelers_risk = risks_db.column(10).drop(1)

puts "------- Level Of Safeties Saving -------"
counter = 0
safety_rank.each_with_index do |rank, i|
    saf = LevelOfSafety.new(
      safety_rank: rank,
      overrall_risk: overrall_risk[i],
      pickpoket_risk: pickpoket_risk[i],
      mugging_risk: mugging_risk[i],
      scams_risk: scams_risk[i],
      transport_and_taxis_risk: transport_and_taxis_risk[i],
      natural_disasters_risk: natural_disasters_risk[i],
      terrorism_risk: terrorism_risk[i],
      women_travelers_risk: women_travelers_risk[i],
      city: City.find_by(name: cities[i])
    )
    if saf.save
      p "======== > Level of safety for #{saf.city.name} created!"
      counter += 1
    else
      p "======== > Error for country: #{saf.errors.messages}"
    end
end
puts "Total #{counter} Level of Safety saved !!!"
puts ""

visa_db = Roo::Excelx.new(Rails.root.join('db', 'visa_db.xlsx')).sheet('visa')

# #1 for each city.
# puts "------- Accommodations Saving -------"
# accommodationPhoto = "https://media-cdn.tripadvisor.com/media/photo-s/08/34/c0/41/v-one-vogue-hotel.jpg"
#   City.all.each do |city|
#   accommodation = Accommodation.new(
#     city: city,
#     name: "#{city.name} Sofitel",
#     address: Faker::Address.full_address,
#     price: 35,
#     booking_url: "url",
#     score: "8.2"
#     )
#   accommodation.remote_photo_url = accommodationPhoto
#   accommodation.save!
#   p "======== > Accommodation #{accommodation.name} Stored !"
# end
