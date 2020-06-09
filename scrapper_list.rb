require 'nokogiri'
require 'open-uri'
require 'json'
# require_relative 'scrapper_personnal'

def list_scrapper(card)
  array = []
  search_name = card.search('.CardSearch-name')
  name_array = name_scrapper(search_name)
  raw_job = card.search('.CardSearch-job').text
  adress_arr = adress_scrapper(card)
  array << {
    first_name: name_array[0],
    last_name: name_array[1],
    job: clean_job!(raw_job),
    workplace: [{
      street: adress_arr[0],
      postal: adress_arr[1],
      city: adress_arr[2]
    }],
    phone: phone_scrapper(card)
  }
  array
end

def adress_scrapper(card)
  raw_adress = card.search('.CardSearch-adress').text
  if raw_adress.empty?
    %w[no_street no_postal no_city]
  else
    clean_adress!(raw_adress)
  end
end

def phone_scrapper(card)
  raw_phone = card.search('@data-toggletext').first
  return 'no_phone' if raw_phone.nil?

  raw_phone.value.split.compact.join
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
  array.flatten
end

def clean_job!(raw_job)
  job_array = raw_job.split(',')
  job_array.each do |job|
    job.downcase!
    job.strip!
  end
end

def clean_adress!(raw_adress)
  raw_adress.strip!.delete_prefix!('Localisation ')
  adress_array = raw_adress.split(' - ')
  postal = adress_array[1].slice!(/\d{5}/)
  city = adress_array[1].strip!
  [adress_array[0].strip, postal, city]
end
