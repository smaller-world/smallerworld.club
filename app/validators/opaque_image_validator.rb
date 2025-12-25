# typed: strict
# frozen_string_literal: true

require "vips"

class OpaqueImageValidator < ActiveModel::EachValidator
  extend T::Sig

  sig { params(record: ActiveRecord::Base, attribute: Symbol, value: T.untyped).void }
  def validate_each(record, attribute, value)
    if value.is_a?(ActiveStorage::Attached::One)
      if !value.attached? && options[:allow_nil]
        return
      end
      value = value.public_send(:blob)
    end
    unless value.is_a?(ActiveStorage::Blob)
      raise "Expected an ActiveStorage::Blob, instead got: #{value.class}"
    end
    unless image_blob_is_opaque?(value)
      record.errors.add(attribute, :invalid, message: "must be opaque")
    end
  end

  private

  # == Helpers ==

  sig { params(blob: ActiveStorage::Blob).returns(T::Boolean) }
  def image_blob_is_opaque?(blob)
    blob.open do |file|
      image = Vips::Image.new_from_file(file.to_path)
      image_is_opaque?(image)
    end
  end

  sig { params(image: Vips::Image).returns(T::Boolean) }
  def image_is_opaque?(image)
    return true unless image.has_alpha?

    alpha = image[image.bands - 1]
    alpha.min == 255
  end
end
