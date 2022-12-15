require "test_helper"

class ActiveSupport::DatabaseCache::EntryMarker::AsyncTest < ActiveSupport::TestCase
  setup do
    @namespace = "test-#{SecureRandom.hex}"
    @cache = lookup_store(entry_marker: :async, role: :writing, entry_marker_options: { batch_size: 2})
  end

  test "read updates asynchronously" do
    @cache.write("foo", 1)
    travel 1.day
    assert ActiveSupport::DatabaseCache::Entry.first.updated_at < Time.now
    @cache.read("foo")
    sleep 0.1
    assert ActiveSupport::DatabaseCache::Entry.first.updated_at < Time.now
    @cache.read("foo")
    sleep 0.1
    assert ActiveSupport::DatabaseCache::Entry.first.updated_at == Time.now
  end
end
