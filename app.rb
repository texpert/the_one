#!/usr/bin/env ruby
# frozen_string_literal: true

require 'csv'
require 'httpx'
require 'zip'

$LOAD_PATH.unshift File.expand_path('../lib/', __dir__)
Dir['./lib/*/**'].each { |file| require file }

RESOURCES = %w[sentinels sniffers loopholes].freeze
BASE_URI = 'https://challenge.distribusion.com/the_one/routes'
PASSPHRASE = 'Kans4s-i$-g01ng-by3-bye'

http = HTTPX.headers('accept' => 'application/json')

def fetch_resource(client, source)
  response = client.get(BASE_URI, params: { passphrase: PASSPHRASE, source: source })
  entries = {}
  Zip::File.open_buffer(StringIO.new(response.body)) do |entry_set|
    entry_set.each do |entry|
      entry_name = entry.name
      if entry_name.start_with?("#{source}/") && !File.extname(entry_name).empty?
        entries[File.basename(entry_name, File.extname(entry_name))] = parse_entry(entry)
      end
    end
  end
  entries
end

def parse_entry(entry)
  entry_data = entry.get_input_stream.read
  parser = Object.const_get(File.extname(entry.name).delete_prefix('.').upcase)
  entry_data.tr!('"', '') if parser == CSV
  parsed_entry = parser.parse(entry_data, headers: true)
  return parsed_entry.map(&:to_h) if parser == CSV

  parsed_entry
end

RESOURCES.each do |res|
  instance_variable_set(:"@#{res}", received_data: fetch_resource(http, res))
  puts "\n#{res} = "
  pp instance_variable_get(:"@#{res}")
  Object.const_get("#{res.capitalize}DataCoherser").run(instance_variable_get(:"@#{res}")[:received_data])
end
