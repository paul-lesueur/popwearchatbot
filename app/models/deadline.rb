class Deadline < ApplicationRecord
  belongs_to :user
  has_many :chats, dependent: :destroy

  enum :category, {
    client: "client",
    atelier: "atelier",
    administratif: "administratif",
    comptable: "comptable"
  }

  enum :status, {
    todo: "todo",
    in_progress: "in_progress",
    done: "done"
  }

  validates :title, :due_date, :category, :status, presence: true
end
