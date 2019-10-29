# frozen_string_literal: true

require_relative 'base_coerser'

class SentinelsDataCoerser < BaseCoerser
  def run
    sorted_data = @data['routes'].sort_by { |r| [r[:route_id], r[:time]] }
    result = []
    sorted_data.each_with_index do |entry, i|
      node = entry[:node].strip
      next unless NODES.include?(node)

      route_id = entry[:route_id]
      previous_route_id = sorted_data[i - 1][:route_id]
      next_route_id = sorted_data[i + 1][:route_id]
      if route_id != previous_route_id && route_id == next_route_id
        result << { start_node: node, start_time: entry[:time] }
      elsif route_id == previous_route_id
        result.last.merge!(end_node: node, end_time: entry[:time])
        result << { start_node: node, start_time: entry[:time] } if route_id == next_route_id
      end
    end
    result
  end
end
