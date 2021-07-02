package test

import (
	"math/rand"
	"strconv"
	"testing"
  "time"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

// Test the Terraform module in examples/complete using Terratest.
func TestExamplesComplete(t *testing.T) {
	t.Parallel()

	rand.Seed(time.Now().UnixNano())

	randId := strconv.Itoa(rand.Intn(100000))
//	attributes := []string{randId}

	terraformOptions := &terraform.Options{
		// The path to where our Terraform code is located
		TerraformDir: "./fixture",
		Upgrade:      true,
		// Variables to pass to our Terraform code using -var-file options
//		VarFiles: []string{"fixtures.eu-west-1.tfvars"},
		Vars: map[string]interface{}{
			"attributes": randId,
		},
	}

	// At the end of the test, run `terraform destroy` to clean up any resources that were created
	defer terraform.Destroy(t, terraformOptions)

	// This will run `terraform init` and `terraform apply` and fail the test if there are any errors
	terraform.InitAndApply(t, terraformOptions)

	// Run `terraform output` to get the value of an output variable
	vpcCidr := terraform.Output(t, terraformOptions, "vpc_cidr")
	expectedVpcCidr := "10.0.0.0/16"
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedVpcCidr, vpcCidr)

	// Run `terraform output` to get the value of an output variable
	efsArn := terraform.Output(t, terraformOptions, "efs_arn")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, efsArn, "arn:aws:elasticfilesystem:eu-west-1:")

	// Run `terraform output` to get the value of an output variable
	efsId := terraform.Output(t, terraformOptions, "efs_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, efsId, "fs-")

	// Run `terraform output` to get the value of an output variable
	securityGroupName := terraform.Output(t, terraformOptions, "security_group_name")
	expectedSecurityGroupName := "sec-efstest-" + randId
	// Verify we're getting back the outputs we expect
	assert.Equal(t, expectedSecurityGroupName, securityGroupName)

	// Run `terraform output` to get the value of an output variable
	securityGroupID := terraform.Output(t, terraformOptions, "security_group_id")
	// Verify we're getting back the outputs we expect
	assert.Contains(t, securityGroupID, "sg-", "SG ID should contains substring 'sg-'")

}
