class Item < ActiveRecord::Base
  serialize :raw_info , Hash  #serializeは聞いたことない。
  validates :title,:detail_page_url, presence: true

  has_many :ownerships, foreign_key: "item_id", dependent: :destroy
  has_many :users, through: :ownerships
  #sourceが付かないのはなぜだろう。
  
  ### Want, Haveしているユーザーへの関連を実装 ###
  
  has_many :wants, class_name: "Want", foreign_key: "item_id", dependent: :destroy
  has_many :want_users , through: :wants, source: :user

  has_many :haves, class_name: "Have", foreign_key: "item_id", dependent: :destroy
  has_many :have_users , through: :haves, source: :user
  
  
end

