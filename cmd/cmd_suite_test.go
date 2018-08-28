package cmd_test

import (
	"testing"

	. "github.com/Microsoft/oe-engine/pkg/test"
)

func TestCmd(t *testing.T) {

	RunSpecsWithReporters(t, "cmd", "Cmd Suite")

}
