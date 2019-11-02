#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/the_one'

$LOAD_PATH.unshift File.expand_path('../lib/', __dir__)
Dir['./lib/*/**'].each { |file| require file }

# TODO: This should be moved to an ENV variable
PASSPHRASE = 'Kans4s-i$-g01ng-by3-bye'

TheOne.run
