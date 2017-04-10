class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
         
  has_many :user_stocks
  has_many :stocks, through: :user_stocks
  has_many :friendships
  has_many :friends, through: :friendships
  
  def full_name
    return "#{first_name} #{last_name}".strip if (first_name || last_name)
    # if theres not a first name or last name then return...
    "Anonymous"
  end
  
  def can_add_stock?(ticker_symbol)
    under_stock_limit? && !stock_already_added?(ticker_symbol)
  end
  
  def under_stock_limit?
    (user_stocks.count < 10)
  end
  
  def stock_already_added?(ticker_symbol)
    stock = Stock.find_by_ticker(ticker_symbol)
    return false unless stock
    user_stocks.where(stock_id: stock.id).exists?
  end
  
  #so here we pass a friend id to the method. the friend_id: refers to the heading in our friendships table.
  #so this is essentially saying - if the friend is is not in the friendships table, friend_id column 
  #then we're not friends with this user!
  def not_friends_with?(friend_id)
    friendships.where(friend_id: friend_id).count < 1
  end
  
  # this loops through and 'rejects' the user id that matches our self.id - i.e. the id of the current logged in user.
  # i.e. the caller of the method (the current user) is rejected as we don't want to return ourselves in asearch
  def except_current_user(users)
    users.reject {|user| user.id == self.id}
  end
  
  def self.search(param)
    return User.none if param.blank?
    
    param.strip!
    param.downcase!
    
    # so rather than having a huge method we can outsource (extract) this away to other methods we define - the ..._matches
    # ones below!
    (first_name_matches(param) + last_name_matches(param) + email_matches(param)).uniq
  end

  def self.first_name_matches(param)
    matches('first_name', param)
  end
  
  def self.last_name_matches(param)
    matches('last_name', param)
  end
  
  def self.email_matches(param)
    matches('email', param)
  end
  
  # Now we define the matches method that is used by all three of the methods below. 
  def self.matches(field_name, param)
    where("lower(#{field_name}) like ?", "%#{param}%")
  end
 
end
