# typed: strict
# frozen_string_literal: true

# Assertions for files downloaded by the browser during a system test.
#
# The capybara-playwright-driver saves every browser download to
# `Capybara.save_path` (using the server-suggested filename) on a background
# thread — see Capybara::Playwright::PageExtension. That means a download
# appears asynchronously *after* the click that triggered it returns, so we
# poll until the expected file shows up.
module DownloadsTestHelper
  extend T::Sig
  extend T::Helpers

  requires_ancestor { ActionDispatch::SystemTestCase }

  # == Methods ==

  # Asserts that a file matching `pattern` (a glob, e.g. "*.pkpass") was
  # downloaded within `wait` seconds. Returns the Pathname of the file.
  sig { params(pattern: String, wait: T.any(Float, Integer)).returns(Pathname) }
  def assert_download(pattern, wait: 10)
    deadline = Process.clock_gettime(Process::CLOCK_MONOTONIC) + wait
    match = T.let(nil, T.nilable(Pathname))

    # A match counts as "done" only once its size is non-zero and unchanged
    # across two consecutive polls — the driver writes the file on a background
    # thread, so it can appear before its bytes are fully flushed.
    last_sizes = T.let({}, T::Hash[String, Integer])

    loop do
      candidate = Dir.glob(File.join(downloads_dir, pattern)).min
      if candidate
        size = file_size(candidate)
        if size.positive? && last_sizes[candidate] == size
          match = Pathname(candidate)
        else
          last_sizes[candidate] = size
        end
      end

      break if match
      break if Process.clock_gettime(Process::CLOCK_MONOTONIC) >= deadline

      sleep(0.1)
    end

    assert(
      match,
      "expected a file matching #{pattern.inspect} in #{downloads_dir} " \
        "within #{wait}s, but found: #{downloads_dir_contents}",
    )
    T.must(match)
  end

  private

  # == Helpers ==

  sig { returns(Pathname) }
  def downloads_dir
    Capybara.save_path or raise "Missing Capybara.save_path"
  end

  sig { returns(T::Array[String]) }
  def downloads_dir_contents
    Dir.children(Capybara.save_path)
  rescue
    []
  end

  # File size in bytes, or 0 if the file vanished between glob and stat.
  sig { params(path: String).returns(Integer) }
  def file_size(path)
    File.size(path)
  rescue Errno::ENOENT
    0
  end
end

ActiveSupport.on_load(:action_dispatch_system_test_case) do
  include DownloadsTestHelper
end
