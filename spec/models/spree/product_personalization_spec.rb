require 'spec_helper'

describe Spree::ProductPersonalization do

  let(:count) { 5 }
  let(:attributes) do
    attrs = []
    count.times { attrs << { name: generate(:personalization_name), required: [true, false].sample, limit: rand(10...1000), calculator_attributes: { type: "Spree::Calculator::FlatRate", preferred_amount: Money.new(rand(100...500)).to_s } } }
    attrs
  end
  let(:options) do
    { personalizations_attributes: attributes }
  end
  let(:params) { ActionController::Parameters.new(options).permit(:personalizations_attributes => Spree::ProductPersonalization.permitted_attributes) }

  describe "Validations" do
    before do
      @target = build(:product_personalization)
      expect(@target.valid?).to be_true
    end

    it "fails when name is too short" do
      @target.name = ""
      expect(@target.valid?).to be_false
    end

    it "fails when name is too long" do
      @target.name = "a" * (Spree::Personalization::Config[:label_limit] + 1)
      expect(@target.valid?).to be_false
    end

    it "fails when limit is too small" do
      @target.limit = 0
      expect(@target.valid?).to be_false
    end

    it "fails when limit is too big" do
      @target.limit = Spree::Personalization::Config[:text_limit] + 1
      expect(@target.valid?).to be_false
    end

    it "fails when price is negative" do
      @target.calculator.preferred_amount = -1.0
      expect(@target.valid?).to be_false
    end

    context "attribute kind" do
      it 'should be invalid for empty value' do
        @target.kind = nil
        expect(@target.valid?).to be_false
      end

      it 'should be invalid for bad values' do
        @target.kind = "random"
        expect(@target.valid?).to be_false
      end

      it 'should be valid for a valid value' do
        @target.kind = "text"
        expect(@target.valid?).to be_true
        @target.kind = "options"
        expect(@target.valid?).to be_true
      end
    end
  end

  it "saves personalization" do
    product = build(:product)
    product.attributes = params
    product.save!

    expect(product.personalizations).to be
    expect(product.personalizations.count).to eq(count)
    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      expect(t.name).to eq(s[:name])
      expect(t.required).to eq(s[:required])
      expect(t.limit).to eq(s[:limit])
      expect(t.calculator.preferred_amount).to eq(BigDecimal.new(s[:calculator_attributes][:preferred_amount]))
    end
  end

  it "updates personalization" do
    product = create(:product_with_personalizations, personalization_count: count)
    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      s[:id] = t.id
      s[:calculator_attributes][:id] = t.calculator.id
    end
    product.update_attributes(params)
    product.reload

    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      expect(t.name).to eq(s[:name])
      expect(t.required).to eq(s[:required])
      expect(t.limit).to eq(s[:limit])
      expect(t.calculator.preferred_amount).to eq(BigDecimal.new(s[:calculator_attributes][:preferred_amount]))
    end
  end

  it "allows destroy personalization" do
    product = create(:product_with_personalizations, personalization_count: count)
    product.personalizations.each_with_index do |t, i|
      s = attributes[i]
      s[:id] = t.id
      s[:calculator_attributes][:id] = t.calculator.id
    end
    pp_id = product.personalizations.first.id
    calc_id = product.personalizations.first.calculator.id
    attributes[0][:_destroy] = true
    product.update_attributes(params)
    product.reload

    expect(product.personalizations.count).to eq(count-1)
    expect(Spree::ProductPersonalization.find_by(id: pp_id)).to be_nil
    expect(Spree::Calculator::FlatRate.find_by(id: calc_id)).to be_nil
  end

end
