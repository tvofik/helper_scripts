import boto3
client = boto3.client('backup')

paginator = client.get_paginator('list_recovery_points_by_backup_vault')

page_iterator = paginator.paginate(
    BackupVaultName='aft-controltower-backup-vault'
)

for page in page_iterator:
    points = page['RecoveryPoints']
    arn = [x['RecoveryPointArn'] for x in points]

    for a in arn:
        response = client.delete_recovery_point(
            BackupVaultName='aft-controltower-backup-vault',
            RecoveryPointArn=a
        )
