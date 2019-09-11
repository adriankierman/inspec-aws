title 'Test single AWS EBS Snapshot'

aws_ebs_snapshot_name = attribute(:aws_ebs_snapshot_name, default: '', description: 'The AWS EBS Snapshot name.')
aws_ebs_snapshot_id = attribute(:aws_ebs_snapshot_id, default: '', description: 'The AWS EBS Snapshot ID.')

control 'aws-ebs-snapshot-1.0' do

  impact 1.0
  title 'Ensure AWS EBS Snapshot has the correct properties.'

  describe aws_ebs_snapshot(snapshot_id: aws_ebs_snapshot_id) do
    it { should exist }
    its ('snapshot_id') { should eq aws_ebs_snapshot_id }
    its('tags') { should include(key: 'Name', value: aws_ebs_snapshot_name) }
    it { should be_encrypted }
    it { should_not be_public }
    it { should be_private }
  end

  describe aws_ebs_snapshot(aws_ebs_snapshot_id) do
    it { should exist }
    its ('snapshot_id') { should eq aws_ebs_snapshot_id }
    its('tags') { should include(key: 'Name', value: aws_ebs_snapshot_name) }
    it { should be_encrypted }
    it { should_not be_public }
    it { should be_private }
  end

  describe aws_ebs_snapshot(name: aws_ebs_snapshot_name) do
    it { should exist }
    its ('snapshot_id') { should eq aws_ebs_snapshot_id }
    its('tags') { should include(key: 'Name', value: aws_ebs_snapshot_name) }
    it { should be_encrypted }
    it { should_not be_public }
    it { should be_private }
  end

  describe aws_ebs_snapshot(name: 'not_existing_snapshot_name') do
    it { should_not exist }
  end

end