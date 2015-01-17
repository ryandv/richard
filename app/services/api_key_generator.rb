module ApiKeyGenerator
  extend self

  def generate
    SecureRandom.hex(26)
  end
end