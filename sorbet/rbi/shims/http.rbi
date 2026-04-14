# typed: true
# frozen_string_literal: true

module HTTP
  module Chainable
    sig { params(type: T.any(String, Symbol)).returns(Session) }
    def accept(type); end

    sig { params(value: T.untyped).returns(Session) }
    def auth(value); end

    sig { params(uri: T.any(String, URI)).returns(Session) }
    def base_uri(uri); end

    sig { params(user: T.untyped, pass: T.untyped).returns(Session) }
    def basic_auth(user:, pass:); end

    sig { params(cookies: T::Hash[String, String]).returns(Session) }
    def cookies(cookies); end

    sig { returns(Options) }
    def default_options; end

    sig do
      params(opts: T.any(T::Hash[Symbol, T.untyped], Options))
        .returns(Options)
    end
    def default_options=(opts); end

    sig { params(user: T.untyped, pass: T.untyped).returns(Session) }
    def digest_auth(user:, pass:); end

    sig { params(encoding: T.any(String, Encoding)).returns(Session) }
    def encoding(encoding); end

    sig do
      params(
        strict: T.nilable(T::Boolean),
        max_hops: T.nilable(Integer),
        on_redirect: T.untyped,
      ).returns(Session)
    end
    def follow(strict: nil, max_hops: nil, on_redirect: nil); end

    sig do
      params(headers: T::Hash[String, String])
        .returns(Session)
    end
    def headers(headers); end

    sig { returns(Session) }
    def nodelay; end

    sig do
      params(host: T.nilable(String), timeout: Integer).returns(Session)
    end
    sig do
      type_parameters(:U).params(
        host: T.nilable(String),
        timeout: Integer,
        block: T.proc.params(session: Session).returns(T.type_parameter(:U)),
      ).returns(T.type_parameter(:U))
    end
    def persistent(host = nil, timeout: 5, &block); end

    sig do
      params(verb: Symbol, uri: T.any(String, URI), options: T.untyped).returns(Response)
    end
    sig do
      type_parameters(:U).params(
        verb: Symbol,
        uri: T.any(String, URI),
        options: T.untyped,
        block: T.proc.bind(Response).returns(T.type_parameter(:U)),
      ).returns(T.type_parameter(:U))
    end
    def request(verb, uri, **options, &block); end

    sig do
      params(
        tries: T.nilable(Integer),
        delay: T.untyped,
        exceptions: T.untyped,
        retry_statuses: T.untyped,
        on_retry: T.untyped,
        max_delay: T.untyped,
        should_retry: T.untyped,
      ).returns(Session)
    end
    def retriable(
      tries: nil,
      delay: nil,
      exceptions: nil,
      retry_statuses: nil,
      on_retry: nil,
      max_delay: nil,
      should_retry: nil
    )
    end

    sig { params(proxy: T.untyped).returns(Session) }
    def through(*proxy); end

    sig do
      params(options: T.any(Numeric, T::Hash[Symbol, T.untyped], Symbol)).returns(Session)
    end
    def timeout(options); end

    sig { params(features: T.untyped).returns(Session) }
    def use(*features); end

    sig { params(proxy: T.untyped).returns(Session) }
    def via(*proxy); end

    module Verbs
      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def connect(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def delete(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def get(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def head(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.nilable(T.proc.bind(Response).returns(T.type_parameter(:U))),
        ).returns(T.type_parameter(:U))
      end
      def options(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def patch(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def post(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def put(uri, **options, &block); end

      sig do
        params(uri: T.any(String, URI), options: T.untyped).returns(Response)
      end
      sig do
        type_parameters(:U).params(
          uri: T.any(String, URI),
          options: T.untyped,
          block: T.proc.bind(Response).returns(T.type_parameter(:U)),
        ).returns(T.type_parameter(:U))
      end
      def trace(uri, **options, &block); end
    end
  end

  class Response
    sig { returns(Body) }
    def body; end
  end
end
