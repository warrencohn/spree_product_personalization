module Spree
  PermittedAttributes.module_eval do
    mattr_writer :line_item_attributes
  end

  unless PermittedAttributes.line_item_attributes.include? :personalizations_attributes
    PermittedAttributes.line_item_attributes += [personalizations_attributes: LineItemPersonalization.permitted_attributes]
  end

  LineItem.class_eval do
    has_many :personalizations, class_name: "Spree::LineItemPersonalization", :dependent => :destroy
    accepts_nested_attributes_for :personalizations, :allow_destroy => true

    before_validation :copy_personalizations, :on => :create, :if => -> { self.personalizations.present? }


    def personalizations_match_with?(other_line_item_or_personalizations_attributes)
      if other_line_item_or_personalizations_attributes.kind_of? LineItem
        personalizations_attributes = other_line_item_or_personalizations_attributes.personalizations.map(&:attributes)
      elsif other_line_item_or_personalizations_attributes.kind_of? Hash
        personalizations_attributes = other_line_item_or_personalizations_attributes[:personalizations_attributes] || []
        personalizations_attributes = fill_personalizations_attributes(personalizations_attributes)
      end

      if personalizations_attributes.present?
        matching_personalizations_attributes?(personalizations_attributes)
      else
        false
      end
    end

    private

    def copy_personalizations
      # Make sure required personalizations were created
      self.product.personalizations.select {|p| p.required}.each do |required_personalization|
        unless self.personalizations.detect {|p| p.name == required_personalization.name}
          self.personalizations << Spree::LineItemPersonalization.new(line_item: self, name: required_personalization.name)
        end
      end

      if self.product.personalizations.present?
        self.personalizations.each do |line_item_personalization|
          relevant_product_personalization = product.personalization_with_name(line_item_personalization.name)

          if relevant_product_personalization
            line_item_personalization.line_item = self
            line_item_personalization.limit = relevant_product_personalization.limit

            if relevant_product_personalization.list?
              option_value_id = line_item_personalization.option_value_id
              option_value_product_personalization = relevant_product_personalization.option_value_product_personalizations.find_by_option_value_id(option_value_id)
              calculator = option_value_product_personalization.try(:calculator)
            else
              calculator = relevant_product_personalization.calculator
            end

            line_item_personalization.price = calculator.try(:preferred_amount)
            line_item_personalization.currency = calculator.try(:preferred_currency)
            line_item_personalization.save
          else
            line_item_personalization.destroy
          end
        end
      else
        # line_item personalization should not be created if the product doesn't have personalization
        self.personalizations = []
      end
    end

    def fill_personalizations_attributes(personalizations_attributes)
      personalizations_attributes.each do |personalization_attributes|
        relevant_product_personalization = product.personalization_with_name(personalization_attributes[:name])

        if relevant_product_personalization
          if relevant_product_personalization.list?
            option_value_id = personalization_attributes[:option_value_id]

            personalization_attributes[:value] = Spree::OptionValue.find_by_id(option_value_id).name

            option_value_product_personalization = relevant_product_personalization.option_value_product_personalizations.find_by_option_value_id(option_value_id)
            calculator = option_value_product_personalization.try(:calculator)
          else
            calculator = relevant_product_personalization.calculator
          end

          personalization_attributes[:price] = calculator.preferred_amount
          personalization_attributes[:currency] = calculator.preferred_currency
        end
      end

      personalizations_attributes
    end

    def matching_personalizations_attributes?(personalizations_attributes)
      if personalizations.present?
        return false if personalizations.count != personalizations_attributes.count

        personalizations.each do |line_item_personalization|
          match = personalizations_attributes.detect do |personalization_attributes|
            line_item_personalization.match? personalization_attributes.with_indifferent_access
          end
          return false unless match
        end
        true
      else
        personalizations_attributes.blank?
      end
    end

  end
end
