# frozen_string_literal: true

require 'csv'
require 'httpx'
require 'zip'

class TheOne
  BASE_URI = 'https://challenge.distribusion.com/the_one/routes'
  SOURCES = %w[sentinels sniffers loopholes].freeze

  def self.run(http_client: HTTPX.headers('accept' => 'application/json'))
    new(client: http_client).run
  end

  def initialize(client:)
    @client = client
    @original_csv_converter = CSV::Converters
  end

  def run
    override_csv_converters

    SOURCES.each do |res|
      instance_variable_set(:"@#{res}", received_data: fetch_resource(@client, res))
      puts "\n#{res} = "
      pp instance_variable_get(:"@#{res}")
      data = Object.const_get("#{res.capitalize}DataCoerser").run(instance_variable_get(:"@#{res}")[:received_data])
      data
    end
  ensure
    CSV::Converters[:date_time] = @original_csv_converter[:date_time]
  end

  private

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
    parsed_entry = parser.parse(entry_data, headers: true, converters: :all, header_converters: :symbol)
    return parsed_entry.map(&:to_h) if parser == CSV

    parsed_entry
  end

  def override_csv_converters
    CSV::Converters[:date_time] = lambda { |f|
      begin
        e = f.encode(CSV::ConverterEncoding)
        DateTime.parse(e).to_time.utc
      rescue  # encoding conversion or date parse errors
        f
      end
    }
  end
end
