require 'rubygems'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'mongo_mapper'
require 'json/ext'
require 'log_buddy'
require 'haml'
require 'coffee-script'
require "rdiscount"
require File.join(File.dirname(__FILE__),'/config/db')
require File.join(File.dirname(__FILE__),'/model/models')

def stats(str)
  query = Query.where(:name => str).first
  if query.nil?
    Query.new(:name => str, :count => 1).save
  else
    query.count += 1 
    query.save 
  end
end

set :markdown, :layout_engine => :haml, :layout => :layout

get '/' do
  @title = "Главная"
  query = Query.first(:order => :updated_at.desc)
  if query.nil?
    @query = ""
  else
    @query = query.name
  end
  haml :index
end

get '/contact' do
  @title = "Контакты"
  haml :contact
end

get '/about' do
  @title = "О проекте"
  markdown :about
end

get '/api' do
  @title = "Api для сторонних приложений"
  markdown :api
end

get '/cli' do
  @title = "CLI - Поиск запчастей из командной строки osx/linux"
  haml :cli
end

get '/price' do
  @title = "Прайслист в онлайн"
  haml :price
end

get '/download_price' do
  @title = "Скачать прайслист в формате xls"
  haml :download_price
end

get '/js/main.js' do
  coffee :main
end

#REST API ;)
#all/last prises in base
get '/api/upd/:str' do
  if    params[:str] == "all"
    result = Price.all(:order => :date.asc)
  elsif params[:str] == "last"
    result = [Price.last(:order => :date.asc)]
  else 
    result = false
  end
  
  content_type :json
  if result
    {:status => :success, :result => result}.to_json
  else
    {:status => :error, :result => "Params only 2 variables(all, last)!"}.to_json
  end
end

#no params
get '/api/categories' do
  result = Category.all
  content_type :json
  {:status => :success, :result => result}.to_json
end

# paginate products in category
get '/api/products/:id/:page' do
  content_type :json
  if params[:id].to_s.size == 24
    category = Category.find(params[:id].to_s)
    if category.nil?
      {:status => :error, :result => "No found category id."}.to_json
    else
      count    = category.products.count
      per_page = 100
      pages    = count / per_page 
      pages   +=1 if count % per_page.nonzero?
      
      if pages >= params[:page].to_i
        result   = category.products.paginate({
          :order    => :name.asc,
          :per_page => per_page, 
          :page     => params[:page].to_i,
        })

        {:status => :success, :count=> count, :pages => pages, :result => result}.to_json
      else
        {:status => :error, :result => "Paginate page out of rane."}.to_json
      end
    end
  else
    {:status => :error, :result => "No valid category id."}.to_json
  end
end

# search
get '/api/search/:query/:page' do
  content_type :json
  query    = params[:query]
  products = Product.where(:name => /#{query}/i)

  if products.count == 0
    {:status => :error, :result => "Products not found."}.to_json
  else
    stats(query) if 1 == params[:page].to_i
    #
    count    = products.count
    per_page = 25
    pages    = count / per_page 
    pages   += 1 if count % per_page.nonzero?
    #
    if pages >= params[:page].to_i
      result = products.paginate({
        :order    => [:last_upd.desc, :category_id.asc],
        :per_page => per_page, 
        :page     => params[:page].to_i,
          })
      {:status => :success, :count=> count, :pages => pages, :result => result}.to_json
    else
      {:status => :error, :result => "Paginate page out of rane."}.to_json
    end
  end
end

#text_search
get '/api/text_search/:query' do
  content_type :text
  query  = params[:query]
  if query.size < 3
    "Query minimum 3 symbols"
  else
    lastupd  = Price.last(:order => :date.asc)
    products = Product.where(:name => /#{query}/i, :last_upd_id => lastupd.id.to_s).all(:limit => 10)
    unless products.empty?
      array    = products.map { |e| [e.sku.to_s, e.name.to_s, e.prices[lastupd.id.to_s]['retail'].to_s ] }
      result   = []
      array.each do |i|
        #row1
        row1 = 8-i[0].size
        i[0] += (1..row1).to_a.map{" "}.join
        #row2
        if i[1].size < 58
        row2 = 58-i[1].size
        i[1] += (1..row2).to_a.map{" "}.join
        else
          i[1] = i[1][0,58]
        end
        #row3
        row3 = 9-i[2].size
        i[2] += (1..row3).to_a.map{" "}.join

        result << "║#{i[0]}║#{i[1]}║#{i[2]}║"
      end

      head = [
        " Search - #{params[:query]}",
        "╔════════╦══════════════════════════════════════════════════════════╦═════════╗",
        "║   id   ║                          name                            ║  price  ║",
        "╠════════╬══════════════════════════════════════════════════════════╬═════════╣",
        result,
        "╚════════╩══════════════════════════════════════════════════════════╩═════════╝",
        ""
      ].join("\n")
    else
      head = "No find - #{params[:query]}"
    end
    head
  end
end
#text_clear_query
get '/api/text_search/' do
  content_type :text
  "rm35 <query>"
end








