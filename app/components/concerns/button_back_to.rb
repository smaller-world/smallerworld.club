# typed: strict
# frozen_string_literal: true

module ButtonBackTo
  extend T::Sig
  include ButtonLinkTo

  private

  # == Method ==

  sig { params(args: T.untyped, attributes: T.untyped).void }
  def button_back_to(*args, **attributes)
    case args.length
    when 2
      label, target = args
    when 1
      target, = args
      label = target.to_s.humanize(capitalize: false)
    end

    button_link_to(
      "back to #{label}",
      target,
      icon: "huge/link-backward",
      **attributes,
    )
  end
end
