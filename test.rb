require 'UrlMinified.rb'
UrlMinified.init
if false
  ['a/b','c/d','e/f'].each {|url|
    x = UrlMinified.add(url)
    puts "#{x} -> url: #{url}"
  }
end
['a','b','c','zzz'].each {|token|
  url = UrlMinified.get(token)
  puts "lookup #{token} get #{url}"
}
