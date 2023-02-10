require "test_helper"
require "active_support/testing/method_call_assertions"

class SolidCache::StatsTest < ActiveSupport::TestCase
  include ActiveSupport::Testing::TimeHelpers

  setup do
    @namespace = "test-#{SecureRandom.hex}"
  end

  def test_stats
    @cache = lookup_store(touch_batch_size: 2, trim_batch_size: 2, max_age: 2.weeks.to_i, max_entries: 1000, shards: [:default, :shard_one])

    expected = {
      shards: 2,
      shards_stats: {
        default: { max_age: 2.weeks.to_i, oldest_age: nil, max_entries: 1000, entries: 0 },
        shard_one: { max_age: 2.weeks.to_i, oldest_age: nil, max_entries: 1000, entries: 0 }
      }
    }

    assert_equal expected, @cache.stats
  end

  def test_stats_with_entries
    @cache = lookup_store(touch_batch_size: 2, trim_batch_size: 2, max_age: 2.weeks.to_i, max_entries: 1000, shards: [:default])

    expected_empty = { shards: 1, shards_stats: { default: { max_age: 2.weeks.to_i, oldest_age: nil, max_entries: 1000, entries: 0 } } }

    assert_equal expected_empty, @cache.stats

    freeze_time
    @cache.write("foo", 1)
    @cache.write("bar", 1)

    SolidCache::Entry.update_all(created_at: Time.now - 20.minutes)

    expected_not_empty = { shards: 1, shards_stats: { default: { max_age: 2.weeks.to_i, oldest_age: 20.minutes.to_i, max_entries: 1000, entries: 2 } } }

    assert_equal expected_not_empty, @cache.stats
  end
end