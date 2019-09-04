---
title: About the aws_ebs_snapshot Resource
platform: aws
---

# aws\_ebs\_snapshot

Use the `aws_ebs_snapshot` InSpec audit resource to test properties of a single AWS EBS snapshot.

<br>

## Syntax

An `aws_ebs_snapshot` resource block declares the tests for a single AWS EBS snapshot by either name or id.

    describe aws_ebs_snapshot('snap-01a2349e94458a507') do
      it { should exist }
    end

    describe aws_ebs_snapshot(name: 'data-snap') do
      it { should be_encrypted }
    end

<br>

## Examples

The following examples show how to use this InSpec audit resource.

### Test that an EBS Snapshot does not exist

    describe aws_ebs_snapshot(name: 'data_snap') do
      it { should_not exist }
    end

### Test that an EBS Snapshot is encrypted

    describe aws_ebs_snapshot(name: 'secure_data_snap') do
      it { should be_encrypted }
    end


<br>

## Properties

* `description`: String
* `encrypted`: true/false
* `owner_alias`: String
* `data_encryption_key_id`: String
* `kms_key_id`: String
* `owner_id`: String
* `progress`: String
* `snapshot_id`: String
* `start_time`: Time
* `state`: String, one of "pending", "completed", "error"
* `state_message`: String
* `volume_id`: String
* `volume_size`: Integer
* `tags`: Array
* `tags[0].key`String
* `tags[0].value`String

<br>

## Matchers

This InSpec audit resource has the following special matchers. For a full list of available matchers, please visit our [matchers page](https://www.inspec.io/docs/reference/matchers/).

### be\_encrypted

The `be_encrypted` matcher tests if the described EBS Snapshot is encrypted.

    it { should be_encrypted }

## AWS Permissions

Your [Principal](https://docs.aws.amazon.com/IAM/latest/UserGuide/intro-structure.html#intro-structure-principal) will need the `ec2:DescribeSnapshots`, and `iam:GetInstanceProfile` actions set to allow.

You can find detailed documentation at [Actions, Resources, and Condition Keys for Amazon EC2](https://docs.aws.amazon.com/IAM/latest/UserGuide/list_amazonec2.html), and [Actions, Resources, and Condition Keys for Identity And Access Management](https://docs.aws.amazon.com/IAM/latest/UserGuide/list_identityandaccessmanagement.html).
