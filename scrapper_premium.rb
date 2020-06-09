require 'nokogiri'
require 'open-uri'
require 'json'

# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
# ATTENTION LE SCRAPPER NE MARCHE QUE POUR LES PROFIL CERTIFIES (15 première pages)
# <<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<

def scrapper_premium(page_int)
  url = open("https://monpsy.psychologies.com/Psys?page=#{page_int}").read
  doc = Nokogiri::HTML(url)
  # raw_data = doc.search('.Search-list script').text
  raw_data = doc.search('.Search-list script').text

  raw_json = /\[{.*\}\]/.match(raw_data)[0]
  data = JSON.parse(raw_json, opts = {symbolize_names: true})
  # p data

  data.each do |element|
    puts "#{element[:salutation]} #{element[:firstname]} #{element[:lastname]} #{element[:mail]} #{element[:metiers]}"

  end
  # return result
end

(1..15).each do |num|
  scrapper_premium(num)
end
