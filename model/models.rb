class Category
  include MongoMapper::Document
  key  :name,      String
  key  :about,     String
  
  many :products  
end

class Product
  include MongoMapper::Document
  key :sku,         Integer, :index => true, :unique => true
  key :name,        String,  :index => true
  key :about,       String,  :index => true
  key :last_upd,    Date
  key :last_upd_id, String
  key :img,         String
  key :prices,      Hash
  
  belongs_to :category
end

class Price
  include MongoMapper::Document
  key :path, String
  key :date, Date
end

class Query
  include MongoMapper::Document
  key :name,  String, :index => true, :unique => true
  key :count, Integer
  timestamps!
end