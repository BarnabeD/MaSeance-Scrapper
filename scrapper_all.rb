require 'nokogiri'
require 'open-uri'
require 'json'

def scrapper_for_all(page_int)
  array = []
  url = open("https://monpsy.psychologies.com/Psys?page=#{page_int}").read
  doc = Nokogiri::HTML(url)
  search_card = doc.search('.CardSearch')

  search_card.each do |this_card|
    search_name = this_card.search('.CardSearch-name')
    temp_array = name_scrapper(search_name)

    raw_job = this_card.search('.CardSearch-job').text
    temp_array << clean_job!(raw_job)

    raw_adress = this_card.search('.CardSearch-adress').text
    temp_array << clean_adress!(raw_adress)

    raw_phone = this_card.search('@data-toggletext').first.value
    temp_array << clean_phone!(raw_phone)

    array << temp_array
  end
p array
end

def solo_name_to_fullname_array(card)
  full_name_array = []
  card.each do |psy_name|
    full_name_array << psy_name.text
  end
  full_name_array
end

def name_scrapper(card)
  array = []
  card.each do |card_search_name|
    card_info = card_search_name.search('.ezstring-field')
    psy_href = card_search_name.attribute('href').value
    array << solo_name_to_fullname_array(card_info).push(psy_href)
  end
  return array.flatten
end

def clean_job!(raw_job)
  job_array = raw_job.split(', ')
  job_array.each do |job|
    job.downcase!
    job.strip!
  end
  job_array
end

def clean_adress!(raw_adress)
  raw_adress.strip!.delete_prefix!("Localisation ")
  adress_array = raw_adress.split(" - ")
  postal = adress_array[1].slice!(/\d{5}/)
  city = adress_array[1].strip!
  [adress_array[0], postal, city]
end

def clean_phone!(raw_phone)
  raw_phone.split.compact.join
end

scrapper_for_all(1)
# (16..20).each do |num|
#   scrapper_for_all(num)
# end

