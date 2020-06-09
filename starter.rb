require 'nokogiri'
require 'open-uri'
require_relative 'scrapper_personnal'
require_relative 'scrapper_list'
FILEPATH = 'psys.json'

def premium_test(page_int)
  data = []
  url = open("https://monpsy.psychologies.com/Psys?page=#{page_int}").read
  doc = Nokogiri::HTML(url)
  doc.search('.CardSearch').each do |card|
    psy_href = card.search('.CardSearch-name').attribute('href').value
    badge = card.search('.Btn' '.Btn--small' '.Btn--second' '.Btn--icon').text
    if badge.length.positive?
      personnal_hash = scrapper_personal(psy_href, card)
      # personnal_hash = scrapper_personal('/Psys/Stephane-CHAUSSIN', card)
      data << personnal_hash
    else
      data << list_scrapper(card)
    end
  end
  data.flatten
end

def save_json(array)
  serialized_psys = File.read(FILEPATH)
  psy_array = JSON.parse(serialized_psys)
  array.each { |psy_hash| psy_array << psy_hash }
  File.open(FILEPATH, 'w') do |file|
    file.write(JSON.generate(psy_array))
  end
end

def intro
  p ' please wait .... we are scrapping for you :)'
  p ' ============================================'
  p ''
  p ''
  p ''
  p '--------------------------- '
end

def outro(duration, counter, average)
  p ''
  p ''
  p ''
  p '/////////////////// FINISH! \\\\\\\\\\\\\\\\\\'
  p '|                  Success !                 |'
  p "|        total process done in : #{duration.round(1)}s.     |"
  p "|            #{counter} contacts added !            |"
  p "|      Average speed : #{average.round(2)}s / contact       |"
  p '/////////////////// FINISH! \\\\\\\\\\\\\\\\\\'
end

def collect_data(range, data)
  counter = 0
  range.each_with_index do |num, i|
    step = Time.now
    data = premium_test(num)
    counter += data.length
    save_json(data)
    status = 10 * ((i + 1) / range.size.to_f).round(2)
    print_status(data.length, step, status)
  end
  counter
end

def print_status(length, step, state)
  p " #{length} contacts added in: #{(Time.now - step).round(1)}s "
  p " #{(state * 10).to_i}\% [#{'#' * (state * 2)}#{' ' * (20 - (state * 2))}] "
  p '===========================  '
end

def start
  start_t = Time.now
  data = []
  File.open(FILEPATH, 'w') { |file| file.write(JSON.generate(data)) }
  intro
  page_range_to_scrap = (1..755)
  counter = collect_data(page_range_to_scrap, data)
  duration = Time.now - start_t
  average = duration / counter
  outro(duration, counter, average)
end

start
