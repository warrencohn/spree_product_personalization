module Spree
  Product.class_eval do
    has_one :product_personalization, :dependent => :destroy
    accepts_nested_attributes_for :product_personalization, :allow_destroy => true
    
  end
end
