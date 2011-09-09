class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table "users", :force => true do |t|
      t.column :login,                     :string
      t.column :crypted_password,          :string, :limit => 40
      t.column :salt,                      :string, :limit => 40
      t.column :is_admin,                  :integer, :default => 0
      t.column :created_at,                :datetime
      t.column :updated_at,                :datetime
      t.column :remember_token,            :string
      t.column :remember_token_expires_at, :datetime
    end
    
    user = User.new
    user.login = "admin"
    user.password = "calp455w0rd"
    user.password_confirmation = "calp455w0rd"
    user.is_admin = 1
    user.save!
    
  end

  def self.down
    drop_table "users"
  end
end
