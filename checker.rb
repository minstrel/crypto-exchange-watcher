#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'

exchanges = ['binance',
             'bittrex',
             'huobi',
             'kucoin',
             'bitfinex']

threads = []

exchanges.each do |ex|
  threads << Thread.new do
    require_relative "lib/#{ex}"
  end
end

threads.each { |t| t.join }
