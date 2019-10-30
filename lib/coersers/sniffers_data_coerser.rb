# frozen_string_literal: true

require_relative 'base_coerser'

class SniffersDataCoerser < BaseCoerser
  def run
    result = []
    @data['sequences'].each do |seq|
      next unless (route_node = @data['node_times'].find { |item| item[:node_time_id] == seq[:node_time_id] })

      start_time = (@data['routes'].find { |route| route[:route_id] == seq[:route_id] })[:time]
      result << { start_node: route_node[:start_node].strip,
                  end_node:   route_node[:end_node].strip,
                  start_time: start_time.iso8601.chop,
                  end_time:   Time.at(start_time.to_f + route_node[:duration_in_milliseconds] / 1000).utc.iso8601.chop }
    end
    result
  end
end
