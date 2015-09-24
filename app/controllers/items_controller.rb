class ItemsController < ApplicationController
  before_action :logged_in_user , except: [:show]
  before_action :set_item, only: [:show]

#検索画面から検索された時に呼び出される
  def new
    if params[:q]
      response = Amazon::Ecs.item_search(params[:q] , 
                                  :search_index => 'All' , 
                                  :response_group => 'Medium' , 
                                  :country => 'jp')
      @amazon_items = response.items

      
#このページ（メソッド）は検索して、その結果を@amazon_itemsに入れるだけ @amazon_itemsはではどうなるの？？基本的にその次の遷移先はまたこのサイト
    end
  end

### http://doruby.kbmj.com/x5r_on_rails/20080121/Rails_Amazon_API_ このやり方ができるかも。

  def show
  end

  private
  def set_item
    @item = Item.find(params[:id])
  end
end
