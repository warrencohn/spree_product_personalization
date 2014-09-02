module Spree
  module ProductPersonalizationDuplicator

    def duplicate_product_personalization(product)
      self.product_personalization = product.product_personalization.dup
      self.product_personalization.calculator = product.product_personalization.calculator.dup
    end

  end
end
