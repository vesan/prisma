#!/usr/bin/env ruby
require 'logger'

$LOAD_PATH.unshift ::File.expand_path(::File.dirname(__FILE__) + '/lib')
require 'prisma/server'

use Rack::ShowExceptions
run Prisma::Server.new
