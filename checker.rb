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

bittrex = Thread.new do
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

binance = Thread.new do
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
end

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

kucoin = Thread.new do
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
end

# HUOBI

puts "Initializing list for Huobi"

def get_huobi
  huobi_uri = URI('https://api.huobi.pro/v1/common/symbols')
  huobi_http = Net::HTTP.new(huobi_uri.host, huobi_uri.port)
  huobi_http.use_ssl = true
  
  huobi_req = Net::HTTP::Get.new(huobi_uri.path)
  huobi_req.content_type = 'application/json'
  huobi_res = huobi_http.request(huobi_req)
  huobi_data = JSON.parse(huobi_res.body)['data']

  huobi_data.collect! { |d| {base_currency: d['base-currency'], quote_currency: d['quote-currency']} }
  huobi_data
end

huobi_old = get_huobi
huobi_new = []
huobi_diff = []

puts "Huobi init - got #{huobi_old.length} results"

huobi = Thread.new do
  loop do
    begin
      huobi_new = get_huobi
      puts "Huobi refresh #{huobi_old.length} old vs #{huobi_new.length} new. #{Time.now}"
      huobi_diff = huobi_new - huobi_old
      if ! huobi_diff.empty?
        huobi_diff.each do |diff|
          puts "    !!!! Huobi may have added or updated #{diff[:base_currency]} => #{diff[:quote_currency]}"
        end
      end
      huobi_old = huobi_new
      sleep(120)
    rescue => e
      puts "Huobi failed with error: #{e}"
      puts "Waiting 240 and retrying"
      sleep(240)
      next
    end
  end
end

bittrex.join
binance.join
kucoin.join
huobi.join
