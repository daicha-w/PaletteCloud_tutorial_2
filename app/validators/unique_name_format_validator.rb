class UniqueNameFormatValidator < ActiveModel::EachValidator
  VALID_UNIQUE_NAME_REGEX = /\A[a-z0-9_]+\z/i

  def validate_each(record, attribute, value)
    unless value.match(VALID_UNIQUE_NAME_REGEX)
      record.errors.add(attribute, options[:message] || I18n.t('validators.unique_name_format.message'))
    end
  end
end
