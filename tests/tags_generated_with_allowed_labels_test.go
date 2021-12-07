package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformTagsWithAllowedLabels(t *testing.T) {
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"team": "team",
			"environment": "test",
			"region": "dr",
			"name": "app",
			"attributes": []string{"demo"},
			"labels_allowed_in_tags": []string{"name"},
		},

	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	verifyTerraformTagsWithAllowedLabels(t, terraformOptions)

}

func verifyTerraformTagsWithAllowedLabels(t *testing.T, terraformOptions *terraform.Options) {

	id := terraform.Output(t, terraformOptions, "id")
	assert.Equal(t, "team-test-dr-app-demo", id)

	tags := terraform.OutputMap(t, terraformOptions, "tags")
	assert.Equal(t, "team-test-dr-app-demo", tags["Name"])
	assert.Equal(t, "", tags["Team"])
	assert.Equal(t, "", tags["Environment"])
	assert.Equal(t, "", tags["Region"])
	assert.Equal(t, "", tags["Attributes"])

}
