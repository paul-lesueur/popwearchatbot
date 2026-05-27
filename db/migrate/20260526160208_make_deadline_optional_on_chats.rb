class MakeDeadlineOptionalOnChats < ActiveRecord::Migration[8.1]
  def change
    change_column_null :chats, :deadline_id, true
  end
end
