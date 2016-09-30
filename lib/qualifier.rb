require 'HTTParty'
require 'Nokogiri'
require 'JSON'
require 'csv'



def qualify_page(website)
@goodfit = nil
@badfit = nil
page = HTTParty.get(website)
@page = Nokogiri::HTML(page)
built_with
what_scripts
user_system
puts 'GOOD FIT!' if @goodfit
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
string = header.to_s
if string.include?('wp-content')
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
end
