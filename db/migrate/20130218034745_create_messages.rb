class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :messenger_name
      t.string :messenger_email
      t.text :content

      t.timestamps
    end
  end
end
