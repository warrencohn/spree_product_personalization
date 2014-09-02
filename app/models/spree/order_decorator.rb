module Spree

  Order.class_eval do

    def line_item_personalization_attributes_match(line_item, options)
      lip = line_item.line_item_personalization
      if lip.nil?
        options.empty?
      else
        calculator = line_item.product.product_personalization.try(:calculator)
        if calculator
          options['price'] = calculator.preferred_amount
          options['currency'] = calculator.preferred_currency
        end
        lip.match? options.with_indifferent_access
      end
    end

    def line_item_personalization_match(line_item, other_line_item)
      lip = line_item.line_item_personalization
      olip = other_line_item.line_item_personalization
      if lip.nil?
        olip.nil?
      else
        lip.match? olip
      end
    end

    self.register_line_item_comparison_hook(:line_item_personalization_match)

  end
end
