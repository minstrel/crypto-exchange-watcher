#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'

# BINANCE

puts "Initializing list for Binance"

def get_binance
  binance_uri = URI('https://api.binance.com/api/v1/exchangeInfo')
  binance_http = Net::HTTP.new(binance_uri.host, binance_uri.port)
  binance_http.use_ssl = true
  
  binance_req = Net::HTTP::Get.new(binance_uri.path)
  binance_req.content_type = 'application/json'
  binance_res = binance_http.request(binance_req)
  binance_data = JSON.parse(binance_res.body)['symbols']

  binance_data.collect! { |d| {symbol: d['symbol'],
                               base_asset: d['baseAsset'],
                               quote_asset: d['quoteAsset']} }
  binance_data
end

binance_old = get_binance
binance_new = []
binance_diff = []

puts "Binance init - got #{binance_old.length} results"

loop do
  begin
    binance_new = get_binance
    puts "Binance refresh #{binance_old.length} old vs #{binance_new.length} new. #{Time.now}"
    binance_diff = binance_new - binance_old
    if ! binance_diff.empty?
      binance_diff.each do |diff|
        puts "    !!!! Binance may have added or updated #{diff[:symbol]}, #{diff[:base_asset]} => #{diff[:quote_asset]}"
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

