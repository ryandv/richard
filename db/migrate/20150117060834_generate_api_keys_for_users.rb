class GenerateApiKeysForUsers < ActiveRecord::Migration
  def up
    User.all.each do |user|
      user.update_attributes(api_key: ApiKeyGenerator.generate)
    end
  end

  def down
    User.all.each do |user|
      user.update_attributes(api_key: nil)
    end
  end
end
