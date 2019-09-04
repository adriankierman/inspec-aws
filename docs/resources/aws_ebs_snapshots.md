---
title: About the aws_ebs_snapshots Resource
platform: aws
---

# aws\_ebs\_snapshots

Use the `aws_ebs_snapshots` InSpec audit resource to test properties of some or all AWS EBS snapshots. To audit a single EBS snapshot, use `aws_ebs_snapshot` (singular).

EBS snapshots are persistent block storage snapshots for use with Amazon EC2 instances in the AWS Cloud.

Each EBS snapshot is uniquely identified by its ID.

<br>

## Syntax

An `aws_ebs_snapshots` resource block collects a group of EBS snapshots and then tests that group.

    # Ensure you have exactly 3 snapshots
    describe aws_ebs_snapshots do
      its('snapshot_ids.count') { should cmp 3 }
    end

    # Use the InSpec resource to enumerate IDs, then test in-depth using `aws_ebs_snapshot`.
    aws_ebs_snapshots.snapshot_ids.each do |snapshot_id|
      describe aws_ebs_snapshot(snapshot_id) do
        it { should exist }
        it { should be_encrypted }
      end
    end

<br>

## Examples

As this is the initial release of `aws_ebs_snapshots`, its limited functionality precludes examples.

<br>

## Filter Criteria

You should be able to filter using the same filters supported by the API. It is strongly suggested that one should always filter down to just the snapshots one owns, to avoid fetching many public snapshots.

* filters (Array) — An array of filters.
  - description - A description of the snapshot.
  - encrypted - Indicates whether the snapshot is encrypted (true | false)
  - owner-alias - Value from an Amazon-maintained list (amazon | self | all | aws-marketplace | microsoft) of snapshot owners. Not to be confused with the user-configured AWS account alias, which is set from the IAM console.
  - owner-id - The ID of the AWS account that owns the snapshot.
  - progress - The progress of the snapshot, as a percentage (for example, 80%).
  - snapshot-id - The snapshot ID.
  - start-time - The time stamp when the snapshot was initiated.
  - status - The status of the snapshot (pending | completed | error).
  - volume-id - The ID of the volume the snapshot is for.
  - volume-size - The size of the volume, in GiB.
* owner_ids (Array<String>) — Describes the snapshots owned by these owners.
* restorable_by_user_ids (Array<String>) — The IDs of the AWS accounts that can create volumes from the snapshot.
* snapshot_ids (Array<String>) — The snapshot IDs.

## Properties

### entries

Provides access to the raw results of the query, which can be treated as an array of hashes. This can be useful for checking counts and other advanced operations.

    # Allow at most 100 EBS snapshots on the account
    describe aws_ebs_snapshots do
      its('entries.count') { should be <= 100 }
    end

### snapshot_ids

Provides a list of the snapshot ids that were found in the query.

    describe aws_ebs_snapshots do
      its('snapshot_ids') { should include 'snap-12345678' }
      its('snapshot_ids.count') { should cmp 3 }
    end

<br>

## Matchers

For a full list of available matchers, please visit our [Universal Matchers page](https://www.inspec.io/docs/reference/matchers/). 

### exist

The control will pass if the filter returns at least one result. Use `should_not` if you expect zero matches.

    # Verify that at least one EBS snapshot exists
    describe aws_ebs_snapshots do
      it { should exist }
    end   
