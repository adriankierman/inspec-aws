require 'helper'
require 'aws_backend'
require 'aws-sdk-core'
require 'pp'
require 'json'

class AwsResourceBaseTest < Minitest::Test
  def setup
    data = {}
    data[:method] = :describe_vpcs
    mock_vpc = {}
    mock_vpc[:vpc_id] = 'vpc-12345678'
    mock_vpc[:is_default] = false
    data[:data] = { :vpcs => [mock_vpc] }
    data[:client] = Aws::EC2::Client
    @resource_base = AwsResourceBase.new(client_args: { stub_responses: true }, stub_data: [data])
  end

  def test_should_assume_role
    assert(@resource_base.should_assume_role?({client_args: { stub_responses: true },
                                               role_arn: 'arn:aws:iam::123456789012:role/compliance_role'}))
    ENV['AWS_ROLE_ARN'] = nil
    refute(@resource_base.should_assume_role?({client_args: { stub_responses: true }, no_role_arn: ''}))
  end

  def test_assume_role
    rc = @resource_base.assume_role({role_arn: 'arn:aws:iam::123456789012:role/compliance_role'},
                                      {client_args: {stub_responses: true}})
    refute(rc.credentials.session_token.nil?)
  end
end