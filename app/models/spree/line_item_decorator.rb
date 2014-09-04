module Spree
  PermittedAttributes.module_eval do
    mattr_writer :line_item_attributes
  end

  unless PermittedAttributes.line_item_attributes.include? :personalization_attributes
    PermittedAttributes.line_item_attributes += [personalization_attributes: LineItemPersonalization.permitted_attributes] 
  end

  LineItem.class_eval do
    has_one :personalization, class_name: "Spree::LineItemPersonalization", :dependent => :destroy
    accepts_nested_attributes_for :personalization, :allow_destroy => true

    before_validation :copy_personalization, :on => :create, :if => -> { self.personalization }

    private

    def copy_personalization
      pp = self.product.personalization
      lp = self.personalization
      lp.line_item = self
      if pp
        lp.name = pp.name
        calc = pp.calculator
        lp.price = calc.preferred_amount
        lp.currency = calc.preferred_currency
      end
    end

  end
end
