#!/usr/bin/ruby -w
# encoding: utf-8

require 'net/http'
require 'json'
require 'date'

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

