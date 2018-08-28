package engine

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io/ioutil"
	"path/filepath"
	"strings"
	"testing"

	"github.com/Microsoft/oe-engine/pkg/api"
	"github.com/Microsoft/oe-engine/pkg/engine/transform"
)

const (
	TestDataDir = "./testdata"
)

func TestExpected(t *testing.T) {
	apiloader := &api.Apiloader{}
	// iterate the test data directory
	apiModelTestFiles := &[]APIModelTestFile{}
	if e := IterateTestFilesDirectory(TestDataDir, apiModelTestFiles); e != nil {
		t.Error(e.Error())
		return
	}

	for _, tuple := range *apiModelTestFiles {
		containerService, version, err := apiloader.LoadContainerServiceFromFile(tuple.APIModelFilename, true, false, nil)
		if err != nil {
			t.Errorf("Loading file %s got error: %s", tuple.APIModelFilename, err.Error())
			continue
		}

		isClassicMode := false
		if strings.Contains(tuple.APIModelFilename, "_classicmode") {
			isClassicMode = true
		}

		// test the output container service 3 times:
		// 1. first time tests loaded containerService
		// 2. second time tests generated containerService
		// 3. third time tests the generated containerService from the generated containerService
		ctx := Context{}
		templateGenerator, e3 := InitializeTemplateGenerator(ctx, isClassicMode)
		if e3 != nil {
			t.Error(e3.Error())
			continue
		}

		armTemplate, params, certsGenerated, err := templateGenerator.GenerateTemplate(containerService, DefaultGeneratorCode, false)
		if err != nil {
			t.Error(fmt.Errorf("error in file %s: %s", tuple.APIModelFilename, err.Error()))
			continue
		}

		expectedPpArmTemplate, e1 := transform.PrettyPrintArmTemplate(armTemplate)
		if e1 != nil {
			t.Error(armTemplate)
			t.Error(fmt.Errorf("error in file %s: %s", tuple.APIModelFilename, e1.Error()))
			break
		}

		expectedPpParams, e2 := transform.PrettyPrintJSON(params)
		if e2 != nil {
			t.Error(fmt.Errorf("error in file %s: %s", tuple.APIModelFilename, e2.Error()))
			continue
		}

		if certsGenerated {
			t.Errorf("cert generation unexpected for %s", containerService.Properties.OrchestratorProfile.OrchestratorType)
		}

		for i := 0; i < 3; i++ {
			armTemplate, params, certsGenerated, err := templateGenerator.GenerateTemplate(containerService, DefaultGeneratorCode, false)
			if err != nil {
				t.Error(fmt.Errorf("error in file %s: %s", tuple.APIModelFilename, err.Error()))
				continue
			}
			generatedPpArmTemplate, e1 := transform.PrettyPrintArmTemplate(armTemplate)
			if e1 != nil {
				t.Error(fmt.Errorf("error in file %s: %s", tuple.APIModelFilename, e1.Error()))
				continue
			}

			generatedPpParams, e2 := transform.PrettyPrintJSON(params)
			if e2 != nil {
				t.Error(fmt.Errorf("error in file %s: %s", tuple.APIModelFilename, e2.Error()))
				continue
			}

			if certsGenerated {
				t.Errorf("cert generation unexpected for %s", containerService.Properties.OrchestratorProfile.OrchestratorType)
			}

			if !bytes.Equal([]byte(expectedPpArmTemplate), []byte(generatedPpArmTemplate)) {
				diffstr, differr := tuple.WriteArmTemplateErrFilename([]byte(generatedPpArmTemplate))
				if differr != nil {
					diffstr += differr.Error()
				}
				t.Errorf("generated output different from expected for model %s: '%s'", tuple.APIModelFilename, diffstr)
			}

			if !bytes.Equal([]byte(expectedPpParams), []byte(generatedPpParams)) {
				diffstr, differr := tuple.WriteArmTemplateParamsErrFilename([]byte(generatedPpParams))
				if differr != nil {
					diffstr += differr.Error()
				}
				t.Errorf("generated parameters different from expected for model %s: '%s'", tuple.APIModelFilename, diffstr)
			}

			b, err := apiloader.SerializeContainerService(containerService, version)
			if err != nil {
				t.Error(err)
			}
			containerService, version, err = apiloader.DeserializeContainerService(b, true, false, nil)
			if err != nil {
				t.Error(err)
			}
		}
	}
}

// APIModelTestFile holds the test file name and knows how to find the expected files
type APIModelTestFile struct {
	APIModelFilename string
}

// WriteArmTemplateErrFilename writes out an error file to sit parallel for comparison
func (a *APIModelTestFile) WriteArmTemplateErrFilename(contents []byte) (string, error) {
	filename := fmt.Sprintf("%s_expected.err", a.APIModelFilename)
	if err := ioutil.WriteFile(filename, contents, 0600); err != nil {
		return "", err
	}
	return fmt.Sprintf("%s written for diff", filename), nil
}

// WriteArmTemplateParamsErrFilename writes out an error file to sit parallel for comparison
func (a *APIModelTestFile) WriteArmTemplateParamsErrFilename(contents []byte) (string, error) {
	filename := fmt.Sprintf("%s_expected_params.err", a.APIModelFilename)
	if err := ioutil.WriteFile(filename, contents, 0600); err != nil {
		return "", err
	}
	return fmt.Sprintf("%s written for diff", filename), nil
}

