#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'

# BITTREX

puts "Initializing list for Bittrex"

def get_bittrex
  bittrex_uri = URI('https://bittrex.com/api/v1.1/public/getmarkets')
  bittrex_http = Net::HTTP.new(bittrex_uri.host, bittrex_uri.port)
  bittrex_http.use_ssl = true
  
  bittrex_req = Net::HTTP::Get.new(bittrex_uri.path)
  bittrex_req.content_type = 'application/json'
  bittrex_res = bittrex_http.request(bittrex_req)
  JSON.parse(bittrex_res.body)['result']
end

bittrex_old = get_bittrex
bittrex_new = []
bittrex_diff = []

puts "Bittrex init - got #{bittrex_old.length} results"

bittrex = Thread.new do
  loop do
    begin
      bittrex_new = get_bittrex
      puts "Bittrex refresh #{bittrex_old.length} old vs #{bittrex_new.length} new. #{Time.now}"
      bittrex_diff = bittrex_new - bittrex_old
      if ! bittrex_diff.empty?
        bittrex_diff.each do |diff|
          puts "Bittrex may have added #{diff['MarketName']}, #{diff['BaseCurrencyLong']} => #{diff['MarketCurrencyLong']}"
        end
      end
      bittrex_old = bittrex_new
      sleep(120)
    rescue => e
      puts "Bittrex failed with error: #{e}"
      puts "Waiting 240 and retrying"
      sleep(240)
      next
    end
  end
end

# BINANCE

puts "Initializing list for Binance"

def get_binance
  binance_uri = URI('https://api.binance.com/api/v1/exchangeInfo')
  binance_http = Net::HTTP.new(binance_uri.host, binance_uri.port)
  binance_http.use_ssl = true
  
  binance_req = Net::HTTP::Get.new(binance_uri.path)
  binance_req.content_type = 'application/json'
  binance_res = binance_http.request(binance_req)
  JSON.parse(binance_res.body)['symbols']
end

binance_old = get_binance
binance_new = []
binance_diff = []

puts "Binance init - got #{binance_old.length} results"

binance = Thread.new do
  loop do
    begin
      binance_new = get_binance
      puts "Binance refresh #{binance_old.length} old vs #{binance_new.length} new. #{Time.now}"
      binance_diff = binance_new - binance_old
      if ! binance_diff.empty?
        binance_diff.each do |diff|
          puts "Binance may have added #{diff['symbol']}, #{diff['baseAsset']} => #{diff['quoteAsset']}"
        end
      end
      binance_old = binance_new
      sleep(180)
    rescue => e
      puts "Binance failed with error: #{e}"
      puts "Waiting 240 and retrying"
      sleep(240)
      next
    end
  end
end

bittrex.join
binance.join
