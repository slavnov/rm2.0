require 'mongo_mapper'
require 'json/ext'
require 'log_buddy'
require 'roo'
require './config/db'
require './model/models'


def start_line
  i=1
  until @oo.cell(i, "A") == "Код"
    i+=1    
  end
  i+1
end

def add_category(int)
  if @oo.cell(int, "A").nil? && @oo.celltype(int, "C") == :string
    @category = Category.where(:name => @oo.cell(int, "C")).first
    if @category.nil?
      @category = Category.new(name: @oo.cell(int, "C"))
      @category.save
    end
    true
  else
    false
  end
end

def add_product(date, int)
  product = Product.where(:sku => @oo.cell(int, "A")).first
  hash={}
  hash[@price.id.to_s] = {
    :retail            => @oo.cell(int, "D").nil? ? " " : @oo.cell(int, "D"),
    :regular           => @oo.cell(int, "E").nil? ? " " : @oo.cell(int, "E"),
    :small_wholesale   => @oo.cell(int, "F").nil? ? " " : @oo.cell(int, "F"),
    :wholesale         => @oo.cell(int, "G").nil? ? " " : @oo.cell(int, "G"),
    :wholesale_3psc    => @oo.cell(int, "H").nil? ? " " : @oo.cell(int, "H"),
    :wholesale_5psc    => @oo.cell(int, "I").nil? ? " " : @oo.cell(int, "I"),
    :wholesale_10psc   => @oo.cell(int, "J").nil? ? " " : @oo.cell(int, "J"),
    :wholesale_100psc  => @oo.cell(int, "K").nil? ? " " : @oo.cell(int, "K"),
    :wholesale_1000psc => @oo.cell(int, "L").nil? ? " " : @oo.cell(int, "L"),
  }

  if product.nil?
    product = Product.new(sku: @oo.cell(int, "A"), name: @oo.cell(int, "C"), about: @oo.cell(int, "M"), prices: hash, last_upd: date, last_upd_id: @price.id.to_s)
    @category.products << product
    product.save
  else
    product.prices.merge!(hash)
    product.last_upd    = date
    product.last_upd_id = @price.id.to_s
    product.save
  end
end

desc "XLS Parse"
task :default do

  puts "yay!"
  prices = Dir["public/xls/*"].map {|i| [Date.parse(i.gsub(/(public\/xls\/|\.xls)/i,'')) ,i]}
  prices.each do |price|
    #o_o
    @price = Price.where(:date => Date.to_mongo(price[0])).first
    if @price.nil?
      @price = Price.new(date: price[0], path: price[1].gsub('public/',''))
      @price.save
      @oo=Roo::Excel.new(price[1])
      puts price[1]
      start_line.upto(@oo.last_row) do |i|
        a=add_category(i)
        unless a
          add_product(price[0], i)
        end
      end
      
    else
      puts "dub"
    end
  end
end

task :clear do
  puts "DB clear"
  Product.destroy_all
  Category.destroy_all
  Price.destroy_all  
end