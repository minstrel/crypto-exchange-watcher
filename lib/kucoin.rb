#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'

# KUCOIN

puts "Initializing list for Kucoin"

def get_kucoin
  kucoin_uri = URI('https://api.kucoin.com/v1/market/open/symbols')
  kucoin_http = Net::HTTP.new(kucoin_uri.host, kucoin_uri.port)
  kucoin_http.use_ssl = true
  
  kucoin_req = Net::HTTP::Get.new(kucoin_uri.path)
  kucoin_req.content_type = 'application/json'
  kucoin_res = kucoin_http.request(kucoin_req)
  kucoin_data = JSON.parse(kucoin_res.body)['data']

  kucoin_data.collect! { |d| {symbol: d['symbol'], coinType: d['coinType'], coinTypePair: d['coinTypePair']} }
  kucoin_data
end

kucoin_old = get_kucoin
kucoin_new = []
kucoin_diff = []

puts "Kucoin init - got #{kucoin_old.length} results"

loop do
  begin
    kucoin_new = get_kucoin
    puts "Kucoin refresh #{kucoin_old.length} old vs #{kucoin_new.length} new. #{Time.now}"
    kucoin_diff = kucoin_new - kucoin_old
    if ! kucoin_diff.empty?
      kucoin_diff.each do |diff|
        puts "    !!!! Kucoin may have added or updated #{diff[:symbol]}, #{diff[:coinType]} => #{diff[:coinTypePair]}"
      end
    end
    kucoin_old = kucoin_new
    sleep(120)
  rescue => e
    puts "Kucoin failed with error: #{e}"
    puts "Waiting 240 and retrying"
    sleep(240)
    next
  end
end

