module Spree

  Order.class_eval do

    def personalization_attributes_match(line_item, options)
      lp = line_item.personalization
      if lp.nil?
        options.empty?
      else
        pp = line_item.product.personalization
        if pp
          options['name'] = pp.name
          calc = pp.calculator
          options['price'] = calc.preferred_amount
          options['currency'] = calc.preferred_currency
        end
        lp.match? options.with_indifferent_access
      end
    end

    def personalization_match(line_item, other_line_item)
      lp = line_item.personalization
      oli = other_line_item.personalization
      if lp.nil?
        olp.nil?
      else
        lp.match? olp
      end
    end

    self.register_line_item_comparison_hook(:personalization_match)

  end
end
