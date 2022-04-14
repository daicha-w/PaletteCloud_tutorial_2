class EmailFormatValidator < ActiveModel::EachValidator
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i

  def validate_each(record, attribute, value)
    unless value.match(VALID_EMAIL_REGEX)
      record.errors.add(attribute, options[:message] || I18n.t('validators.email_format.message'))
    end
  end
end
