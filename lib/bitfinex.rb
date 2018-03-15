#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'

# BITFINEX

puts "Initializing list for Bitfinex"

def get_bitfinex
  bitfinex_uri = URI('https://api.bitfinex.com/v1/symbols_details')
  bitfinex_http = Net::HTTP.new(bitfinex_uri.host, bitfinex_uri.port)
  bitfinex_http.use_ssl = true
  
  bitfinex_req = Net::HTTP::Get.new(bitfinex_uri.path)
  bitfinex_req.content_type = 'application/json'
  bitfinex_res = bitfinex_http.request(bitfinex_req)
  bitfinex_data = JSON.parse(bitfinex_res.body)

  bitfinex_data.collect! { |d| { pair: d['pair'] } }
  bitfinex_data
end

bitfinex_old = get_bitfinex
bitfinex_new = []
bitfinex_diff = []

puts "Bitfinex init - got #{bitfinex_old.length} results"

loop do
  begin
    bitfinex_new = get_bitfinex
    puts "Bitfinex refresh #{bitfinex_old.length} old vs #{bitfinex_new.length} new. #{Time.now}"
    bitfinex_diff = bitfinex_new - bitfinex_old
    if ! bitfinex_diff.empty?
      bitfinex_diff.each do |diff|
        puts "    !!!! Bitfinex may have added or updated #{diff[:pair]}"
      end
    end
    bitfinex_old = bitfinex_new
    sleep(120)
  rescue => e
    puts "Bitfinex failed with error: #{e}"
    puts "Waiting 240 and retrying"
    sleep(240)
    next
  end
end

