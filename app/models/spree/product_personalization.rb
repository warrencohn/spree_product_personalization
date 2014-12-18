module Spree
  class ProductPersonalization < ActiveRecord::Base
    include Spree::Core::CalculatedAdjustments

    belongs_to :product
    has_and_belongs_to_many :option_values, join_table: :spree_option_values_product_personalizations

    validates :name, length: {minimum: 1, maximum: Spree::Personalization::Config[:label_limit]}
    validates :name, uniqueness: {scope: :product_id}
    validates :limit, numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: Spree::Personalization::Config[:text_limit]}
    validates :kind, inclusion: { in: %w(text options), message: "%{value} is not a valid type of personalization" }
    validate :check_price
    validate :check_kind

    before_validation { self.name = self.name.strip if self.name }

    before_save { self.calculator.preferred_currency = Spree::Config[:currency] }

    def self.permitted_attributes
      [:id, :name, :kind, :required, :limit, :_destroy, :calculator_attributes => [:id, :type, :preferred_amount]]
    end

    def text?
      kind == 'text'
    end

    def options?
      kind == 'options'
    end

    private

    def check_price
      if self.calculator.preferred_amount < 0
        errors.add(:base, Spree.t('errors.increasing_price_can_not_be_negative'))
      end
    end

    def check_kind
      if text? && option_values.present?
        errors.add(:base, Spree.t('errors.personalization_text_cannot_have_options'))
      end

      if options? && option_values.empty?
        errors.add(:base, Spree.t('errors.personalization_options_should_have_options'))
      end
    end
  end
end
