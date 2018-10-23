package engine

import (
	"bytes"
	"encoding/base64"
	"errors"
	"fmt"
	"runtime/debug"
	"strings"
	"text/template"

	"github.com/Microsoft/oe-engine/pkg/api"
	"github.com/Microsoft/oe-engine/pkg/helpers"
)

// TemplateGenerator represents the object that performs the template generation.
type TemplateGenerator struct {
}

// InitializeTemplateGenerator creates a new template generator object
func InitializeTemplateGenerator() (*TemplateGenerator, error) {
	t := &TemplateGenerator{}

	if err := t.verifyFiles(); err != nil {
		return nil, err
	}

	return t, nil
}

// GenerateTemplate generates the template from the API Model
func (t *TemplateGenerator) GenerateTemplate(oe *api.OpenEnclave, generatorCode string, isUpgrade bool) (templateRaw string, parametersRaw string, certsGenerated bool, err error) {
	// named return values are used in order to set err in case of a panic
	templateRaw = ""
	parametersRaw = ""
	err = nil

	var templ *template.Template

	properties := oe.Properties

	setPropertiesDefaults(oe, isUpgrade)

	templ = template.New("oe template").Funcs(t.getTemplateFuncMap(oe))

	for _, file := range templateFiles {
		bytes, e := Asset(file)
		if e != nil {
			err = fmt.Errorf("Error reading file %s, Error: %s", file, e.Error())
			return templateRaw, parametersRaw, certsGenerated, err
		}
		if _, err = templ.New(file).Parse(string(bytes)); err != nil {
			return templateRaw, parametersRaw, certsGenerated, err
		}
	}
	// template generation may have panics in the called functions.  This catches those panics
	// and ensures the panic is returned as an error
	defer func() {
		if r := recover(); r != nil {
			s := debug.Stack()
			err = fmt.Errorf("%v - %s", r, s)

			// invalidate the template and the parameters
			templateRaw = ""
			parametersRaw = ""
		}
	}()

	//if !validateDistro(oe) {
	//	return templateRaw, parametersRaw, certsGenerated, fmt.Errorf("Invalid distro")
	//}

	var b bytes.Buffer
	if err = templ.ExecuteTemplate(&b, baseFile, properties); err != nil {
		return templateRaw, parametersRaw, certsGenerated, err
	}
	templateRaw = b.String()

	var parametersMap paramsMap
	if parametersMap, err = getParameters(oe, generatorCode); err != nil {
		return templateRaw, parametersRaw, certsGenerated, err
	}

	var parameterBytes []byte
	if parameterBytes, err = helpers.JSONMarshal(parametersMap, false); err != nil {
		return templateRaw, parametersRaw, certsGenerated, err
	}
	parametersRaw = string(parameterBytes)

	return templateRaw, parametersRaw, certsGenerated, err
}

func (t *TemplateGenerator) verifyFiles() error {
	allFiles := templateFiles
	for _, file := range allFiles {
		if _, err := Asset(file); err != nil {
			return fmt.Errorf("template file %s does not exist", file)
		}
	}
	return nil
}

// getTemplateFuncMap returns all functions used in template generation
func (t *TemplateGenerator) getTemplateFuncMap(cs *api.OpenEnclave) template.FuncMap {
	return template.FuncMap{
		"RequiresFakeAgentOutput": func() bool {
			return false
		},
		"IsPublic": func(ports []int) bool {
			return len(ports) > 0
		},

		"IsPrivateCluster": func() bool {
			return false
		},
		"GetLBRules": func(name string, ports []int) string {
			return getLBRules(name, ports)
		},
		"GetProbes": func(ports []int) string {
			return getProbes(ports)
		},
		"GetSecurityRules": func(ports []int) string {
			return getSecurityRules(ports)
		},
		"GetLinuxCustomData": func() string {
			str := getSingleLineCustomData(
				customdata,
				map[string]string{
					"UTILS_STR":      getProvisionScript(utilsScript, nil),
					"PROVISION_STR":  getProvisionScript(provisionScript, map[string]string{"PACKAGE_BASE_URL": cs.PackageBaseURL}),
					"VALIDATION_STR": getProvisionScript(validationScript, nil),
				})
			return fmt.Sprintf("base64(concat('#cloud-config\\n\\n', '%s'))", str)
		},
		"GetWindowsCustomData": func() string {
			b, err := Asset(windowsProvision)
			if err != nil {
				// this should never happen and this is a bug
				panic(fmt.Sprintf("BUG: %s", err.Error()))
			}
			csStr := string(b)
			csStr = strings.Replace(csStr, "SSH_PUB_KEY", cs.Properties.WindowsProfile.SSHPubKey, -1)
			return getBase64CustomScriptFromStr(csStr)
		},
		"GetAllowedVMSizes": func() string {
			return api.GetAllowedVMSizes()
		},
		"GetOsDiskTypes": func() string {
			return api.GetOsDiskTypes()
		},
		"GetOSImageNames": func() string {
			return api.GetOSImageNames()
		},
		"GetOSImageReferences": func() string {
			return api.GetOSImageReferences()
		},
		"GetVMPlans": func() string {
			return api.GetVMPlans()
		},
		"Base64": func(s string) string {
			return base64.StdEncoding.EncodeToString([]byte(s))
		},
		"WriteLinkedTemplatesForExtensions": func() string {
			return ""
		},
		"GetAllowedLocations": func() string {
			return api.GetAllowedLocations()
		},
		"WrapAsVariable": func(s string) string {
			return fmt.Sprintf("',variables('%s'),'", s)
		},
		"WrapAsVerbatim": func(s string) string {
			return fmt.Sprintf("',%s,'", s)
		},
		"HasLinuxSecrets": func() bool {
			return cs.Properties.LinuxProfile != nil && cs.Properties.LinuxProfile.HasSecrets()
		},
		"HasCustomSearchDomain": func() bool {
			return cs.Properties.LinuxProfile != nil && cs.Properties.LinuxProfile.HasSearchDomain()
		},
		"HasCustomNodesDNS": func() bool {
			return cs.Properties.LinuxProfile != nil && cs.Properties.LinuxProfile.HasCustomNodesDNS()
		},
		"HasWindowsSecrets": func() bool {
			return cs.Properties.WindowsProfile != nil && cs.Properties.WindowsProfile.HasSecrets()
		},
		"HasWindowsCustomImage": func() bool {
			return cs.Properties.WindowsProfile != nil && cs.Properties.WindowsProfile.HasCustomImage()
		},
		// inspired by http://stackoverflow.com/questions/18276173/calling-a-template-with-several-pipeline-parameters/18276968#18276968
		"dict": func(values ...interface{}) (map[string]interface{}, error) {
			if len(values)%2 != 0 {
				return nil, errors.New("invalid dict call")
			}
			dict := make(map[string]interface{}, len(values)/2)
			for i := 0; i < len(values); i += 2 {
				key, ok := values[i].(string)
				if !ok {
					return nil, errors.New("dict keys must be strings")
				}
				dict[key] = values[i+1]
			}
			return dict, nil
		},
		"loop": func(min, max int) []int {
			var s []int
			for i := min; i <= max; i++ {
				s = append(s, i)
			}
			return s
		},
		"subtract": func(a, b int) int {
			return a - b
		},
	}
}
