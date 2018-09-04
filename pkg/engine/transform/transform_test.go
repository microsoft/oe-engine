package transform

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"testing"

	"github.com/Microsoft/oe-engine/pkg/helpers"
	. "github.com/onsi/gomega"
	"github.com/sirupsen/logrus"
)

func TestNormalizeForVMSSScaling(t *testing.T) {
	RegisterTestingT(t)
	logger := logrus.New().WithField("testName", "TestNormalizeForVMSSScaling")
	fileContents, e := ioutil.ReadFile("./transformtestfiles/oe_template.json")
	Expect(e).To(BeNil())
	expectedFileContents, e := ioutil.ReadFile("./transformtestfiles/oe_scale_template.json")
	Expect(e).To(BeNil())
	templateJSON := string(fileContents)
	var template interface{}
	json.Unmarshal([]byte(templateJSON), &template)
	templateMap := template.(map[string]interface{})
	transformer := Transformer{}
	e = transformer.NormalizeForVMSSScaling(logger, templateMap)
	Expect(e).To(BeNil())
	ValidateTemplate(templateMap, expectedFileContents, "TestNormalizeForVMSSScaling")
}

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
