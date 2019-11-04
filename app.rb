#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/the_one'

$LOAD_PATH.unshift File.expand_path('../lib/', __dir__)
Dir['./lib/*/**'].each { |file| require file }

TheOne.run
