require 'json'

filepath = 'psys.json'
serialized_psys = File.read(filepath)

psy_array = JSON.parse(serialized_psys)
p beers
