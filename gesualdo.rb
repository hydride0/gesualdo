# encoding: UTF-8
require 'cinch'
require 'cinch/plugins/login'
require 'nokogiri'
require 'open-uri'

bot = Cinch::Bot.new do
  configure do |c|
    c.nick = 'Gesualdo'
    c.realname = c.nick
    c.user = c.nick
    c.password = 'BOTSPASS'
    c.plugins.plugins = [Cinch::Plugins::Login]
    c.plugins.options[Cinch::Plugins::Login] = { :password => 'BOTSPASS' }
    c.server = "YOURIRCSERVER"
    c.channels = ["#YOUIRCCHAN"]
  end

  @poll = nil
  @poll_owner = ''
  reply = [].tap { |ary| File.read('reply.txt').each_line { |line| ary << line } }
  proverbio = [].tap { |ary| File.read('proverbi.txt').each_line { |line| ary << line } }

  on :message, /http(s)?:\/\/(\S+)/ do |m, ssl, url|
     page = Nokogiri::HTML(open("http#{ssl}://#{url}").read, nil, 'utf-8')
     if url.include? ( 'youtube.com' || 'youtu.be' )
      m.reply Format(:lime,  page.css('//title').first.text.chomp(' - YouTube'))
     else
       m.reply Format(:teal, page.css('//title').first.text)
     end
   end

  on :message, /^!poll ([^;]+);([^\/]+)\/(.+)$/ do  |m, topic, opt_a, opt_b|
    if @poll != nil
      m.reply Format(:red, 'A poll is currently in progress')
    elsif @poll == nil && (opt_a.downcase != opt_b.downcase)
      m.reply "Poll '#{topic}' started by #{m.user.nick}, vote with '!pvote #{opt_a}' or '!pvote #{opt_b}'. Stop the poll with '!pstop'."
      @poll_owner = m.user.nick
      @poll = 1
      @glob_a = opt_a
      @gl_b = opt_b
      @a_count = 0
      @b_count = 0
      @who_vote = []
    else
      m.reply 'Error: control the syntax and don\'t be an asshole.'
    end
  end

  on :message, /^!pvote (\S+)$/ do |m, vote|
    if vote == @glob_a && !@who_vote.include?(m.user.nick)
      @a_count += 1
      @who_vote <<  m.user.nick
    elsif vote == @glob_b && !@who_vote.include?(m.user.nick)
      @b_count += 1
      @who_vote << m.user.nick
    else
      m.reply 'Invalid vote.'
    end
  end

  on :message, /^!pstop$/ do |m|
    partic = @a_count + @b_count
    if @poll != nil && (m.user.nick == 'YOURNICKNAME' || m.user.nick == @poll_owner)
        m.reply 'Poll is ended'
        m.reply "#{partic} user(s) voted, #{@a_count} voted '#{@glob_a}' and #{@b_count} voted '#{@glob_b}'"
        @poll = nil
    elsif m.user.nick != 'YOURNICKNAME' || m.user.nick != @poll_owner
        m.reply 'Command denied.'
    else
        m.reply 'No poll in progress'
    end
  end

  on :message, /^!prov$/ do |m|
    m.reply proverbio[rand(1..369)]
  end

  on :message, /^!phelp$/ do |m|
    m.reply 'Use !poll ARG;ARG/ARG to start a poll, !pvote ARG to vote and !pstop to stop the poll.'
  end

  on :message, /^!qu1t$/ do |m|
    if m.user.nick == 'YOURNICKNAME'
      bot.quit
    else
      m.reply 'GTFO && ESAD, bitch'
    end
  end

  on :message, /Gesualdo.*\?/ do |m|
    m.reply reply[rand(1..26)]
  end
end
bot.start

