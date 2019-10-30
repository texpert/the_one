# frozen_string_literal: true

require_relative 'base_coerser'

class LoopholesDataCoerser < BaseCoerser
  def run
    result = []
    node_pairs = @data.dig('node_pairs', 'node_pairs')
    @data.dig('routes', 'routes').each do |route|
      route_node_pair = node_pairs.find { |item| item['id'] == route['node_pair_id'] }
      next unless route_node_pair

      result << { start_node: route_node_pair['start_node'],
                  end_node:   route_node_pair['end_node'],
                  start_time: DateTime.parse(route['start_time']).to_time.utc.iso8601.chop,
                  end_time:   DateTime.parse(route['end_time']).to_time.utc.iso8601.chop }
    end
    result
  end
end
