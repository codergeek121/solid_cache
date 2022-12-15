require "test_helper"

class ActiveSupport::DatabaseCache::EntryMarker::SyncTest < ActiveSupport::TestCase
  setup do
    @namespace = "test-#{SecureRandom.hex}"
    @cache = lookup_store(entry_marker: :sync, role: :writing)
  end

  test "read updates synchronously" do
    @cache.write("foo", 1)
    travel 1.day
    assert ActiveSupport::DatabaseCache::Entry.first.updated_at < Time.now
    @cache.read("foo")
    assert ActiveSupport::DatabaseCache::Entry.first.updated_at == Time.now
  end
end
