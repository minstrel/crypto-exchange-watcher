#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'
#require_relative 'lib/binance'
#require_relative 'lib/bittrex'
#require_relative 'lib/huobi'
#require_relative 'lib/kucoin'

exchanges = ['binance',
             'bittrex',
             'huobi',
             'kucoin']

threads = []

exchanges.each do |ex|
  threads << Thread.new do
    require_relative "lib/#{ex}"
  end
end

threads.each { |t| t.join }
