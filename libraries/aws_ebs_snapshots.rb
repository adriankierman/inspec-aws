# frozen_string_literal: true

require 'aws_backend'
require 'pp'

class AwsEbsSnapshots < AwsResourceBase
  name 'aws_ebs_snapshots'
  desc 'Verifies settings for AWS EBS snapshots in bulk'
  example '
    describe aws_ebs_snapshots do
      it { should exist }
    end
  '

  def initialize(opts = {})
    # Call the parent class constructor
    super(opts)
    permitted_fields = %i(filters owner_ids restorable_by_user_ids snapshot_ids)
    validate_parameters(permitted_fields)
    snapshot_rows = []
    query_options = opts.clone.select { |key, _value| permitted_fields.include?(key) }
    loop do
      catch_aws_errors do
        @api_response = @aws.compute_client.describe_snapshots(query_options)
      end
      return [] if !@api_response || @api_response.empty?

      @api_response.snapshots.map do |snapshot|
        snapshot_rows += [{ snapshot_id: snapshot.snapshot_id }]
      end
      break unless @api_response.next_token
      query_options[:next_token] = @api_response.next_token
    end
    @table = snapshot_rows
  end

  # FilterTable setup
  filter_table_config = FilterTable.create
  filter_table_config.add(:snapshot_ids, field: :snapshot_id)
  filter_table_config.connect(self, :fetch_data)

  def fetch_data
    @table
  end
end
