package test

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func TestTerraformTags(t *testing.T) {
	t.Parallel()
	// retryable errors in terraform testing.
	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]interface{}{
			"team": "team",
			"environment": "test",
			"region": "dr",
			"name": "app",
			"attributes": []string{"demo"},
		},

	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	verifyGeneratedTags(t, terraformOptions)

}

func verifyGeneratedTags(t *testing.T, terraformOptions *terraform.Options) {

	id := terraform.Output(t, terraformOptions, "id")
	assert.Equal(t, "team-test-dr-app-demo", id)

	tags := terraform.OutputMap(t, terraformOptions, "tags")
	assert.Equal(t, "team-test-dr-app-demo", tags["Name"])
	assert.Equal(t, "team", tags["Team"])
	assert.Equal(t, "test", tags["Environment"])
	assert.Equal(t, "dr", tags["Region"])
	assert.Equal(t, "demo", tags["Attributes"])

}
