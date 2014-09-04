module Spree
  Product.class_eval do
    has_one :product_personalization, :dependent => :destroy
    accepts_nested_attributes_for :product_personalization, :allow_destroy => true
    
    def duplicate_extra(product)
      if product.product_personalization
        self.product_personalization = product.product_personalization.dup
        self.product_personalization.calculator = product.product_personalization.calculator.dup
        if product.product_personalization.calculator.respond_to?(:preferred_amount)
          self.product_personalization.calculator.preferred_amount = product.product_personalization.calculator.preferred_amount
        end
      end
    end
  end
end
