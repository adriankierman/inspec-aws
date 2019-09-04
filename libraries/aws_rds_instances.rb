# frozen_string_literal: true

require 'aws_backend'

class AwsRdsInstances < AwsResourceBase
  name 'aws_rds_instances'
  desc 'Verifies settings for AWS Security Groups in bulk'
  example "
    # Verify that you have security groups defined
    describe aws_rds_instances do
      it { should exist }
    end

    # Verify you have more than the default security group
    describe aws_rds_instances do
      its('entries.count') { should be > 1 }
    end
  "

  attr_reader :table

  # FilterTable setup
  FilterTable.create
             .register_column(:tags, field: :tags)
             .register_column(:db_instance_identifiers, field: :db_instance_identifier)
             .register_column(:cluster_identifiers,     field: :cluster_identifier)
             .install_filter_methods_on_resource(self, :table)

  def initialize(opts = {})
    # Call the parent class constructor
    super(opts)
    validate_parameters([])
    @table = fetch_data
  end

  def fetch_data
    rds_instance_rows = []
    pagination_options = {}
    loop do
      catch_aws_errors do
        @api_response = @aws.rds_client.describe_db_instances(**pagination_options)
      end
      return [] if !@api_response || @api_response.empty?

      @api_response.db_instances.each do |rds_instance|
        rds_instance_rows += [{
          db_instance_identifier: rds_instance.db_instance_identifier,
                                db_name: rds_instance.db_name,
        }]
      end
      break unless @api_response.marker
      pagination_options = { marker: @api_response[:marker] }
    end
    @table = rds_instance_rows
  end
end
