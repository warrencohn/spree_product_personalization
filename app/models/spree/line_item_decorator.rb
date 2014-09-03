module Spree
  PermittedAttributes.module_eval do
    mattr_writer :line_item_attributes
  end

  unless PermittedAttributes.line_item_attributes.include? :line_item_personalization_attributes
    PermittedAttributes.line_item_attributes += [line_item_personalization_attributes: LineItemPersonalization.permitted_attributes] 
  end

  LineItem.class_eval do
    has_one :line_item_personalization, :dependent => :destroy
    accepts_nested_attributes_for :line_item_personalization, :allow_destroy => true

    before_validation :copy_personalization, :on => :create, :if => -> { self.line_item_personalization }

    private

    def copy_personalization
      pp = self.product.product_personalization
      lip = self.line_item_personalization
      lip.line_item = self
      if pp
        lip.name = pp.name
        calc = pp.calculator
        lip.price = calc.preferred_amount
        lip.currency = calc.preferred_currency
      end
    end

  end
end
