class OwnershipsController < ApplicationController
  before_action :logged_in_user

# 初期設定　これが2重になってしまった。。ドハマりの原因。
#Amazon::Ecs.options = {
#    :aWS_access_key_id  =>  ENV["AWS_ACCESS_KEY_ID"],
#    :aWS_secret_key =>  ENV["AWS_SECRET_KEY_ID"],
#    :country  => :jp,
#}

  def create
    if params[:asin]
      @item = Item.find_or_initialize_by(asin: params[:asin])
   #   @item = Item.find_or_create_by(asin: params[:asin])
   # find_or_create_byの場合は、asin: params[:asin]があれば、findされる。なければ、 params[:asin]が入った@itemがcreateされる。
   #つまりこのままでは、ASINのみが入ったデータができる。http://qiita.com/yusabana/items/1b566f61ca556a482f52
   # initializeの場合は、存在する場合は取得、しなければ新規作成(未保存)http://blog.hello-world.jp.net/ruby/1526/
   #if user.new_record? # 新規作成の場合は保存
    #user.save!
   # 新規作成時に行いたい処理を記述
   #end
   
    else
      @item = Item.find(params[:item_id])
    end
    # itemsテーブルに存在しない場合はAmazonのデータを登録する。

    if @item.new_record?
      begin 
      #
      #例外処理を書くには以下のように「begin 〜 rescue 〜 end」を使います。
      # begin
      #  ＜例外が起こる可能性のある処理＞
      # rescue => ＜例外オブジェクトが代入される変数＞
      #  ＜例外が起こった場合の処理＞
      # end
      #
        # TODO 商品情報の取得 Amazon::Ecs.item_lookupを用いてください
        # ARGV[0] 現在のスクリプトに渡されたすべての引数の配列が含まれますこの場合は、params[:asin]もしくは、params[:item_id])となるのかな。
#      response =  Amazon::Ecs.item_lookup(ARGV[0], { :response_group => 'Medium ,ItemAttributes , LargeImages ,DetailPageURL', :country => 'jp'}) 
      response = Amazon::Ecs.item_lookup(@item.asin, {:response_group =>'Medium, ItemAttributes, Images',:country =>'jp'}) 

      rescue Amazon::RequestError => e
        render :js => "alert('#{e.message}')"
      end
    
      amazon_item = response.items.first  
      # response.items のままではArray型で配列の状態なので first 等で１つを取り出してあげればgetで情報を取得できると思います
      # amazon_item get は amazon側のデータを取得するメソッドです
      # その必要な情報をamazonから取得して さいごに itemを保存しています
      #
    
      @item.title        = amazon_item.get('ItemAttributes/Title')
      @item.small_image  = amazon_item.get("SmallImage/URL")
      @item.medium_image = amazon_item.get("MediumImage/URL")
      @item.large_image  = amazon_item.get("LargeImage/URL")
      @item.detail_page_url = amazon_item.get("DetailPageURL")
      @item.raw_info        = amazon_item.get_hash
##      @item.save
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



