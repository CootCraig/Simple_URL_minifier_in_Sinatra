require 'rubygems'
require 'dm-core'
require 'dm-migrations'

module UrlMinified

  CHARACTER_LIST = (('a'..'z').to_a + ('0'..'9').to_a + ['_']).inject('') { |a,x| a << x }
  
  def UrlMinified.increment_mini_token(mini_token='')
    case mini_token
    when nil,''
      return '' << CHARACTER_LIST[0]
    end
    (1..mini_token.length).each {|increment_pos|
      if mini_token[-increment_pos] == CHARACTER_LIST[-1]
        # set this to first character, increment the next
        mini_token[-increment_pos] = CHARACTER_LIST[0]
      else
        # increment this character and we're done
        next_index = CHARACTER_LIST.index(mini_token[-increment_pos]) + 1
        mini_token[-increment_pos] = CHARACTER_LIST[next_index]
        return mini_token
      end
    }
    # Add another character position
    CHARACTER_LIST[0,1] << mini_token
  end
  
  class UrlMiniToken
    include DataMapper::Resource
    property :miniToken, String, :key => true
    property :url, Text
    property :createdAt, DateTime
  end
  
  class NextMiniToken
    include DataMapper::Resource
    property :pid, Integer, :key => true
    property :nextKey, String
  end
  
  def UrlMinified.init
    DataMapper.setup(:default, 'sqlite3:db/my_db.db')
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end
  def UrlMinified.add(fullUrl)
    db_next_mini_token = NextMiniToken.first
    if db_next_mini_token
      mini_token = db_next_mini_token.nextKey
    else
      mini_token = increment_mini_token
      db_next_mini_token = NextMiniToken.new(:pid => 1, :nextKey => '')
    end
    next_mini_token = String.new(mini_token)
    increment_mini_token(next_mini_token)
    db_next_mini_token.nextKey = next_mini_token
    db_next_mini_token.save
    UrlMiniToken.new(:miniToken => mini_token, :url => fullUrl, :createdAt => Time.now).save
    mini_token
  end
  def UrlMinified.get(miniToken)
    r = UrlMiniToken.get(miniToken)
    r && r.url
  end
  def UrlMinified.all
    UrlMiniToken.all.inject({}) { |h,r| h[r.miniToken] = r.url; r }
  end
end
