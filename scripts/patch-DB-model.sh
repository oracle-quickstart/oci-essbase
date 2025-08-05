sed -i '' '/cpu_core_count           = "1"/ {
s/^/#/
a\
 compute_model            = "ECPU\
 compute_count            = "4.0"
}' ../terraform/modules/database/main.tf