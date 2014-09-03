module Spree
  module ProductPersonalizationDuplicator

    def duplicate_product_personalization(product)
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
