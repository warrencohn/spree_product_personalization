module Spree
  class ProductPersonalization < ActiveRecord::Base
    include Spree::Core::CalculatedAdjustments

    belongs_to :product

    validates :name, presence: true
    validates :name, uniqueness: {scope: :product_id}
    validates :limit, numericality: {only_integer: true, greater_than: 0, less_than_or_equal_to: Spree::Config[:personalization_text_limit]}

    before_save { self.calculator.preferred_currency = Spree::Config[:currency] }

    def self.permitted_attributes 
      [:id, :name, :required, :limit, :_destroy, :calculator_attributes => [:id, :type, :preferred_amount]]
    end

  end
end
