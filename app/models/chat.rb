class Chat < ApplicationRecord
  belongs_to :user
  belongs_to :deadline
  has_many :messages, dependent: :destroy
end
