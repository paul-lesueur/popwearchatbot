class CreateDeadlines < ActiveRecord::Migration[8.1]
  def change
    create_table :deadlines do |t|
      t.string :title
      t.text :description
      t.string :category
      t.date :due_date
      t.string :status
      t.integer :estimated_duration
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
