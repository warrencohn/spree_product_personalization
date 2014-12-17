module Spree
  Product.class_eval do
    has_many :personalizations, class_name: "Spree::ProductPersonalization", :dependent => :destroy
    accepts_nested_attributes_for :personalizations, :allow_destroy => true

    def duplicate_extra(product)
      product.personalizations.each do |p|
        new_p = p.dup
        new_p.product = self
        new_p.calculator = p.calculator.dup
        new_p.calculator.preferred_amount = p.calculator.preferred_amount
        self.personalizations << new_p
      end
    end
  end
end
