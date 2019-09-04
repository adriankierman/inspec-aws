require 'helper'
require 'aws_ebs_snapshot'
require 'aws-sdk-core'

class AwsEbsSnapshotConstructorTest < Minitest::Test

  def test_empty_params_not_ok
    assert_raises(ArgumentError) { AwsEbsSnapshot.new(client_args: { stub_responses: true }) }
  end

  def test_rejects_scalar_invalid_args
    assert_raises(ArgumentError) { AwsEbsSnapshot.new('rubbish') }
  end

  def test_accepts_snapshot_id_as_hash_eight_sign
    AwsEbsSnapshot.new(snapshot_id: 'snap-1234abcd', client_args: { stub_responses: true })
  end

  def test_accepts_snapshot_id_as_hash
    AwsEbsSnapshot.new(snapshot_id: 'snap-abcd123454321dcba', client_args: { stub_responses: true })
  end

  def test_rejects_unrecognized_params
    assert_raises(ArgumentError) { AwsEbsSnapshot.new(rubbish: 9) }
  end

  def test_rejects_invalid_snapshot_id
    assert_raises(ArgumentError) { AwsEbsSnapshot.new(snapshot_id: 'snap-invalid') }
  end

  def test_snapshot_non_existing
    refute AwsEbsSnapshot.new(snapshot_id: 'snap-1234abcd', client_args: { stub_responses: true }).exists?
  end

  def test_snapshot_non_existing_name
    refute AwsEbsSnapshot.new(name: 'not-there', client_args: { stub_responses: true }).exists?
  end
end

class AwsEbsSnapshotConstructorNameIdTest < Minitest::Test
  def setup
    data = {}
    data[:method] = :describe_snapshots
    mock_snapshot = {}
    mock_snapshot[:tags] = [{ :key => 'Name', :value => 'inspec-ebs-snapshot-name' }]
    mock_snapshot[:snapshot_id] = 'snap-079fa6fd624da8e44'
    data[:data] = { :snapshots => [mock_snapshot] }
    data[:client] = Aws::EC2::Client
    @snapshot = AwsEbsSnapshot.new(snapshot_id: 'snap-012b75749d0b5ceb5', client_args: { stub_responses: true }, stub_data: [data])
  end

  def test_vol_snapshot_id
    assert_equal(@snapshot.snapshot_id, 'snap-079fa6fd624da8e44')
  end

  def test_vol_id
    assert_equal(@snapshot.id, 'snap-079fa6fd624da8e44')
  end

  def test_vol_exists
    assert @snapshot.exists?
  end
end

class AwsEbsSnapshotHappyPathTest < Minitest::Test

  def setup
    data = {}
    data[:method] = :describe_snapshots
    mock_snapshot = {
      description: "This is my copied snapshot.",
      owner_id: "012345678910",
      volume_id: "vol-049df61146c4d7901",
      progress: "100%",
      snapshot_id: "snap-066877671789bd71b",
      start_time: Time.parse("2014-02-28T21:37:27.000Z"),
      state: "completed",
      encrypted: true,
    }
    mock_snapshot[:tags] = [{ :key => 'Name', :value => 'inspec-ebs-snapshot-name' }]
    data[:data] = { :snapshots => [mock_snapshot] }
    data[:client] = Aws::EC2::Client
    @snapshot = AwsEbsSnapshot.new(snapshot_id: 'snap-012b75749d0b5ceb5', client_args: { stub_responses: true }, stub_data: [data])
  end

  def test_snapshot_exists
    assert @snapshot.exists?
  end

  def test_snapshot_encrypted
    assert_equal(@snapshot.encrypted, true)
  end

  def test_snapshot_snapshot_id
    assert_equal(@snapshot.snapshot_id, 'snap-066877671789bd71b')
  end

  def test_snapshot_state
    assert_equal(@snapshot.state, 'completed')
  end

  def test_snapshot_owner_id
    assert_equal(@snapshot.owner_id, '012345678910')
  end

  def test_snapshot_volume_id
    assert_equal(@snapshot.volume_id, 'vol-049df61146c4d7901')
  end

end