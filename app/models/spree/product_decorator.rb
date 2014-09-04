module Spree
  Product.class_eval do
    has_one :personalization, class_name: "Spree::ProductPersonalization", :dependent => :destroy
    accepts_nested_attributes_for :personalization, :allow_destroy => true
    
    def duplicate_extra(product)
      if product.personalization
        self.personalization = product.personalization.dup
        self.personalization.calculator = product.personalization.calculator.dup
        if product.personalization.calculator.respond_to?(:preferred_amount)
          self.personalization.calculator.preferred_amount = product.personalization.calculator.preferred_amount
        end
      end
    end
  end
end
