class CreateInvitation < ActiveRecord::Migration[7.2]
  def change
    create_table :invitations do |t|
      t.references :room, null: false, foreign_key: true
      t.string :token_digest, null: false
      t.datetime :send_token_at, null: false

      t.timestamps
    end
  end
end
