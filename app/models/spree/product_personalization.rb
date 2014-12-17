module Spree
  class ProductPersonalization < ActiveRecord::Base
    include Spree::Core::CalculatedAdjustments

    belongs_to :product

    validates :name, length: {minimum: 1, maximum: Spree::Personalization::Config[:label_limit]}
    validates :name, uniqueness: {scope: :product_id}
    validates :limit, numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: Spree::Personalization::Config[:text_limit]}
    validate :check_price

    before_validation { self.name = self.name.strip if self.name }

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
