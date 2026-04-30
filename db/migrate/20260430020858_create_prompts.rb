class CreatePrompts < ActiveRecord::Migration[8.1]
  def change
    create_table :prompts do |t|
      t.string :title, null: false
      t.text :description
      t.text :content, null: false

      t.integer :prompt_type, null: false, default: 0

      t.references :user, null: false, foreign_key: true


      t.integer :favorites_count, default: 0, null: false
      t.integer :comments_count, default: 0, null: false

      t.timestamps
    end

    add_index :prompts, :prompt_type
    add_index :prompts, :created_at
  end
end
