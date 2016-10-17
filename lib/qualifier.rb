require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'csv'
require './lib/driver'

class Qualifier

USER_SYSTEM = %w(sign\ in log\ in LOGIN log_in Login sign\ up register Sign\ In Sign\ Up Log\ in Sign\ in Log\ In)

def initialize(website)
    @website = website
end

def qualify
@user_sites = Driver.new(@website).find_sites
num = 0
while @user_sites == [] || @user_sites.nil?
p "#{num += 1}"
@user_sites = Driver.new(@website).find_sites
p @user_sites
end
end

def qualify_user_sites
@user_sites.each do |x|

begin
  response = HTTParty.get(x)
rescue SocketError => error
  puts x
  puts "Site does not load: {error}"
  puts "\n\n"
end
   if response
    puts x
    qualify_page(x)
    puts "\n\n"
   end
end
end

def qualify_page(website)
  @usersystem = false
  @goodfit = nil
  @badfit = nil
  page = HTTParty.get(website)
  @page = Nokogiri::HTML(page)
  login
  built_with
  what_scripts
  puts 'This site would be a good fit for a demo!' if @goodfit
  puts 'BAD FIT!' if @badfit
end

def header
  @page.xpath('//head')
end

def body
  @page.xpath('//body')
end

def html
  @page.xpath('//html')
end

def login
  USER_SYSTEM.each do |x|
    x = (@page.search "[text()*='"+x+"']")
   if x.to_s.strip.length == 0

   else
   @usersystem = x
   @goodfit = true
  end

end
 # (@usersystem = true) if @page.search "[text()*='"+x+"']"
 #  @goodfit = true
 #  print "This Site has a User System: matched word: " + x + "\n"  if @usersystem
 #  @usersystem = false
 if @usersystem
  print "This Site has a User System\n"
else
  print "This Site has no User System\n"
end

end

def what_scripts
  string = html.to_s
  print "GoSquared is on this page\n" if string.include?('_gs')
  print "Segment is on this page\n" if string.include?('analytics.track' || 'analytics.identify')
  print "Google Analytics is on this page\n" if string.include?('ga')
  print "Google Tag Manager is on this page\n" if string.include?('gtm.start')
  print "Intercom is on this page\n" if string.include?('intercomSettings')
end

def user_system
  string = body.to_s.downcase
  if string.include?('sign in' || 'my Account' || 'log in' || 'LOGIN' || '/log_in' || 'Login' || 'sign up' || 'log-in' || 'sign_in' || 'log_in'|| 'sign up')
    print "This Site has a User System\n"
    @goodfit = true
  else
    print "This Site has no User System\n"
  end
end

def built_with
  string = header.to_s.downcase
  if  @usersystem && string.include?('wp-content')
     print "This site is built with Wordpress but has a usersystem\n"
  elsif string.include?('wp-content')
    print "This site is built with Wordpress\n"
    @badfit = true
  end
  if string.include?('wix')
    print "This site is built with Wix\n"
    @badfit = true
  end
  if string.include?('squarespace')
    print "This site is built with SquareSpace\n"
    @badfit = true
  end
  if string.include?('rapidweaver')
    print "This site is built with Rapidweaver\n"
    @badfit = true
  end
end

end
