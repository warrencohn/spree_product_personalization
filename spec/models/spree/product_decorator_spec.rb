require 'spec_helper'

describe Spree::Product do

  context "duplication" do

    let(:product) { create(:product_with_personalization) }
    let(:source) { product.product_personalization }

    it 'clones personalization info' do
      target = product.duplicate.product_personalization

      expect(target).to be
      expect(target.id).not_to eq(source.id)
      expect(target.name).to eq(source.name)
      expect(target.required).to eq(source.required)
      expect(target.limit).to eq(source.limit)
      expect(target.calculator.id).to_not eq(source.calculator.id)
      expect(target.calculator.preferred_amount).to eq(source.calculator.preferred_amount)
    end
  end

end
