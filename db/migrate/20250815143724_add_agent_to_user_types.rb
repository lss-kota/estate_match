class AddAgentToUserTypes < ActiveRecord::Migration[8.0]
  def change
    # user_typeのenumにagent(2)を追加するためのコメント
    # Userモデルで enum :user_type, { buyer: 0, owner: 1, agent: 2, admin: 99 } に変更
    # 既存データには影響なし（buyer=0, owner=1, admin=99はそのまま）
  end
end
