# frozen_string_literal: true

module SpecSupport::FakeDataGenerator
  STR_LETTERS = (('a'..'z').to_a | ('A'..'Z').to_a).freeze
  STR_LENGTH  = 20

  def gen_str(str_len = STR_LENGTH)
    Array.new(str_len) { STR_LETTERS.sample }.join
  end

  def gen_symb(str_len = STR_LENGTH)
    gen_str(str_len).to_sym
  end
end
