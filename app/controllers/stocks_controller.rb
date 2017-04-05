class StocksController < ApplicationController
  
  def search
    if params[:stock]
      @stock = Stock.find_by_ticker(params[:stock])
      @stock ||= Stock.new_from_lookup(params[:stock])
    end
    
    if @stock
      #the below is a good way to see if functionality is working by going to the search_stocks path in the address bar and 
      #searching a stock i.e. search_stocks?stock="GOOG"
      #render json: @stock
      render partial: 'lookup'
    else
      render status: :not_found, nothing:true
    end
    
  end
  
end