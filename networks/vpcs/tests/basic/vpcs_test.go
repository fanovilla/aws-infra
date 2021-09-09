package basic

import (
	"github.com/fanovilla/terraform-unit-testing/tut"
	"testing"
)

func TestResourceCounts(t *testing.T) {
	plan := tut.Plan(t)

	plan.AssertResourceCounts(t, map[string]int{
		"aws_vpc":                             2,
		"aws_subnet":                          18,
		"aws_vpc_ipv4_cidr_block_association": 2,
	})
}
