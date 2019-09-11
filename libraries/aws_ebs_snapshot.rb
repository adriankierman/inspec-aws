# frozen_string_literal: true

require 'aws_backend'

class AwsEbsSnapshot < AwsResourceBase
  name 'aws_ebs_snapshot'
  desc 'Verifies settings for an EBS snapshot'

  example "
    describe aws_ebs_snapshot('snap-12345678') do
      it { should be_encrypted }
      it { should_not be_public }
    end
  "

  def initialize(opts = {})
    raise ArgumentError, 'aws_ebs_snapshot `id` or `name` must be provided' if opts.nil?
    opts = { snapshot_id: opts } if opts.is_a?(String) # this preserves the original scalar interface - note that the original implementation offered scalar 'id' or tag property :name
    # Call the parent class constructor
    super(opts)
    validate_parameters(%i(snapshot_id name))
    @display_name = opts[:snapshot_id] || opts[:name]
    if opts[:snapshot_id] && !opts[:snapshot_id].empty?
      raise ArgumentError, 'aws_ebs_snapshot must be in the format "snap-" followed by 8 or 17 hexadecimal characters.' if opts[:snapshot_id] !~ /^snap\-([0-9a-f]{8})|(^vol\-[0-9a-f]{17})$/
      snapshot_arguments = { snapshot_ids: [opts[:snapshot_id]] }
    else
      raise ArgumentError, 'aws_ebs_snapshot `name` must be provided' if opts[:name].nil? || opts[:name].empty?
      filter = { name: 'tag:Name', values: [opts[:name]] }
      snapshot_arguments = { filters: [filter] }
    end

    catch_aws_errors do
      @resp = @aws.compute_client.describe_snapshots(snapshot_arguments)
      @snapshot = @resp.snapshots[0].to_h
      create_resource_methods(@snapshot)
      # below is because the original implementation exposed several clashing method
      # names and we want to ensure backwards compatibility
      class << self
        def tags
          @snapshot[:tags].map { |tag| { key: tag[:key], value: tag[:value] } }
        end
      end
    end
  end

  def create_volume_permissions
    return [] if !@snapshot
    catch_aws_errors do
      @resp = @aws.compute_client.describe_snapshot_attribute({
                                           attribute: "createVolumePermission",
                                           snapshot_id: @snapshot[:snapshot_id],
                                         })
      if !@resp.respond_to?('create_volume_permissions')
        raise Inspec::Exceptions::ResourceFailed, 'Expected to receive a field describing the create volume permissions - but none was received'
      end
      @resp.create_volume_permissions
    end
  end

  def public?
    self.create_volume_permissions.each do |permission|
      return true if permission.key?(:group) && permission[:group] == 'all'
    end
    return false
  end

  def private?
    !self.public?
  end

  def id
    return nil if !exists?
    @snapshot[:snapshot_id]
  end

  def exists?
    return false if @snapshot.nil?
    !@snapshot.empty?
  end

  def encrypted?
    @snapshot[:encrypted]
  end

  def to_s
    "EBS Snapshot #{@display_name}"
  end
end
