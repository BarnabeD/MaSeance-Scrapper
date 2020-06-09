require 'nokogiri'
require 'open-uri'
require 'json'
require_relative 'scrapper_list'

# //////////////////////  TODO : /////////////////
#
# ajouter un if pour le rest !
# pas plus d'info sur les fiches non premium
# continuer le scrap ppur :
#  - Adeli scrapper (dans organism ?)
#  - linkedIn
#  - Site web
#  - prix
#  - moyens de payement
#  - public
#  - motif
#  - methode
#  - formation
#  - Tenter de recuperer le mail...
#
# Connecter le scraper_list sur celui la
#
# //////////////////////  TODO : /////////////////

def scrapper_personal(psy_url, card)
  psy_url = open("https://monpsy.psychologies.com#{psy_url}").read
  psy_page = Nokogiri::HTML(psy_url)
  search_name = card.search('.CardSearch-name')
  name_array = name_scrapper(search_name)

  array = [{
    civility: civility_scrapper(psy_page).first,
    first_name: name_array[0],
    last_name: name_array[1],
    job: job_scrapper(psy_page),
    phone: premium_phone_scrapper(psy_page),
    avatar: image_scrapper(psy_page),
    description: description_scrapper(psy_page),
    workplace: workplace_scrapper(psy_page)
    # organism: organism_scrapper(psy_page)[0],
    # lang: organism_scrapper(psy_page)[1],
    # other: organism_scrapper(psy_page)[2],
  }]
  array
end

def workplace_scrapper(psy_page)
  array = []
  arr = psy_page.search('.col-md-8' '.col-xs-12')
  arr.each do |element|
    array << str_to_arr_cleaner(element.text).length
    array << str_to_arr_cleaner(element.text)
  end

  array.flatten!
  array.reject! { |e| e == 'Prendre contact' }
  workplace = workplace_cutter(array)
  workplace
end

def workplace_cutter(array)
  workplace = []
  while array.length >= 4
    limit = array.slice!(0) - 1
    sub_arr = array.slice!(0..limit)
    sub_arr[1].delete_prefix!('Adresse du cabinet ')
    sub_arr.delete('France')
    workplace << {
      adress_name: sub_arr.slice!(0).strip,
      postal: sub_arr[-1].slice!(/\d{5}/),
      city: sub_arr.slice!(-1).strip,
      street: sub_arr.join(' ').strip
    }
  end
  workplace
end

def str_to_arr_cleaner(string)
  string = string.strip
  array = string.split(/\n/)
  array.map! do |element|
    element.strip!
    element.split(': ')
  end
  if array.length.positive?
    array.flatten!.compact
  else
    array
  end
end

def image_scrapper(psy_page)
  img = psy_page.search('.Card-head img').first.attribute('src').value
  return 'no_image' if img == '/bundles/psychologiesannuairefront//images/user.png'

  img
end

def description_scrapper(psy_page)
  string = psy_page.search('.eztext-field').text
  string.strip.gsub(/\r\n|\r|\n|\t/, " ").gsub("  ", " ")
end

def civility_scrapper(psy_page)
  string = psy_page.search('.Title' '.Title--1' '.Title--center').text
  array = string.split(' ')
  array
end

def job_scrapper(psy_page)
  string = psy_page.search('.Title' '.Title--3' '.Title--center').text
  array = string.split(',')
  array.each { |str| str.strip! }
  array
end

def premium_phone_scrapper(psy_page)
  return 'no_phone' if psy_page.search('@data-toggletext').first.nil?

  psy_page.search('@data-toggletext').first.value
end

# def linkedin_scraper(psy_page)
#   # //////////////////////  ATTENTION : /////////////////
#   # ne marche pas .... je n'arrive pas a récuperer l'adress linkedin
#   # Ruby plante malgré les test quand la string est vide.
#   # //////////////////////  ATTENTION : /////////////////

#   linkedin = 'no_linkedin'
#   psy_page.search('.Btn--icon').each_with_index do |e, i|
#     string = e.attribute('href')
#     unless string.nil?
#       string2 = string.value
#       # p string2.class
#       # unless string2.match(/https:\/\/www.linkedin.com\/in\/\S*/)[0].nil?
#         linkedin = string2.match(/https:\/\/www.linkedin.com\/in\/\S*/)[0]
#       # end
#     end
#   end
#   # p linkedin
# end

# def organism_scrapper(psy_page)
#   string = psy_page.search('.Openable-inner').first
#   # p string
#   return '' if string.nil?

#   array = str_to_arr_cleaner(string.text)
#   organism = array.select.with_index { |e, i| array[i - 1] == 'Membre de:'}
#   lang = array.select.with_index { |e, i| array[i - 1] == 'Langues parlées'}
#   other = array - lang - organism
#   other.delete('Langues parlées')
#   other.delete('Membre de:')
#   [organism, lang, other]
# end

# def json_scrapper(psy_page)
#   # raw_data = psy_page.search('@type')
#   raw_data = psy_page.search('script')
#   # raw id 3 = nom prenom adresse1 job photo description site linkedin
#   # rax id 8 prix
#   # raw id 9 adresse cabinets mail

#   p raw_data[3].text
#   # p raw_data[8].text
#   # p raw_data[9].text
#   # raw_json = /\[{.*\}\]/.match(raw_data[3])[0]
#   # data = JSON.parse(raw_json, opts = {symbolize_names: true})
#   # p raw_json
#   # raw_data.each_with_index do |script, i|
#   #   p "//////////////////////////////////////////////"
#   #   p "                      #{i}                        "
#   #   p "//////////////////////////////////////////////"
#   #   p script
#   # end

#   #[3].text
#   # p raw_data[1]
#   # p raw_data[2]
#   # p raw_data[3]
#   # p "empty" if raw_data.empty?

#   # raw_json = /\[{.*\}\]/.match(raw_data)[0]
#   # p raw_json.class
#   # data = JSON.parse(raw_json, opts = {symbolize_names: true})
#   # return if data.empty?

#   # data.each do |json|
#   #   p json.keys
#   # end
# end

# scrapper_personal('/Psys/Brigitte-CHRETIENNE')

# scrapper_personal('/Psys/Marie-Madeleine-NICOLIER-GRENOTTON')
# p '//////////////////////////////////////////////////////'
# scrapper_personal('/Psys/Stephane-CHAUSSIN')
# p '//////////////////////////////////////////////////////'
# scrapper_personal('/Psys/Stephanie-Slama')
# p '//////////////////////////////////////////////////////'
# scrapper_personal('/Psys/Martine-LEFEVRE-NADAi')
# (1..15).each do |num|
#   scrapper_for_all(num)
# end
