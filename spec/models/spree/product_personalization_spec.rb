require 'spec_helper'

describe Spree::ProductPersonalization do

  let(:name) { 'My Engrave' }
  let(:price) { BigDecimal.new(5) }
  let(:required) { true }
  let(:limit) { 100 }
  let(:options) do
    { personalization_attributes: { name: name, required: required, limit: limit, calculator_attributes: { type: "Spree::Calculator::FlatRate", preferred_amount: price.to_s } } }
  end
  let(:params) { ActionController::Parameters.new(options).permit(:personalization_attributes => Spree::ProductPersonalization.permitted_attributes) }

  it "auto save personalization" do
    product = build(:product)
    product.attributes = params
    product.save!

    expect(product.personalization).to be
    expect(product.personalization.name).to eq(name)
    expect(product.personalization.required).to eq(required)
    expect(product.personalization.limit).to eq(limit)
    expect(product.personalization.calculator.preferred_amount).to eq(price)
  end

  it "auto update personalization" do
    product = create(:product_with_personalization)
    expect(product.personalization.name).not_to eq(name)
    expect(product.personalization.calculator.preferred_amount).not_to eq(price)

    params[:personalization_attributes][:id] = product.personalization.id
    params[:personalization_attributes][:calculator_attributes][:id] = product.personalization.calculator.id
    product.update_attributes(params)

    expect(product.personalization).to be
    expect(product.personalization.name).to eq(name)
    expect(product.personalization.required).to eq(required)
    expect(product.personalization.limit).to eq(limit)
    expect(product.personalization.calculator.preferred_amount).to eq(price)
  end

  it "allows destroy personalization" do
    product = create(:product_with_personalization)
    pp_id = product.personalization.id
    calc_id = product.personalization.calculator.id
    params[:personalization_attributes][:id] = pp_id
    params[:personalization_attributes][:_destroy] = true
    params[:personalization_attributes][:calculator_attributes][:id] = calc_id
    product.update_attributes(params)

    product.reload
    expect(product.personalization).not_to be
    expect(Spree::ProductPersonalization.find_by(id: pp_id)).to be_nil
    expect(Spree::Calculator::FlatRate.find_by(id: calc_id)).to be_nil
  end

  context "validation" do
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

  end

end
