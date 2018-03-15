#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'

# OKEX

puts "Initializing list for Okex"

def get_okex
  okex_uri = URI('https://www.okex.com/v2/markets/products')
  okex_http = Net::HTTP.new(okex_uri.host, okex_uri.port)
  okex_http.use_ssl = true
  
  okex_req = Net::HTTP::Get.new(okex_uri.path)
  okex_req.content_type = 'application/json'
  okex_res = okex_http.request(okex_req)
  okex_data = JSON.parse(okex_res.body)['data']

  okex_data.collect! { |d| {symbol: d['symbol']} }
  okex_data
end

okex_old = get_okex
okex_new = []
okex_diff = []

puts "Okex init - got #{okex_old.length} results"

loop do
  begin
    okex_new = get_okex
    puts "Okex refresh #{okex_old.length} old vs #{okex_new.length} new. #{Time.now}"
    okex_diff = okex_new - okex_old
    if ! okex_diff.empty?
      okex_diff.each do |diff|
        puts "    !!!! Okex may have added or updated #{diff[:symbol]}"
      end
    end
    okex_old = okex_new
    sleep(120)
  rescue => e
    puts "Okex failed with error: #{e}"
    puts "Waiting 240 and retrying"
    sleep(240)
    next
  end
end

