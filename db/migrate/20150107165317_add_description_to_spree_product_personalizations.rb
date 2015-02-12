class AddDescriptionToSpreeProductPersonalizations < ActiveRecord::Migration
  def change
    add_column :spree_product_personalizations, :description, :string, after: :name
  end
end
