class RankingController < ApplicationController

#    @items = Item.all.order("updated_at DESC").limit(10)
# やること：OwnerShipテーブルからHaveが入っているもので多い順に並べる。
#　できていないこと。Has_many系のアソシエーションからデータを引っ張ってくる。

  def have
   # @haves = @user.have_items #あるユーザーの持っているItem一覧
  #     @items = Have.group(:item_id)
 #  @haves = Have.all.pluck(:item_id)
 # これ配列。
 
   @have_all = Have.group(:item_id).order("count_item_id DESC").limit(10).count(:item_id).keys
   @items = Item.find(@have_all).sort_by{|o| @have_all.index(o.id)}

#全てのユーザーの持っているItem一覧
  end


  def want
   @want_all = Want.group(:item_id).order("count_item_id DESC").limit(10).count(:item_id).keys
   @items = Item.find(@want_all).sort_by{|o| @want_all.index(o.id)}
  end
end

