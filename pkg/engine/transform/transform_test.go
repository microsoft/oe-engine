package transform

import (
	"fmt"
	"io/ioutil"

	"github.com/Microsoft/oe-engine/pkg/helpers"
	. "github.com/onsi/gomega"
)

func ValidateTemplate(templateMap map[string]interface{}, expectedFileContents []byte, testFileName string) {
	output, e := helpers.JSONMarshal(templateMap, false)
	Expect(e).To(BeNil())
	prettyOutput, e := PrettyPrintArmTemplate(string(output))
	Expect(e).To(BeNil())
	prettyExpectedOutput, e := PrettyPrintArmTemplate(string(expectedFileContents))
	Expect(e).To(BeNil())
	if prettyOutput != prettyExpectedOutput {
		ioutil.WriteFile(fmt.Sprintf("./transformtestfiles/%s.failure.json", testFileName), []byte(prettyOutput), 0600)
	}
	Expect(prettyOutput).To(Equal(prettyExpectedOutput))
}
