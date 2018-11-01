package api

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"reflect"

	"github.com/Microsoft/oe-engine/pkg/helpers"
	log "github.com/sirupsen/logrus"
)

// Apiloader represents the object that loads api model
type Apiloader struct {
}

// LoadOpenEnclaveFromFile loads an OE API Model from a JSON file
func (a *Apiloader) LoadOpenEnclaveFromFile(jsonFile string, validate, isUpdate bool, sshPubKeys []string) (*OpenEnclave, error) {
	contents, e := ioutil.ReadFile(jsonFile)
	if e != nil {
		return nil, fmt.Errorf("error reading file %s: %s", jsonFile, e.Error())
	}
	return a.DeserializeOpenEnclave(contents, validate, isUpdate, sshPubKeys)
}

// DeserializeOpenEnclave loads an ACS Cluster API Model, validates it, and returns the unversioned representation
func (a *Apiloader) DeserializeOpenEnclave(contents []byte, validate, isUpdate bool, sshPubKeys []string) (*OpenEnclave, error) {
	oe, err := a.LoadOpenEnclave(contents, validate, isUpdate, sshPubKeys)
	if oe == nil || err != nil {
		log.Infof("Error returned by LoadOpenEnclave: %+v", err)
	}
	return oe, err
}

// LoadOpenEnclave loads and validates an OE API Model
func (a *Apiloader) LoadOpenEnclave(contents []byte, validate, isUpdate bool, sshPubKeys []string) (*OpenEnclave, error) {
	oe := &OpenEnclave{}
	if e := json.Unmarshal(contents, oe); e != nil {
		return nil, e
	}
	if e := checkJSONKeys(contents, reflect.TypeOf(*oe)); e != nil {
		return nil, e
	}
	// add SSH public keys from command line arguments
	if oe.Properties.LinuxProfile != nil {
		for _, key := range sshPubKeys {
			oe.Properties.LinuxProfile.SSHPubKeys = append(oe.Properties.LinuxProfile.SSHPubKeys, &PublicKey{KeyData: key})
		}
	}
	if e := oe.Properties.Validate(isUpdate); validate && e != nil {
		return nil, e
	}
	return oe, nil
}

// SerializeOpenEnclave takes an unversioned container service and returns the bytes
func (a *Apiloader) SerializeOpenEnclave(oe *OpenEnclave) ([]byte, error) {
	return helpers.JSONMarshalIndent(oe, "", "  ", false)
}