// IterateTestFilesDirectory iterates the test data directory adding api model files to the test file slice.
func IterateTestFilesDirectory(directory string, APIModelTestFiles *[]APIModelTestFile) error {
	files, err := ioutil.ReadDir(directory)
	if err != nil {
		return err
	}

	for _, file := range files {
		if file.IsDir() {
			if e := IterateTestFilesDirectory(filepath.Join(directory, file.Name()), APIModelTestFiles); e != nil {
				return e
			}
		} else {
			if !strings.Contains(file.Name(), "_expected") && strings.HasSuffix(file.Name(), ".json") {
				tuple := &APIModelTestFile{}
				tuple.APIModelFilename = filepath.Join(directory, file.Name())
				*APIModelTestFiles = append(*APIModelTestFiles, *tuple)
			}
		}
	}
	return nil
}

func TestGetStorageAccountType(t *testing.T) {
	validPremiumVMSize := "Standard_DS2_v2"
	validStandardVMSize := "Standard_D2_v2"
	expectedPremiumTier := "Premium_LRS"
	expectedStandardTier := "Standard_LRS"
	invalidVMSize := "D2v2"

	// test premium VMSize returns premium managed disk tier
	premiumTier, err := getStorageAccountType(validPremiumVMSize)
	if err != nil {
		t.Fatalf("Invalid sizeName: %s", err)
	}

	if premiumTier != expectedPremiumTier {
		t.Fatalf("premium VM did no match premium managed storage tier")
	}

	// test standard VMSize returns standard managed disk tier
	standardTier, err := getStorageAccountType(validStandardVMSize)
	if err != nil {
		t.Fatalf("Invalid sizeName: %s", err)
	}

	if standardTier != expectedStandardTier {
		t.Fatalf("standard VM did no match standard managed storage tier")
	}

	// test invalid VMSize
	result, err := getStorageAccountType(invalidVMSize)
	if err == nil {
		t.Errorf("getStorageAccountType() = (%s, nil), want error", result)
	}
}

type TestARMTemplate struct {
	Outputs map[string]OutputElement `json:"outputs"`
	//Parameters *json.RawMessage `json:"parameters"`
	//Resources  *json.RawMessage `json:"resources"`
	//Variables  *json.RawMessage `json:"variables"`
}

type OutputElement struct {
	Type  string `json:"type"`
	Value string `json:"value"`
}

func TestTemplateOutputPresence(t *testing.T) {
	apiloader := &api.Apiloader{}

	ctx := Context{}

	templateGenerator, err := InitializeTemplateGenerator(ctx, false)

	if err != nil {
		t.Fatalf("Failed to initialize template generator: %v", err)
	}

	containerService, _, err := apiloader.LoadContainerServiceFromFile("./testdata/simple/dcos.json", true, false, nil)
	if err != nil {
		t.Fatalf("Failed to load container service from file: %v", err)
	}
	armTemplate, _, _, err := templateGenerator.GenerateTemplate(containerService, DefaultGeneratorCode, false)
	if err != nil {
		t.Fatalf("Failed to generate arm template: %v", err)
	}

	var template TestARMTemplate
	err = json.Unmarshal([]byte(armTemplate), &template)
	if err != nil {
		t.Fatalf("couldn't unmarshall ARM template: %#v\n", err)
	}

	tt := []struct {
		key   string
		value string
	}{
		{key: "agentpublicFQDN", value: "[reference(concat('Microsoft.Network/publicIPAddresses/', variables('agentpublicIPAddressName'))).dnsSettings.fqdn]"},
		{key: "masterFQDN", value: "[reference(concat('Microsoft.Network/publicIPAddresses/', variables('masterPublicIPAddressName'))).dnsSettings.fqdn]"},
	}
	for _, tc := range tt {
		element, found := template.Outputs[tc.key]
		if !found {
			t.Fatalf("Output key %v not found", tc.key)
		} else if element.Value != tc.value {
			t.Fatalf("Expected %q at key %v but got: %q", tc.value, tc.key, element.Value)
		}
	}
}

func TestIsCustomVNET(t *testing.T) {

	a := []*api.AgentPoolProfile{
		{
			VnetSubnetID: "subnetlink1",
		},
		{
			VnetSubnetID: "subnetlink2",
		},
	}

	if !isCustomVNET(a) {
		t.Fatalf("Expected isCustomVNET to be true when subnet exists for all agent pool profile")
	}

	a = []*api.AgentPoolProfile{
		{
			VnetSubnetID: "subnetlink1",
		},
		{
			VnetSubnetID: "",
		},
	}

	if isCustomVNET(a) {
		t.Fatalf("Expected isCustomVNET to be false when subnet exists for some agent pool profile")
	}

	a = nil

	if isCustomVNET(a) {
		t.Fatalf("Expected isCustomVNET to be false when agent pool profiles is nil")
	}
}

func TestGenerateIpList(t *testing.T) {
	count := 3
	forth := 240
	ipList := generateIPList(count, fmt.Sprintf("10.0.0.%d", forth))
	if len(ipList) != 3 {
		t.Fatalf("IP list size should be %d", count)
	}
	for i, ip := range ipList {
		expected := fmt.Sprintf("10.0.0.%d", forth+i)
		if ip != expected {
			t.Fatalf("wrong IP %s. Expected %s", ip, expected)
		}
	}
}
