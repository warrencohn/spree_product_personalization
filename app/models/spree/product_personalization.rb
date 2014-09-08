module Spree
  class ProductPersonalization < ActiveRecord::Base
    include Spree::Core::CalculatedAdjustments

    belongs_to :product

    validates :name, length: {minimum: 1, maximum: Spree::Config[:personalization_label_limit]}
    validates :limit, numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: Spree::Config[:personalization_text_limit]}
    validate :check_price

    before_validation { self.name = self.name.strip }

    before_save { self.calculator.preferred_currency = Spree::Config[:currency] }

    def self.permitted_attributes 
      [:id, :name, :required, :limit, :_destroy, :calculator_attributes => [:id, :type, :preferred_amount]]
    end

    private

    def check_price
      if self.calculator.preferred_amount < 0
        errors.add(:base, Spree.t('errors.increasing_price_can_not_be_negative'))
      end
    end

  end
end
