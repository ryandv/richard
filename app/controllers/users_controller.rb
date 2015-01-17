class UsersController < ApplicationController
  before_action :authenticate_user!

  def reset_api_key
    current_user.update_attributes(api_key: ApiKeyGenerator.generate)
    render text: current_user.api_key
  end

  def api_key
    render text: current_user.api_key
  end

private

  module ApiKeyGenerator
    extend self

    def generate
      SecureRandom.hex(26)
    end
  end
end