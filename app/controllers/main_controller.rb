class MainController < ApplicationController
  def index
    @articles = $redis.srandmember('wikidata', 20)
    respond_to do |format|
      format.html
      format.json { render :json => @articles }
    end
  end
end
