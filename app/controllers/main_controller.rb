class MainController < ApplicationController
  def index
    #if Rails.env == 'production'
    #  @articles = (1..20).map { |i| $redis.srandmember('wikidata') }
    #else
    #  @articles = $redis.srandmember('wikidata', 20)
    #end
    @articles = []
    $redis.pipelined do
      20.times do
        @articles.push $redis.srandmember('wikidata')
      end
    end
    @articles = @articles.map { |a| a.value }
    respond_to do |format|
      format.html
      format.json { render :json => @articles }
    end
  end
end
