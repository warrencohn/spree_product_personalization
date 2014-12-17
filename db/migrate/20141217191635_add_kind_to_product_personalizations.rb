class AddKindToProductPersonalizations < ActiveRecord::Migration
  def change
    add_column :spree_product_personalizations, :kind, :string, default: "text"
  end
end
