# encoding: UTF-8
require 'cinch'
require 'cinch/plugins/login'
require 'nokogiri'
require 'open-uri'

Cinch::Bot.new {
  configure do |c|
   c.nick = 'Gesualdo'
   c.realname = c.nick 
   c.user = c.nick
   c.password = 'PASSWORD'
   c.plugins.plugins = [Cinch::Plugins::Login]
   c.plugins.options[Cinch::Plugins::Login] = { :password => 'PASSWORD' }
   c.server = "SERVER"
   c.channels = ["#CHANNEL"]
end

   on :message, /^http(s)?\:\/\/(www)?\.youtube\.com\/(.*)$/ do |m, ssl, www, url|
     page = Nokogiri::HTML(open("http://www.youtube.com/#{url}").read, nil, 'utf-8')
     m.reply  Format(:green, page.css('//title').first.text.chomp(' - YouTube'))
   end
 
   on :message, /.*Gesualdo.*/ do |m|
     m.reply "Le porgo i miei saluti, messer #{m.user.nick}"
   end

   on :message, /.*ALL'ATTACCO!.*/ do |m|
     m.reply "#{m.user.nick}, ALLA PUGNA!"
   end
}.start

