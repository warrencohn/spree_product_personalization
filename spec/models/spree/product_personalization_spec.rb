require 'spec_helper'

describe Spree::ProductPersonalization do

  let(:name) { 'My Engrave' }
  let(:price) { BigDecimal.new(5) }
  let(:required) { true }
  let(:limit) { 100 }
  let(:options) do
    { product_personalization_attributes: { name: name, required: required, limit: limit, calculator_attributes: { type: "Spree::Calculator::FlatRate", preferred_amount: price.to_s } } }
  end
  let(:params) { ActionController::Parameters.new(options).permit(:product_personalization_attributes => Spree::ProductPersonalization.permitted_attributes) }

  it "auto save personalization" do
    product = build(:product)
    product.attributes = params
    product.save!

    expect(product.product_personalization).to be
    expect(product.product_personalization.name).to eq(name)
    expect(product.product_personalization.required).to eq(required)
    expect(product.product_personalization.limit).to eq(limit)
    expect(product.product_personalization.calculator.preferred_amount).to eq(price)
  end

  it "auto update personalization" do
    product = create(:product_with_personalization)
    expect(product.product_personalization.name).not_to eq(name)
    expect(product.product_personalization.calculator.preferred_amount).not_to eq(price)

    params[:product_personalization_attributes][:id] = product.product_personalization.id
    params[:product_personalization_attributes][:calculator_attributes][:id] = product.product_personalization.calculator.id
    product.update_attributes(params)

    expect(product.product_personalization).to be
    expect(product.product_personalization.name).to eq(name)
    expect(product.product_personalization.required).to eq(required)
    expect(product.product_personalization.limit).to eq(limit)
    expect(product.product_personalization.calculator.preferred_amount).to eq(price)
  end

  it "allows destroy personalization" do
    product = create(:product_with_personalization)
    pp_id = product.product_personalization.id
    calc_id = product.product_personalization.calculator.id
    params[:product_personalization_attributes][:id] = pp_id
    params[:product_personalization_attributes][:_destroy] = true
    params[:product_personalization_attributes][:calculator_attributes][:id] = calc_id
    product.update_attributes(params)

    product.reload
    expect(product.product_personalization).not_to be
    expect(Spree::ProductPersonalization.find_by(id: pp_id)).to be_nil
    expect(Spree::Calculator::FlatRate.find_by(id: calc_id)).to be_nil
  end

end
