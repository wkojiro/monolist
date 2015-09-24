class OwnershipsController < ApplicationController
  before_action :logged_in_user

# 初期設定
Amazon::Ecs.options = {
    :aWS_access_key_id  =>  ENV["AWS_ACCESS_KEY_ID"],
    :aWS_secret_key     =>  ENV["AWS_SECRET_KEY_ID"],
    :country            => :jp,
}

  def create
##このメソッドはWant/Haveの時に呼ばれる。
##このメソッドはASINがパラメータにのっていれば、そのパラメータでItemを探しなければ作る

    if params[:asin]
      @item = Item.find_or_create_by(asin: params[:asin])
    else
      @item = Item.find(params[:item_id])
    end
    
    if @item.new_record?  #新しいレコードかどうかチェックする
      begin
        # TODO 商品情報の取得 Amazon::Ecs.item_lookupを用いてください
        response =  Amazon::Ecs.item_lookup(ARGV[0], { :response_group => 'Medium' })
      rescue Amazon::RequestError => e
        return render :js => "alert('#{e.message}')"
      end
       
      amazon_item       = response.items.first  
      @item.title        = amazon_item.get('ItemAttributes/Title')
      @item.small_image  = amazon_item.get("SmallImage/URL")
      @item.medium_image = amazon_item.get("MediumImage/URL")
      @item.large_image  = amazon_item.get("LargeImage/URL")
      @item.detail_page_url = amazon_item.get("DetailPageURL")
      @item.raw_info        = amazon_item.get_hash
      @item.save!
      else
    puts("#{ARGV[0]}: products not found")
    end
     
    if params[:type] == "Have"
     current_user.have(@item)
    elsif params[:type] == "Want"
     current_user.want(@item)
    end
  end
    
    # TODO ユーザにwant or haveを設定する
    # params[:type]の値ににHaveボタンが押された時には「Have」,
    # Wantボタンがされた時には「Want」が設定されています。
  
    
  def destroy
    @item = Item.find(params[:item_id])
      # params[:type]の値ににHavedボタンが押された時には「Have」
    if params[:type] == "Have"
      current_user.unhave(@item)
    elsif params[:type] == "Want"
      current_user.unwant(@item)
    end
  
    # TODO 紐付けの解除。 
    # params[:type]の値ににHavedボタンが押された時には「Have」,
    # Wantedボタンがされた時には「Want」が設定されています。
    
  end
end


