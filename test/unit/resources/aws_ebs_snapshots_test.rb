require 'helper'
require 'aws_ebs_snapshots'
require 'aws-sdk-core'
require 'pp'

class AwsEbsSnapshotsConstructorTest < Minitest::Test

  def test_empty_params_ok
    AwsEbsSnapshots.new(client_args: { stub_responses: true })
  end

  def test_rejects_other_args
    assert_raises(ArgumentError) { AwsEbsSnapshots.new('rubbish') }
  end

  def test_snapshots_non_existing_for_empty_response
    refute AwsEbsSnapshots.new(client_args: { stub_responses: true }).exist?
  end
end

class AwsEbsSnapshotsHappyPathTest < Minitest::Test

  def setup
    data = {}
    data[:method] = :describe_snapshots
    mock_snapshot = {
      description: "This is my copied snapshot.",
      owner_id: "012345678910",
      progress: "87%",
      snapshot_id: "snap-066877671789bd71b",
      start_time: Time.parse("2014-02-28T21:37:27.000Z"),
      state: "pending",
      volume_id: "vol-1234567890abcdef0",
      volume_size: 8,
    }
    mock_snapshot[:snapshot_id] = 'snap-012b75749d0b5ceb5'
    data[:data] = { :snapshots => [mock_snapshot] }
    data[:client] = Aws::EC2::Client
    @snapshots = AwsEbsSnapshots.new(client_args: { stub_responses: true }, stub_data: [data])
    #pp @snapshots
  end

  def test_snapshots_exists
    assert @snapshots.exist?
  end

  def test_snapshots_ids
    assert_equal(@snapshots.snapshot_ids, ['snap-012b75749d0b5ceb5'])
  end

  def test_snapshots_filtering_not_there
    refute @snapshots.where(:snapshot_id => 'bad').exist?
  end

  def test_snapshots_filtering_there
    assert @snapshots.where(:snapshot_id => 'snap-012b75749d0b5ceb5').exist?
  end
end