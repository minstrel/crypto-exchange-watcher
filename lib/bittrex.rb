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
  bittrex_data = JSON.parse(bittrex_res.body)['result']

  bittrex_data.collect! { |d| {marketname: d['MarketName'],
                               marketcurrencylong: d['MarketCurrencyLong'],
                               basecurrencylong: d['BaseCurrencyLong']} }
  bittrex_data
end

bittrex_old = get_bittrex
bittrex_new = []
bittrex_diff = []

puts "Bittrex init - got #{bittrex_old.length} results"

loop do
  begin
    bittrex_new = get_bittrex
    puts "Bittrex refresh #{bittrex_old.length} old vs #{bittrex_new.length} new. #{Time.now}"
    bittrex_diff = bittrex_new - bittrex_old
    if ! bittrex_diff.empty?
      bittrex_diff.each do |diff|
        puts "    !!!! Bittrex may have added or updated #{diff[:marketname]}, #{diff[:basecurrencylong]} => #{diff[:marketcurrencylong]}"
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

