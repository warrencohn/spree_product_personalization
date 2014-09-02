module Spree

  Order.class_eval do

    def line_item_personalization_attributes_match(line_item, options)
      lip = line_item.line_item_personalization
      if lip.nil?
        options.empty?
      else
        pp = line_item.product.product_personalization
        if pp
          options['name'] = pp.name
          calc = pp.calculator
          options['price'] = calc.preferred_amount
          options['currency'] = calc.preferred_currency
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
