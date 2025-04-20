resource "aws_grafana_workspace" "existing" {
    name                      = "nusiss"
    account_access_type       = "CURRENT_ACCOUNT"
    authentication_providers  = ["AWS_SSO"]

    permission_type           = "SERVICE_MANAGED"
    role_arn                  = "arn:aws:iam::746441023300:role/service-role/AmazonGrafanaServiceRole-1erDMkNqk"
    
    data_sources              = [
        "SITEWISE",
        "XRAY",
        "CLOUDWATCH",
        "AMAZON_OPENSEARCH_SERVICE",
        "PROMETHEUS",
        "TIMESTREAM",
        "REDSHIFT",
        "ATHENA",
    ]
    notification_destinations = ["SNS"]
    configuration             = jsonencode(
        {
            plugins         = {
                pluginAdminEnabled = false
            }
            unifiedAlerting = {
                enabled = false
            }
        }
    )
    tags                      = {
        "Owner" = "bhaarathan23@gmail.com"
    }
}